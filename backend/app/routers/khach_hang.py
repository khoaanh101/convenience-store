from app.services.crud import register_crud_routes
from fastapi import APIRouter

router = APIRouter(
    prefix="/khach-hang",
    tags=["khach-hang"]
)

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
