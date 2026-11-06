from app.services.crud import register_crud_routes
from fastapi import APIRouter

router = APIRouter(
    prefix="/luong-nv",
    tags=["Luong nhan vien"]
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
