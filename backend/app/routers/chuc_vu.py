from app.services.crud import register_crud_routes
from fastapi import APIRouter

router = APIRouter(
    prefix="/chuc-vu",
    tags=["Chuc vu"]
)

register_crud_routes(
    router,
    table="chuc_vu",
    columns=("MaCV", "TenCV", "LuongCoBan"),
    primary_keys=("MaCV",),
    required_columns=("MaCV", "TenCV", "LuongCoBan"),
    search_columns=("MaCV", "TenCV", "LuongCoBan"),
    search_value_placeholders={
        "MaCV": "CV001",
        "TenCV": "Thu ngân",
        "LuongCoBan": "7000000",
    },
    create_example={"MaCV": "CV001", "TenCV": "Thu ngân", "LuongCoBan": 7000000},
    update_example={"TenCV": "Quản lý cửa hàng", "LuongCoBan": 10000000},
)
