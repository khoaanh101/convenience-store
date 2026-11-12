import json
from datetime import datetime
from typing import Annotated
from uuid import uuid4

from fastapi import APIRouter, Body, Depends, HTTPException
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError, OperationalError
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.connection import get_session
from app.services.crud import execute_write, register_crud_routes
from app.services.ton_kho import finish_stock_change, lock_product

router = APIRouter(prefix="/hoa-don", tags=["Hoa don"])


class DongBanHang(BaseModel):
    MaHH: str = Field(min_length=1, max_length=10)
    SoLuong: int = Field(strict=True, gt=0, le=2147483647)


class HoaDonBanHang(BaseModel):
    MaHD: str = Field(pattern=r"^[A-Za-z0-9_-]{1,20}$")
    MaPK: str = Field(min_length=1, max_length=10)
    MaKH: str | None = Field(default=None, min_length=1, max_length=10)
    MatHang: list[DongBanHang] = Field(min_length=1)


@router.post("/ban-hang", status_code=201)
async def ban_hang(
    payload: HoaDonBanHang,
    session: Annotated[AsyncSession, Depends(get_session)],
):
    try:
        async with session.begin():
            products = {}
            # Cùng thứ tự khóa giữa các hóa đơn có nhiều mặt hàng.
            for line in sorted(payload.MatHang, key=lambda item: item.MaHH.casefold()):
                product = await lock_product(session, line.MaHH)
                if product["Gia"] <= 0:
                    raise HTTPException(422, "Giá bán phải lớn hơn 0.")
                code = product["MaHH"]
                if code in products:
                    raise HTTPException(422, f"Mã hàng {code} bị lặp.")
                if line.SoLuong > product["SoLuongHangTonKho"]:
                    raise HTTPException(409, f"Hàng {code} không đủ tồn kho.")
                products[code] = (product, line.SoLuong)

            await session.execute(
                text("INSERT INTO hoa_don (MaHD, MaPK, MaKH) VALUES (:MaHD, :MaPK, :MaKH)"),
                payload.model_dump(exclude={"MatHang"}),
            )
            for code, (product, quantity) in products.items():
                await session.execute(
                    text(
                        "INSERT INTO chi_tiet_hoa_don (MaCTHD, MaHD, MaHH, SoLuong, Gia) "
                        "VALUES (:id, :invoice, :code, :quantity, :price)"
                    ),
                    {"id": uuid4().hex[:20], "invoice": payload.MaHD, "code": code,
                     "quantity": quantity, "price": product["Gia"]},
                )
                await finish_stock_change(
                    session, code, product["SoLuongHangTonKho"], -quantity
                )
    except IntegrityError as exc:
        raise HTTPException(409, "Mã hóa đơn bị trùng hoặc mã ca/khách hàng không hợp lệ.") from exc
    except OperationalError as exc:
        if exc.orig.args[0:1] == (1644,):
            raise HTTPException(409, str(exc.orig.args[1])) from exc
        raise
    return {"MaHD": payload.MaHD}


@router.get("/{record_id}/chi-tiet")
async def chi_tiet(
    record_id: str, session: Annotated[AsyncSession, Depends(get_session)]
):
    invoice = (await session.execute(
        text(
            "SELECT hd.MaHD, hd.MaPK, hd.MaKH, hd.ThoiGian, kh.HoTen "
            "FROM hoa_don hd LEFT JOIN khach_hang kh ON kh.MaKH = hd.MaKH "
            "WHERE hd.MaHD = :id"
        ),
        {"id": record_id},
    )).mappings().one_or_none()
    if invoice is None:
        raise HTTPException(404, "Không tìm thấy hóa đơn.")
    lines = (await session.execute(
        text(
            "SELECT ct.MaHH, hh.TenHang, ct.SoLuong, ct.Gia, ct.ThanhTien "
            "FROM chi_tiet_hoa_don ct JOIN hang_hoa hh ON hh.MaHH = ct.MaHH "
            "WHERE ct.MaHD = :id ORDER BY ct.MaHH"
        ),
        {"id": record_id},
    )).mappings().all()
    total = sum(line["ThanhTien"] for line in lines)
    return {**dict(invoice), "MatHang": [dict(line) for line in lines], "TongTien": str(total)}



