from fastapi import APIRouter

from app.services.crud import register_crud_routes

router = APIRouter(
    prefix="/nha-cung-cap",
    tags=["Nha cung cap"]
)

register_crud_routes(
    router,
    table="nha_cung_cap",
    columns=("MaNCC", "TenNCC", "SDT", "DiaChi"),
    primary_keys=("MaNCC",),
    required_columns=("MaNCC", "TenNCC", "SDT", "DiaChi"),
    search_columns=("MaNCC", "TenNCC", "SDT", "DiaChi"),
    search_value_placeholders={
        "MaNCC": "NCC001",
        "TenNCC": "Công ty Thực phẩm ABC",
        "SDT": "0912345678",
        "DiaChi": "123 Đường Nguyễn Trãi",
    },
    create_example={
        "MaNCC": "NCC001",
        "TenNCC": "Công ty Thực phẩm ABC",
        "SDT": "0912345678",
        "DiaChi": "123 Đường Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh",
    },
    update_example={
        "TenNCC": "Công ty Phân phối XYZ",
        "SDT": "0987654321",
        "DiaChi": "456 Đường Lê Lợi, Quận 3, TP. Hồ Chí Minh",
    },
)
