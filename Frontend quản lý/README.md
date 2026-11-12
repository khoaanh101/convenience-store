# Frontend quản lý – Cửa hàng tiện lợi

## Cấu trúc
- `index.html` – Tổng quan (dashboard); `hang-hoa.html`, `nhan-vien.html`, `khach-hang.html`, `the-thanh-vien.html`
- `js/api.js` – địa chỉ API + hàm `api()`; `js/layout.js` – sidebar/header; `js/crud-page.js` – bảng + form thêm/sửa/xóa/tìm kiếm dùng chung
- Mỗi trang chỉ cần một file cấu hình ngắn (`js/hang-hoa.js`, …) khai báo cột và bảng.

## Chạy

1. Thiết lập MySQL và `.env` theo `backend/README.md`. CORS đã được cấu hình trong `backend/app/main.py`.
2. Từ gốc repo, chạy `uv run fastapi dev backend/app/main.py` (mặc định http://127.0.0.1:8000).
3. Trong thư mục Frontend, chạy `python -m http.server 5500` rồi mở http://127.0.0.1:5500. Nút API trên header cho phép đổi địa chỉ Backend.

## Nghiệp vụ bán hàng và nhập kho

- **Lập hóa đơn** lấy danh mục hàng hóa, khách hàng và phân công ca. Khi lưu, `POST /api/hoa-don` nhận `MaHD`, `MaPK`, `MaKH` (có thể là null) và `MatHang` gồm các cặp `MaHH`, `SoLuong`. Giá được lấy từ database lúc lưu.
- **Tra cứu hóa đơn** lọc theo mã, ngày và khách hàng. `GET /hoa-don/{record_id}/chi-tiet` trả thông tin hóa đơn, các dòng hàng với giá đã lưu và tổng tiền.
- **Nhập hàng** lưu một mặt hàng trên mỗi mã nhập theo schema. `POST /api/phieu-nhap` nhận `MaNH`, `MaHH`, `MaNCC`, `SoLuong`, `DonGia`, `NgayNhap` và trả mã nhập cùng tồn kho mới.

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

## Bản giao diện theo lộ trình bốn giai đoạn

- Điểm vào bán hàng là `ban-hang.html` và `js/ban-hang.js`. Sau khi thanh toán, modal hiện chi tiết hóa đơn đã lưu.
- `hoa-don.html` tra cứu cả hóa đơn và phiếu nhập theo mã, ngày và mở chi tiết bằng modal.
- Số lượng là số nguyên dương, giá bán và đơn giá nhập phải lớn hơn 0.
- Tìm hàng theo mã và tên dùng dữ liệu hiện có. Tìm mã vạch sẽ dùng `MaVach` nếu Backend cung cấp. Schema hiện tại chưa có cột này.
- Chép cả phần Backend trong gói vì hai endpoint POST `/api/hoa-don` và `/api/phieu-nhap` mới được khai báo tại `backend/app/main.py`.
- Sau khi lưu thành công, tải lại trang Hàng hóa để đọc tồn kho từ API. Trang bán hàng tự tải lại số tồn cho lượt bán tiếp theo.
- Gói đã kiểm tra cú pháp và endpoint với phiên database SQLite thử nghiệm thay cho driver MySQL. Kiểm thử trình duyệt đầu cuối và kiểm thử đồng thời trên MySQL thật cần thực hiện cùng thành viên 2.

## Ghép vào nhánh

Giải nén vào gốc repo trên nhánh `feature/frontend-sales-inventory`, kiểm tra diff của các file trùng tên trước khi commit. Nếu đã dùng bản trước, có thể xóa `lap-hoa-don.html` và `js/lap-hoa-don.js` vì điểm vào hiện tại là `ban-hang.html`.
