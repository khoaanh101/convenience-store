from fastapi import APIRouter

from app.services.crud import register_crud_routes

router = APIRouter(
    prefix="/nhap-hang",
    tags=["Nhap hang"]
)

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
