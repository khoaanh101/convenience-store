import io
from datetime import date, datetime
from decimal import Decimal
from typing import Any

from app.database.connection import get_session
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import Response
from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(prefix="/bao-cao", tags=["Bao cao"])
REPORT_HEADERS = {
    "MaHD": "Mã hóa đơn",
    "ThoiGian": "Thời gian",
    "KhachHang": "Khách hàng",
    "NhanVien": "Nhân viên",
    "SoLuong": "Số lượng",
    "TongTien": "Tổng tiền",
    "MaNH": "Mã phiếu nhập",
    "NgayNhap": "Ngày nhập",
    "TenNCC": "Nhà cung cấp",
    "MaHH": "Mã hàng",
    "TenHang": "Tên hàng",
    "DonGia": "Đơn giá",
    "ThanhTien": "Thành tiền",
    "Loai": "Loại",
    "TonKho": "Tồn kho",
    "HSD": "Hạn sử dụng",
    "TinhTrang": "Tình trạng",
    "NCCGanNhat": "NCC gần nhất",
}


async def validate_period(from_date: date, to_date: date) -> None:
    if from_date > to_date:
        raise HTTPException(
            status_code=422,
            detail="Ngày bắt đầu không được sau ngày kết thúc.",
        )


def report_xlsx(
    *,
    title: str,
    from_date: date | None = None,
    to_date: date | None = None,
    period: str | None = None,
    author: str,
    recipient: str,
    columns: tuple[str, ...],
    rows: list[dict[str, Any]],
    totals: tuple[Any, ...],
) -> bytes:
    workbook = Workbook()
    sheet = workbook.active
    sheet.title = "Báo cáo"
    last_column = get_column_letter(len(columns))

    sheet.merge_cells(start_row=1, start_column=1, end_row=1, end_column=len(columns))
    title_cell = sheet.cell(row=1, column=1, value=title)
    title_cell.font = Font(name="Aptos Display", size=16, bold=True, color="FFFFFF")
    title_cell.fill = PatternFill("solid", fgColor="14342B")
    title_cell.alignment = Alignment(horizontal="center")
    sheet.row_dimensions[1].height = 30

    metadata = (
        ("Kỳ báo cáo", period or f"{from_date.isoformat()} - {to_date.isoformat()}"),
        ("Người lập", author),
        ("Nơi nhận", recipient),
        ("Ngày xuất", datetime.now().astimezone().isoformat(timespec="seconds")),
    )
    for row_number, (label, value) in enumerate(metadata, start=2):
        sheet.cell(row=row_number, column=1, value=label).font = Font(bold=True)
        sheet.cell(row=row_number, column=2, value=value)

    header_row = len(metadata) + 3
    for column_number, column in enumerate(columns, start=1):
        cell = sheet.cell(
            row=header_row,
            column=column_number,
            value=REPORT_HEADERS.get(column, column),
        )
        cell.font = Font(bold=True, color="FFFFFF")
        cell.fill = PatternFill("solid", fgColor="1D4A3D")
        cell.alignment = Alignment(horizontal="center")

    for row_number, row in enumerate(rows, start=header_row + 1):
        for column_number, column in enumerate(columns, start=1):
            value = row.get(column)
            if isinstance(value, str) and value.lstrip().startswith(("=", "+", "-", "@")):
                value = "'" + value
            cell = sheet.cell(row=row_number, column=column_number, value=value)
            if column in {"TongTien", "DonGia", "ThanhTien"}:
                cell.number_format = '#,##0.00 "₫"'
            elif column == "HSD":
                cell.number_format = "DD/MM/YYYY"

    total_row = header_row + len(rows) + 1
    for column_number, value in enumerate(totals, start=1):
        cell = sheet.cell(row=total_row, column=column_number, value=value)
        cell.font = Font(bold=True)
        cell.fill = PatternFill("solid", fgColor="F2B632")
        if columns[column_number - 1] in {"TongTien", "DonGia", "ThanhTien"}:
            cell.number_format = '#,##0.00 "₫"'

    if rows:
        sheet.auto_filter.ref = f"A{header_row}:{last_column}{header_row + len(rows)}"
    sheet.freeze_panes = f"A{header_row + 1}"
    sheet.sheet_view.showGridLines = False
    sheet.page_setup.orientation = "landscape"
    sheet.page_setup.fitToWidth = 1
    sheet.sheet_properties.pageSetUpPr.fitToPage = True

    for column_number, column in enumerate(columns, start=1):
        values = [REPORT_HEADERS.get(column, column)]
        values.extend(str(row.get(column) or "") for row in rows)
        width = min(max(max(map(len, values)) + 2, 12), 40)
        sheet.column_dimensions[get_column_letter(column_number)].width = width
    sheet.column_dimensions["A"].width = max(sheet.column_dimensions["A"].width, 24)

    output = io.BytesIO()
    workbook.save(output)
    return output.getvalue()


