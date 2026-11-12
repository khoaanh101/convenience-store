# Frontend quản lý – Cửa hàng tiện lợi

## Cấu trúc

- `index.html` – Tổng quan (dashboard); `hang-hoa.html`, `nhan-vien.html`, `khach-hang.html`, `the-thanh-vien.html`, `bao-cao.html`
- `js/api.js` – địa chỉ API + hàm `api()`; `js/layout.js` – sidebar/header; `js/crud-page.js` – bảng + form thêm/sửa/xóa/tìm kiếm dùng chung
- Mỗi trang chỉ cần một file cấu hình ngắn (`js/hang-hoa.js`, …) khai báo cột và bảng.
- `js/bao-cao.js` – xem và xuất Excel báo cáo doanh thu, nhập hàng

## Chạy

Từ thư mục gốc dự án, mở hai terminal:

1. Chạy backend: `uv run fastapi dev backend/app/main.py` (mặc định <http://127.0.0.1:8000>). CORS đã được bật trong `backend/app/main.py`.
2. Chạy frontend tĩnh: `python -m http.server 5500 --directory "Frontend quản lý"`.

Mở <http://127.0.0.1:5500/> để vào trang tổng quan, hoặc <http://127.0.0.1:5500/bao-cao.html> để mở thẳng báo cáo. Cổng `8000` là backend API/Swagger, không phải giao diện frontend.

## Báo cáo

Chọn **Báo cáo** trên menu, đặt khoảng ngày rồi bấm **Xem báo cáo** hoặc **Xuất Excel** để tải tệp `.xlsx`. Hai báo cáo có sẵn:

- **Doanh thu bán hàng**: tổng hợp số hóa đơn, số lượng sản phẩm và doanh thu theo hóa đơn; người lập là quản lý cửa hàng, nơi nhận là chủ cửa hàng/ban quản lý.
- **Nhập hàng**: liệt kê phiếu nhập theo hàng hóa và nhà cung cấp, kèm số lượng, đơn giá, thành tiền; người lập là nhân viên phụ trách kho, nơi nhận là quản lý cửa hàng/kế toán.

API xem lần lượt tại `GET /bao-cao/doanh-thu` và `GET /bao-cao/nhap-hang`. Thêm `/xuat` để tải Excel, ví dụ `GET /bao-cao/doanh-thu/xuat?from_date=2026-11-01&to_date=2026-11-30`. Cả hai API nhận `from_date` và `to_date` theo định dạng `YYYY-MM-DD`; ngày bắt đầu phải không sau ngày kết thúc.
