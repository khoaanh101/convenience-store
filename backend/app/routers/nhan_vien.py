from fastapi import APIRouter

from app.services.crud import register_crud_routes

router = APIRouter(
    prefix="/nhan-vien",
    tags=["Nhan vien"]
)

register_crud_routes(
    router,
    table="nhan_vien",
    columns=("MaNV", "HoTen", "GioiTinh", "NgaySinh", "SDT", "MaCV"),
    primary_keys=("MaNV",),
    required_columns=("MaNV", "HoTen", "GioiTinh", "NgaySinh", "SDT", "MaCV"),
    search_columns=("MaNV", "HoTen", "GioiTinh", "NgaySinh", "SDT", "MaCV"),
    search_value_placeholders={
        "MaNV": "NV001",
        "HoTen": "Trần Thị Bình",
        "GioiTinh": "Nữ",
        "NgaySinh": "1998-06-15",
        "SDT": "0912345678",
        "MaCV": "CV001",
    },
    create_example={
        "MaNV": "NV001",
        "HoTen": "Trần Thị Bình",
        "GioiTinh": "Nữ",
        "NgaySinh": "1998-06-15",
        "SDT": "0912345678",
        "MaCV": "CV001",
    },
    update_example={
        "HoTen": "Nguyễn Thị Mai",
        "GioiTinh": "Nữ",
        "NgaySinh": "1995-08-20",
        "SDT": "0933333333",
    },
    foreign_keys={"MaCV": ("chuc_vu", "MaCV")},
)