def xlsx_response(content: bytes, filename: str) -> Response:
    return Response(
        content=content,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.get("/doanh-thu")
async def doanh_thu(
    from_date: date = Query(..., description="Ngày bắt đầu (YYYY-MM-DD)"),
    to_date: date = Query(..., description="Ngày kết thúc (YYYY-MM-DD)"),
    session: AsyncSession = Depends(get_session),
):
    await validate_period(from_date, to_date)
    result = await session.execute(
        text(
            """
            SELECT hd.MaHD, hd.ThoiGian,
                   COALESCE(kh.HoTen, 'Khách lẻ') AS KhachHang,
                   nv.HoTen AS NhanVien,
                   COALESCE(ct.SoLuong, 0) AS SoLuong,
                   COALESCE(ct.TongTien, 0) AS TongTien
            FROM hoa_don AS hd
            JOIN phan_cong_ca AS pc ON pc.MaPK = hd.MaPK
            JOIN nhan_vien AS nv ON nv.MaNV = pc.MaNV
            LEFT JOIN khach_hang AS kh ON kh.MaKH = hd.MaKH
            LEFT JOIN (
                SELECT MaHD, SUM(SoLuong) AS SoLuong, SUM(ThanhTien) AS TongTien
                FROM chi_tiet_hoa_don
                GROUP BY MaHD
            ) AS ct ON ct.MaHD = hd.MaHD
            WHERE hd.ThoiGian >= :from_date
              AND hd.ThoiGian < DATE_ADD(:to_date, INTERVAL 1 DAY)
            ORDER BY hd.ThoiGian, hd.MaHD
            """
        ),
        {"from_date": from_date, "to_date": to_date},
    )
    rows = [dict(row) for row in result.mappings().all()]
    return {
        "from_date": from_date,
        "to_date": to_date,
        "summary": {
            "so_hoa_don": len(rows),
            "tong_so_luong": sum(int(row["SoLuong"]) for row in rows),
            "tong_doanh_thu": sum(
                (Decimal(str(row["TongTien"])) for row in rows), Decimal("0")
            ),
        },
        "rows": rows,
    }


@router.get("/doanh-thu/xuat")
async def xuat_doanh_thu(
    from_date: date = Query(..., description="Ngày bắt đầu (YYYY-MM-DD)"),
    to_date: date = Query(..., description="Ngày kết thúc (YYYY-MM-DD)"),
    session: AsyncSession = Depends(get_session),
):
    report = await doanh_thu(from_date, to_date, session)
    content = report_xlsx(
        title="BÁO CÁO DOANH THU BÁN HÀNG",
        from_date=from_date,
        to_date=to_date,
        author="Quản lý cửa hàng",
        recipient="Chủ cửa hàng/ban quản lý",
        columns=("MaHD", "ThoiGian", "KhachHang", "NhanVien", "SoLuong", "TongTien"),
        rows=report["rows"],
        totals=(
            f"TỔNG CỘNG ({report['summary']['so_hoa_don']} hóa đơn)",
            "",
            "",
            "",
            report["summary"]["tong_so_luong"],
            report["summary"]["tong_doanh_thu"],
        ),
    )
    return xlsx_response(content, "bao-cao-doanh-thu.xlsx")


@router.get("/nhap-hang")
async def nhap_hang(
    from_date: date = Query(..., description="Ngày bắt đầu (YYYY-MM-DD)"),
    to_date: date = Query(..., description="Ngày kết thúc (YYYY-MM-DD)"),
    session: AsyncSession = Depends(get_session),
):
    await validate_period(from_date, to_date)
    result = await session.execute(
        text(
            """
            SELECT nh.MaNH, nh.NgayNhap, ncc.TenNCC, hh.MaHH, hh.TenHang,
                   nh.SoLuong, nh.DonGia, nh.SoLuong * nh.DonGia AS ThanhTien
            FROM nhap_hang AS nh
            JOIN nha_cung_cap AS ncc ON ncc.MaNCC = nh.MaNCC
            JOIN hang_hoa AS hh ON hh.MaHH = nh.MaHH
            WHERE nh.NgayNhap >= :from_date AND nh.NgayNhap <= :to_date
            ORDER BY nh.NgayNhap, nh.MaNH
            """
        ),
        {"from_date": from_date, "to_date": to_date},
    )
    rows = [dict(row) for row in result.mappings().all()]
    return {
        "from_date": from_date,
        "to_date": to_date,
        "summary": {
            "so_phieu_nhap": len(rows),
            "tong_so_luong": sum(int(row["SoLuong"]) for row in rows),
            "tong_chi_phi": sum(
                (Decimal(str(row["ThanhTien"])) for row in rows), Decimal("0")
            ),
        },
        "rows": rows,
    }


@router.get("/nhap-hang/xuat")
async def xuat_nhap_hang(
    from_date: date = Query(..., description="Ngày bắt đầu (YYYY-MM-DD)"),
    to_date: date = Query(..., description="Ngày kết thúc (YYYY-MM-DD)"),
    session: AsyncSession = Depends(get_session),
):
    report = await nhap_hang(from_date, to_date, session)
    content = report_xlsx(
        title="BÁO CÁO NHẬP HÀNG",
        from_date=from_date,
        to_date=to_date,
        author="Nhân viên phụ trách kho",
        recipient="Quản lý cửa hàng/kế toán",
        columns=(
            "MaNH",
            "NgayNhap",
            "TenNCC",
            "MaHH",
            "TenHang",
            "SoLuong",
            "DonGia",
            "ThanhTien",
        ),
        rows=report["rows"],
        totals=(
            f"TỔNG CỘNG ({report['summary']['so_phieu_nhap']} phiếu)",
            "",
            "",
            "",
            "",
            report["summary"]["tong_so_luong"],
            "",
            report["summary"]["tong_chi_phi"],
        ),
    )
    return xlsx_response(content, "bao-cao-nhap-hang.xlsx")


# ---------------------------------------------------------------------------
# Báo cáo hàng tồn kho thấp / sắp hết hạn (Người 5)
# Người lập: nhân viên kho -> người nhận: quản lý / bộ phận nhập hàng.
# Thứ tự nhãn theo truy vấn 2.1 của Người 1: Đã hết hạn > Sắp hết hạn > Hết hàng > Tồn thấp.
# ---------------------------------------------------------------------------
TON_KHO_SQL = """
    SELECT hh.MaHH,
           hh.TenHang,
           hh.Loai,
           hh.SoLuongHangTonKho AS TonKho,
           hh.HSD,
           CASE
               WHEN hh.HSD IS NOT NULL AND hh.HSD < CURDATE()                               THEN 'Đã hết hạn'
               WHEN hh.HSD IS NOT NULL AND hh.HSD <= DATE_ADD(CURDATE(), INTERVAL :han DAY) THEN 'Sắp hết hạn'
               WHEN hh.SoLuongHangTonKho = 0                                                THEN 'Hết hàng'
               ELSE 'Tồn thấp'
           END AS TinhTrang,
           (SELECT ncc.TenNCC
              FROM nhap_hang nh
              JOIN nha_cung_cap ncc ON ncc.MaNCC = nh.MaNCC
             WHERE nh.MaHH = hh.MaHH
             ORDER BY nh.NgayNhap DESC, nh.MaNH DESC
             LIMIT 1) AS NCCGanNhat
    FROM hang_hoa AS hh
    WHERE hh.SoLuongHangTonKho <= :nguong
       OR (hh.HSD IS NOT NULL AND hh.HSD <= DATE_ADD(CURDATE(), INTERVAL :han DAY))
    ORDER BY hh.SoLuongHangTonKho ASC, hh.HSD ASC, hh.MaHH
"""


@router.get("/ton-kho")
async def ton_kho(
    nguong: int = Query(10, ge=0, description="Tồn kho từ mức này trở xuống bị coi là thấp"),
    han: int = Query(7, ge=0, description="Hàng hết hạn trong số ngày này (hoặc đã hết hạn) được đưa vào báo cáo"),
    session: AsyncSession = Depends(get_session),
):
    result = await session.execute(text(TON_KHO_SQL), {"nguong": nguong, "han": han})
    rows = [dict(row) for row in result.mappings().all()]
    count = lambda status: sum(1 for row in rows if row["TinhTrang"] == status)  # noqa: E731
    return {
        "nguong": nguong,
        "han": han,
        "ngay_lap": date.today(),
        "summary": {
            "so_mat_hang": len(rows),
            "da_het_han": count("Đã hết hạn"),
            "sap_het_han": count("Sắp hết hạn"),
            "het_hang": count("Hết hàng"),
            "ton_thap": count("Tồn thấp"),
        },
        "rows": rows,
    }


@router.get("/ton-kho/xuat")
async def xuat_ton_kho(
    nguong: int = Query(10, ge=0),
    han: int = Query(7, ge=0),
    session: AsyncSession = Depends(get_session),
):
    report = await ton_kho(nguong, han, session)
    today = date.today().strftime("%d/%m/%Y")
    content = report_xlsx(
        title="BÁO CÁO HÀNG TỒN KHO THẤP / SẮP HẾT HẠN",
        period=f"Tại ngày {today} (tồn kho từ {nguong} trở xuống hoặc hết hạn trong {han} ngày)",
        author="Nhân viên kho",
        recipient="Quản lý cửa hàng / bộ phận nhập hàng",
        columns=("MaHH", "TenHang", "Loai", "TonKho", "HSD", "TinhTrang", "NCCGanNhat"),
        rows=report["rows"],
        totals=(
            f"TỔNG CỘNG ({report['summary']['so_mat_hang']} mặt hàng)",
            "",
            "",
            sum(int(row["TonKho"]) for row in report["rows"]),
            "",
            "",
            "",
        ),
    )
    return xlsx_response(content, "bao-cao-ton-kho.xlsx")
