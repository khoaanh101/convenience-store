from typing import Annotated

from app.database.connection import get_session
from app.services.crud import execute_procedure_with_rows, register_crud_routes
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(
    prefix="/luong-nv",
    tags=["Luong nhan vien"]
)


@router.get("/tinh-luong")
async def calculate_payroll(
    thang: Annotated[int, Query(ge=1, le=12)],
    nam: Annotated[int, Query(ge=1)],
    session: Annotated[AsyncSession, Depends(get_session)],
):
    return await execute_procedure_with_rows(
        session,
        "CALL `tinh_luong`(:thang, :nam)",
        {"thang": thang, "nam": nam},
    )


register_crud_routes(
    router,
    table="luong_nv",
    columns=("MaNV", "Thang", "Nam", "Thuong"),
    primary_keys=("MaNV", "Thang", "Nam"),
    required_columns=("MaNV", "Thang", "Nam"),
    search_columns=("MaNV", "Thang", "Nam", "Thuong"),
    search_value_placeholders={
        "MaNV": "NV001",
        "Thang": "11",
        "Nam": "2026",
        "Thuong": "500000",
    },
    create_example={"MaNV": "NV001", "Thang": 11, "Nam": 2026, "Thuong": 500000},
    update_example={"Thuong": 750000},
    foreign_keys={"MaNV": ("nhan_vien", "MaNV")},
)
