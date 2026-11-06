from app.services.crud import register_crud_routes
from fastapi import APIRouter

router = APIRouter(
    prefix="/phan-cong-ca",
    tags=["Phan-cong-ca"]
)

register_crud_routes(
    router,
    table="ca_lam_viec",
    columns=("MaCLV", "GioBatDau", "GioKetThuc"),
    primary_keys=("MaCLV",),
    required_columns=("MaCLV", "GioBatDau", "GioKetThuc"),
    search_columns=("MaCLV", "GioBatDau", "GioKetThuc"),
    search_value_placeholders={
        "MaCLV": "CA001",
        "GioBatDau": "08:00:00",
        "GioKetThuc": "16:00:00",
    },
    create_example={
        "MaCLV": "CA001",
        "GioBatDau": "08:00:00",
        "GioKetThuc": "16:00:00",
    },
    update_example={"GioBatDau": "09:00:00", "GioKetThuc": "17:00:00"},
    time_columns=("GioBatDau", "GioKetThuc"),
    path="/ca-lam-viec",
)

register_crud_routes(
    router,
    table="phan_cong_ca",
    columns=("MaPK", "MaNV", "MaCLV", "NgayLam"),
    primary_keys=("MaPK",),
    required_columns=("MaPK", "MaNV", "MaCLV", "NgayLam"),
    search_columns=("MaPK", "MaNV", "MaCLV", "NgayLam"),
    search_value_placeholders={
        "MaPK": "PK001",
        "MaNV": "NV001",
        "MaCLV": "CA001",
        "NgayLam": "2026-11-05",
    },
    create_example={
        "MaPK": "PK001",
        "MaNV": "NV001",
        "MaCLV": "CA001",
        "NgayLam": "2026-11-05",
    },
    update_example={"MaNV": "NV002", "NgayLam": "2026-11-06"},
    foreign_keys={
        "MaNV": ("nhan_vien", "MaNV"),
        "MaCLV": ("ca_lam_viec", "MaCLV"),
    },
)
