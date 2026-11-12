from datetime import date
from decimal import Decimal
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError, OperationalError
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.connection import get_session
from app.services.crud import register_crud_routes
from app.services.ton_kho import finish_stock_change, lock_product

router = APIRouter(prefix="/nhap-hang", tags=["Nhap hang"])


class PhieuNhap(BaseModel):
    MaNH: str = Field(pattern=r"^[A-Za-z0-9_-]{1,10}$")
    MaHH: str = Field(min_length=1, max_length=10)
    MaNCC: str = Field(min_length=1, max_length=10)
    SoLuong: int = Field(strict=True, gt=0, le=2147483647)
    DonGia: Decimal = Field(gt=0, max_digits=12, decimal_places=2)
    NgayNhap: date


@router.post("/tiep-nhan", status_code=201)
async def tiep_nhan(
    payload: PhieuNhap, session: Annotated[AsyncSession, Depends(get_session)]
):
    try:
        async with session.begin():
            product = await lock_product(session, payload.MaHH)
            code = product["MaHH"]
            before = product["SoLuongHangTonKho"]
            if before + payload.SoLuong > 2147483647:
                raise HTTPException(422, "Số lượng sau khi nhập vượt giới hạn tồn kho.")
            await session.execute(
                text(
                    "INSERT INTO nhap_hang (MaNH, MaHH, MaNCC, SoLuong, DonGia, NgayNhap) "
                    "VALUES (:MaNH, :MaHH, :MaNCC, :SoLuong, :DonGia, :NgayNhap)"
                ),
                {**payload.model_dump(), "MaHH": code},
            )
            after = await finish_stock_change(session, code, before, payload.SoLuong)
    except IntegrityError as exc:
        raise HTTPException(409, "Mã nhập hàng bị trùng hoặc mã nhà cung cấp không hợp lệ.") from exc
    except OperationalError as exc:
        if exc.orig.args[0:1] == (1644,):
            raise HTTPException(409, str(exc.orig.args[1])) from exc
        raise
    return {"MaNH": payload.MaNH, "TonKho": after}


register_crud_routes(
    router,
    table="nhap_hang",
    columns=("MaNH", "MaHH", "MaNCC", "SoLuong", "DonGia", "NgayNhap"),
    primary_keys=("MaNH",),
    required_columns=("MaNH", "MaHH", "MaNCC", "SoLuong", "DonGia", "NgayNhap"),
    search_columns=("MaNH", "MaHH", "MaNCC", "SoLuong", "DonGia", "NgayNhap"),
    search_value_placeholders={
        "MaNH": "NH001",
        "MaHH": "HH001",
        "MaNCC": "NCC001",
        "SoLuong": "50",
        "DonGia": "8000",
        "NgayNhap": "2026-11-05",
    },
    create_example={
        "MaNH": "NH001",
        "MaHH": "HH001",
        "MaNCC": "NCC001",
        "SoLuong": 50,
        "DonGia": 8000,
        "NgayNhap": "2026-11-05",
    },
    update_example={"SoLuong": 75, "DonGia": 8500, "NgayNhap": "2026-11-06"},
    foreign_keys={
        "MaHH": ("hang_hoa", "MaHH"),
        "MaNCC": ("nha_cung_cap", "MaNCC"),
    },
)
