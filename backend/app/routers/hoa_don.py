from app.services.crud import register_crud_routes
from fastapi import APIRouter

router = APIRouter(
    prefix="/hoa-don",
    tags=["Hoa don"]
)

register_crud_routes(
    router,
    table="chi_tiet_hoa_don",
    columns=("MaCTHD", "MaHD", "MaHH", "SoLuong", "Gia"),
    primary_keys=("MaCTHD",),
    required_columns=("MaCTHD", "MaHD", "MaHH", "SoLuong", "Gia"),
    search_columns=("MaCTHD", "MaHD", "MaHH", "SoLuong", "Gia", "ThanhTien"),
    search_value_placeholders={
        "MaCTHD": "CTHD001",
        "MaHD": "HD20260001",
        "MaHH": "HH001",
        "SoLuong": "2",
        "Gia": "10000",
        "ThanhTien": "20000",
    },
    create_example={
        "MaCTHD": "CTHD001",
        "MaHD": "HD20260001",
        "MaHH": "HH001",
        "SoLuong": 2,
        "Gia": 10000,
    },
    update_example={"SoLuong": 3, "Gia": 12000},
    foreign_keys={
        "MaHD": ("hoa_don", "MaHD"),
        "MaHH": ("hang_hoa", "MaHH"),
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
    foreign_keys={
        "MaPK": ("phan_cong_ca", "MaPK"),
        "MaKH": ("khach_hang", "MaKH"),
    },
)
