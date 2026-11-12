from decimal import Decimal
from typing import Annotated

from app.database.connection import get_session
from app.services.crud import (
    execute_procedure_with_rows,
    execute_write,
    register_crud_routes,
)
from fastapi import APIRouter, Body, Depends
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(
    prefix="/khach-hang",
    tags=["khach-hang"]
)


class MembershipIssueRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    ma_the: str = Field(alias="MaThe", max_length=10)
    ma_kh: str = Field(alias="MaKH", max_length=10)
    gia_the: Decimal = Field(alias="GiaThe", ge=0)
    so_ngay: int = Field(alias="SoNgay", gt=0)


@router.get("/thanh-vien/con-hieu-luc")
async def list_active_memberships(
    session: Annotated[AsyncSession, Depends(get_session)],
):
    result = await session.execute(
        text(
            """
            SELECT MaThe, MaKH, HoTen, NgayMua, GiaThe, HSD, TrangThaiThe
            FROM v_the_thanh_vien_con_hieu_luc
            ORDER BY MaThe
            """
        )
    )
    return [dict(row) for row in result.mappings().all()]


@router.post("/cap-the")
async def issue_membership(
    payload: Annotated[
        MembershipIssueRequest,
        Body(
            json_schema_extra={
                "example": {
                    "MaThe": "THE001",
                    "MaKH": "KH001",
                    "GiaThe": 200000,
                    "SoNgay": 365,
                }
            }
        ),
    ],
    session: Annotated[AsyncSession, Depends(get_session)],
):
    await execute_write(
        session,
        "CALL `sp_cap_the`(:mathe, :makh, :giathe, :so_ngay)",
        {
            "mathe": payload.ma_the,
            "makh": payload.ma_kh,
            "giathe": payload.gia_the,
            "so_ngay": payload.so_ngay,
        },
        signal_status_code=409,
    )
    result = await session.execute(
        text(
            """
            SELECT MaThe, MaKH, NgayMua, GiaThe, HSD, TrangThaiThe
            FROM the_thanh_vien
            WHERE MaThe = :mathe
            """
        ),
        {"mathe": payload.ma_the},
    )
    return dict(result.mappings().one())


@router.post("/thanh-vien/cap-nhat-het-han")
async def update_expired_memberships(
    session: Annotated[AsyncSession, Depends(get_session)],
):
    rows = await execute_procedure_with_rows(
        session,
        "CALL `capnhat_the_het_han`()",
        {},
    )
    return {"so_the_da_cap_nhat": rows[0]["SoTheDaCapNhat"] if rows else 0}


register_crud_routes(
    router,
    table="the_thanh_vien",
    columns=("MaThe", "MaKH", "NgayMua", "GiaThe", "HSD", "TrangThaiThe"),
    primary_keys=("MaThe",),
    required_columns=("MaThe", "MaKH", "NgayMua", "GiaThe", "HSD", "TrangThaiThe"),
    search_columns=("MaThe", "MaKH", "NgayMua", "GiaThe", "HSD", "TrangThaiThe"),
    search_value_placeholders={
        "MaThe": "THE001",
        "MaKH": "KH001",
        "NgayMua": "2026-11-05",
        "GiaThe": "200000",
        "HSD": "2027-11-05",
        "TrangThaiThe": "HoatDong",
    },
    create_example={
        "MaThe": "THE001",
        "MaKH": "KH001",
        "NgayMua": "2026-11-05",
        "GiaThe": 200000,
        "HSD": "2027-11-05",
        "TrangThaiThe": "HoatDong",
    },
    update_example={"HSD": "2028-12-31", "TrangThaiThe": "HetHan"},
    foreign_keys={"MaKH": ("khach_hang", "MaKH")},
    check_constraint_detail=(
        "GiaThe phải lớn hơn hoặc bằng 0, HSD không được trước NgayMua và "
        "TrangThaiThe phải là HoatDong, HetHan hoặc DaHuy."
    ),
    business_conflict_detail=(
        "Mỗi khách hàng chỉ được có một thẻ thành viên còn hiệu lực."
    ),
    allow_create=False,
    path="/thanh-vien",
)

register_crud_routes(
    router,
    table="khach_hang",
    columns=("MaKH", "HoTen", "SDT"),
    primary_keys=("MaKH",),
    required_columns=("MaKH", "HoTen", "SDT"),
    search_columns=("MaKH", "HoTen", "SDT"),
    search_value_placeholders={
        "MaKH": "KH001",
        "HoTen": "Nguyễn Văn An",
        "SDT": "0912345678",
    },
    create_example={"MaKH": "KH001", "HoTen": "Nguyễn Văn An", "SDT": "0912345678"},
    update_example={"HoTen": "Nguyễn Văn Minh", "SDT": "0933333333"},
)
