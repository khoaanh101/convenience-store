from fastapi import APIRouter

from app.services.crud import register_crud_routes

router = APIRouter(
    prefix="/hang-hoa",
    tags=["Hang hoa"]
)

register_crud_routes(
    router,
    table="hang_hoa",
    columns=("MaHH", "TenHang", "Loai", "Gia", "HSD", "SoLuongHangTonKho"),
    primary_keys=("MaHH",),
    required_columns=("MaHH", "TenHang", "Loai", "Gia"),
    search_columns=("MaHH", "TenHang", "Loai", "Gia", "HSD", "SoLuongHangTonKho"),
    search_value_placeholders={
        "MaHH": "HH001",
        "TenHang": "Nước suối 500ml",
        "Loai": "Đồ uống",
        "Gia": "10000",
        "HSD": "2027-12-31",
        "SoLuongHangTonKho": "100",
    },
    create_example={
        "MaHH": "HH001",
        "TenHang": "Nước suối 500ml",
        "Loai": "Đồ uống",
        "Gia": 10000,
        "HSD": "2027-12-31",
        "SoLuongHangTonKho": 100,
    },
    update_example={
        "TenHang": "Nước suối 1.5L",
        "Loai": "Đồ uống đóng chai",
        "Gia": 15000,
        "HSD": "2028-06-30",
        "SoLuongHangTonKho": 80,
    },
)
