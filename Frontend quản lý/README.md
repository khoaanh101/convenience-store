# Frontend quản lý – Cửa hàng tiện lợi

## Cấu trúc

- `index.html` – Tổng quan (dashboard); `hang-hoa.html`, `nhan-vien.html`, `khach-hang.html`, `the-thanh-vien.html`, `bao-cao.html`
- `js/api.js` – địa chỉ API + hàm `api()`; `js/layout.js` – sidebar/header; `js/crud-page.js` – bảng + form thêm/sửa/xóa/tìm kiếm dùng chung
- Mỗi trang chỉ cần một file cấu hình ngắn (`js/hang-hoa.js`, …) khai báo cột và bảng.
- `js/bao-cao.js` – xem và xuất Excel báo cáo doanh thu, nhập hàng

## Chạy

1. Thiết lập MySQL và `.env` theo `backend/README.md`. CORS đã được cấu hình trong `backend/app/main.py`.
2. Từ thư mục gốc dự án, mở hai terminal:
   - Chạy backend: `uv run fastapi dev backend/app/main.py` (mặc định <http://127.0.0.1:8000> - đây là cổng API/Swagger, không phải giao diện frontend).
   - Chạy frontend tĩnh: `python -m http.server 5500 --directory "Frontend quản lý"` (hoặc chạy `python -m http.server 5500` bên trong thư mục `Frontend quản lý`).
3. Mở <http://127.0.0.1:5500/> để vào trang tổng quan (hoặc <http://127.0.0.1:5500/bao-cao.html> để mở thẳng báo cáo). Nút **API** trên header cho phép đổi địa chỉ Backend.

## Nghiệp vụ bán hàng và nhập kho

- **Lập hóa đơn** (`ban-hang.html`, `js/ban-hang.js`) lấy danh mục hàng hóa, khách hàng và phân công ca. Khi lưu, `POST /api/hoa-don` nhận `MaHD`, `MaPK`, `MaKH` (có thể là null) và `MatHang` gồm các cặp `MaHH`, `SoLuong`. Giá được lấy từ database lúc lưu; sau khi thanh toán, modal hiện chi tiết hóa đơn đã lưu và trang tự cập nhật lại số tồn.
- **Tra cứu hóa đơn & phiếu nhập** (`hoa-don.html`) lọc theo mã, ngày và khách hàng, mở chi tiết bằng modal. `GET /hoa-don/{record_id}/chi-tiet` trả thông tin hóa đơn, các dòng hàng với giá đã lưu và tổng tiền.
- **Nhập hàng** (`nhap-hang.html`) lưu một mặt hàng trên mỗi mã nhập theo schema. `POST /api/phieu-nhap` nhận `MaNH`, `MaHH`, `MaNCC`, `SoLuong`, `DonGia`, `NgayNhap` và trả mã nhập cùng tồn kho mới.
- **Ràng buộc dữ liệu:** Số lượng phải là số nguyên dương; giá bán và đơn giá nhập lớn hơn 0. Tìm hàng theo mã và tên dùng dữ liệu hiện có (tìm mã vạch sẽ dùng `MaVach` khi Backend bổ sung cột này).

Hai API ghi nghiệp vụ lưu chứng từ và tồn kho trong một giao dịch. Nếu trigger đã cập nhật đúng số lượng thì Backend giữ kết quả đó. Nếu tồn chưa đổi, Backend cập nhật trong cùng giao dịch. Nếu tồn đổi sai số lượng, giao dịch được hoàn tác.

### Kiểm tra trên MySQL thử nghiệm

Chuẩn bị hàng hóa tồn 10, một phân công ca và một nhà cung cấp. Dùng mã chứng từ mới cho mỗi lượt thành công.

| Thao tác | Kết quả mong đợi |
|---|---|
| Bán 3 | Mở chi tiết hóa đơn và thấy đúng giá đã lưu. Trang Hàng hóa sau khi tải lại hiển thị tồn 7. |
| Bán 8 khi còn 7 | Báo thiếu tồn. Tồn vẫn 7 và không tìm thấy mã hóa đơn vừa thử. |
| Nhập 5 | Tồn sau nhập là 12. Tải lại trang Hàng hóa để đối chiếu. |
| Tra cứu theo ngày và khách hàng | Tìm được hóa đơn đã lưu và mở đúng chi tiết. |
| Nhập số lượng 0 hoặc 1,5 | Form báo lỗi, chứng từ và tồn kho giữ nguyên. |

## Báo cáo

Chọn **Báo cáo** trên menu, đặt khoảng ngày rồi bấm **Xem báo cáo** hoặc **Xuất Excel** để tải tệp `.xlsx`. Hai báo cáo có sẵn:

- **Doanh thu bán hàng**: tổng hợp số hóa đơn, số lượng sản phẩm và doanh thu theo hóa đơn; người lập là quản lý cửa hàng, nơi nhận là chủ cửa hàng/ban quản lý.
- **Nhập hàng**: liệt kê phiếu nhập theo hàng hóa và nhà cung cấp, kèm số lượng, đơn giá, thành tiền; người lập là nhân viên phụ trách kho, nơi nhận là quản lý cửa hàng/kế toán.

API xem lần lượt tại `GET /bao-cao/doanh-thu` và `GET /bao-cao/nhap-hang`. Thêm `/xuat` để tải Excel, ví dụ `GET /bao-cao/doanh-thu/xuat?from_date=2026-11-01&to_date=2026-11-30`. Cả hai API nhận `from_date` và `to_date` theo định dạng `YYYY-MM-DD`; ngày bắt đầu phải không sau ngày kết thúc.