class SaleItem(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    ma_hh: str = Field(alias="MaHH", max_length=10)
    so_luong: int = Field(alias="SoLuong", gt=0)


class SaleRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    ma_hd: str = Field(alias="MaHD", max_length=17)
    ma_pk: str = Field(alias="MaPK", max_length=10)
    ma_kh: str | None = Field(default=None, alias="MaKH", max_length=10)
    thoi_gian: datetime | None = Field(default=None, alias="ThoiGian")
    chi_tiet: list[SaleItem] = Field(alias="ChiTiet", min_length=1, max_length=99)


@router.post("/ban-hang")
async def ban_hang(
    payload: Annotated[
        SaleRequest,
        Body(
            json_schema_extra={
                "example": {
                    "MaHD": "HD20260001",
                    "MaPK": "PK001",
                    "MaKH": "KH001",
                    "ThoiGian": "2026-11-05T10:30:00",
                    "ChiTiet": [
                        {"MaHH": "HH001", "SoLuong": 2},
                        {"MaHH": "HH002", "SoLuong": 1},
                    ],
                }
            }
        ),
    ],
    session: Annotated[AsyncSession, Depends(get_session)],
):
    item_codes = [item.ma_hh for item in payload.chi_tiet]
    if len(item_codes) != len(set(item_codes)):
        raise HTTPException(
            status_code=422,
            detail="Mỗi mặt hàng chỉ được xuất hiện một lần trong hóa đơn.",
        )

    await execute_write(
        session,
        "CALL `sp_ban_hang`(:mahd, :mapk, :makh, :thoigian, :dong)",
        {
            "mahd": payload.ma_hd,
            "mapk": payload.ma_pk,
            "makh": payload.ma_kh,
            "thoigian": payload.thoi_gian,
            "dong": json.dumps(
                [
                    {"mahh": item.ma_hh, "sl": item.so_luong}
                    for item in payload.chi_tiet
                ],
                ensure_ascii=False,
            ),
        },
        signal_status_code=422,
    )

    invoice = await session.execute(
        text(
            """
            SELECT MaHD, MaPK, MaKH, ThoiGian
            FROM hoa_don
            WHERE MaHD = :mahd
            """
        ),
        {"mahd": payload.ma_hd},
    )
    details = await session.execute(
        text(
            """
            SELECT MaCTHD, MaHD, MaHH, SoLuong, Gia, ThanhTien
            FROM chi_tiet_hoa_don
            WHERE MaHD = :mahd
            ORDER BY MaCTHD
            """
        ),
        {"mahd": payload.ma_hd},
    )
    return {
        "hoa_don": dict(invoice.mappings().one()),
        "chi_tiet": [dict(row) for row in details.mappings().all()],
    }


register_crud_routes(
    router,
    table="chi_tiet_hoa_don",
    columns=("MaCTHD", "MaHD", "MaHH", "SoLuong", "Gia", "ThanhTien"),
    primary_keys=("MaCTHD",),
    required_columns=("MaCTHD", "MaHD", "MaHH", "SoLuong", "Gia"),
    search_columns=("MaCTHD", "MaHD", "MaHH", "SoLuong", "Gia", "ThanhTien"),
    search_value_placeholders={
        "MaCTHD": "HD20260001-01",
        "MaHD": "HD20260001",
        "MaHH": "HH001",
        "SoLuong": "2",
        "Gia": "10000",
        "ThanhTien": "20000",
    },
    create_example={
        "MaCTHD": "HD20260001-01",
        "MaHD": "HD20260001",
        "MaHH": "HH001",
        "SoLuong": 2,
        "Gia": 10000,
    },
    update_example={"SoLuong": 3, "Gia": 12000},
    generated_columns=("ThanhTien",),
    foreign_keys={
        "MaHD": ("hoa_don", "MaHD"),
        "MaHH": ("hang_hoa", "MaHH"),
    },
    allow_create=False,
    path_parameter_descriptions={
        "record_id": (
            "Mã chi tiết hóa đơn được sinh từ mã hóa đơn và số thứ tự dòng hàng, "
            "ví dụ: HD20260001-01."
        )
    },
    path="/chi-tiet",
)

register_crud_routes(
    router,
    table="hoa_don",
    columns=("MaHD", "ThoiGian", "MaPK", "MaKH"),
    primary_keys=("MaHD",),
    required_columns=("MaHD", "MaPK"),
    search_columns=("MaHD", "MaPK", "MaKH", "ThoiGian"),
    search_value_placeholders={
        "MaHD": "HD20260001",
        "MaPK": "PK001",
        "MaKH": "KH001",
        "ThoiGian": "2026-11-05",
    },
    create_example={
        "MaHD": "HD20260001",
        "ThoiGian": "2026-11-05T10:30:00",
        "MaPK": "PK001",
        "MaKH": None,
    },
    update_example={"ThoiGian": "2026-11-06T09:30:00"},
    delete_procedure="sp_huy_hoa_don",
    foreign_keys={
        "MaPK": ("phan_cong_ca", "MaPK"),
        "MaKH": ("khach_hang", "MaKH"),
    },
    allow_create=False,
)
