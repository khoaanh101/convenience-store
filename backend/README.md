# Backend API

Backend dùng FastAPI, SQLAlchemy async và MySQL. Cấu trúc database chuẩn nằm trong [`../schemas/schema-final.sql`](../schemas/schema-final.sql).

## Yêu cầu

- Python 3.12 trở lên
- MySQL Server đang chạy và có thể truy cập từ máy chạy backend
- Database được tạo theo `schemas/schema-final.sql`
- `uv` để đồng bộ dependencies (hoặc cài các package trong `pyproject.toml` bằng công cụ Python khác)

## Cấu hình database

Tạo file `.env` tại thư mục gốc dự án, dựa trên `.env.sample`:

```dotenv
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=cuahangtienloi
```

Thay các giá trị cho phù hợp với MySQL đang dùng. Không commit mật khẩu hoặc thông tin kết nối thật vào Git. Backend nạp cấu hình bằng `python-dotenv` và kết nối qua `mysql+asyncmy`.

## Cài đặt và chạy

Từ thư mục gốc dự án:

```powershell
uv sync
uv run fastapi dev backend/app/main.py
```

Server phát triển mặc định tại `http://127.0.0.1:8000`. Có thể mở:

- Swagger UI: `http://127.0.0.1:8000/docs`
- ReDoc: `http://127.0.0.1:8000/redoc`
- OpenAPI JSON: `http://127.0.0.1:8000/openapi.json`

Endpoint `GET /` trả về thông báo backend đang chạy. Cần khởi động lại server nếu tiến trình hiện tại không tự nạp thay đổi code.

## Các endpoint

Mỗi nhóm dữ liệu (resource) có các thao tác CRUD:

| Thao tác | Route | Ý nghĩa |
| --- | --- | --- |
| List | `GET /<resource>` | Trả về các bản ghi |
| Search | `GET /<resource>/search?column=<column>&value=<value>` | Tìm gần đúng theo cột được hỗ trợ |
| Create | `POST /<resource>` | Tạo bản ghi bằng JSON |
| Get | `GET /<resource>/<id>` | Lấy một bản ghi theo khóa |
| Update | `PUT /<resource>/<id>` | Cập nhật các trường gửi trong JSON |
| Delete | `DELETE /<resource>/<id>` | Xóa bản ghi theo khóa |

Các resource đã đăng ký:

| Resource / route collection | Bảng | Khóa chính |
| --- | --- | --- |
| `/chuc-vu` | `chuc_vu` | `MaCV` |
| `/hang-hoa` | `hang_hoa` | `MaHH` |
| `/khach-hang` | `khach_hang` | `MaKH` |
| `/khach-hang/thanh-vien` | `the_thanh_vien` | `MaThe` |
| `/luong-nv` | `luong_nv` | `MaNV`, `Thang`, `Nam` |
| `/nha-cung-cap` | `nha_cung_cap` | `MaNCC` |
| `/nhan-vien` | `nhan_vien` | `MaNV` |
| `/nhap-hang` | `nhap_hang` | `MaNH` |
| `/hoa-don` | `hoa_don` | `MaHD` |
| `/hoa-don/chi-tiet` | `chi_tiet_hoa_don` | `MaCTHD` |
| `/phan-cong-ca/ca-lam-viec` | `ca_lam_viec` | `MaCLV` |
| `/phan-cong-ca` | `phan_cong_ca` | `MaPK` |

Với bảng có khóa chính tổng hợp, endpoint bản ghi có dạng `/key/<key1>/<key2>/...`. Ví dụ:

```text
GET    /luong-nv/key/NV001/11/2026
PUT    /luong-nv/key/NV001/11/2026
DELETE /luong-nv/key/NV001/11/2026
```

Các trường có thể tìm kiếm và ví dụ cho request body được khai báo trong từng router và hiển thị trên Swagger UI.

## Quy trình kiểm thử trên Swagger

Mở `http://127.0.0.1:8000/docs`, chọn API cần kiểm thử và dùng `Try it out`. Với mỗi resource, thực hiện theo thứ tự:

1. `GET` danh sách để xem dữ liệu hiện có.
2. `POST` tạo một bản ghi thử nghiệm.
3. `GET` theo khóa chính để xác nhận bản ghi vừa tạo.
4. `GET /search` để tìm bản ghi theo một cột và giá trị.
5. `PUT` cập nhật một hoặc nhiều trường.
6. Gọi lại `GET` theo khóa chính để xác nhận thay đổi.
7. Khi dọn dữ liệu thử nghiệm, gọi `DELETE`, sau đó `GET` theo khóa để xác nhận API trả `404`.

Thực hiện lần lượt theo nhóm và quan hệ dữ liệu:

1. Chức vụ (`/chuc-vu`).
2. Hàng hóa (`/hang-hoa`).
3. Khách hàng (`/khach-hang`), sau đó thẻ thành viên (`/khach-hang/thanh-vien`).
4. Nhân viên (`/nhan-vien`), sau đó lương nhân viên (`/luong-nv`).
5. Nhà cung cấp (`/nha-cung-cap`), sau đó nhập hàng (`/nhap-hang`).
6. Ca làm việc (`/phan-cong-ca/ca-lam-viec`), sau đó phân công ca (`/phan-cong-ca`).
7. Hóa đơn (`/hoa-don`), sau đó chi tiết hóa đơn (`/hoa-don/chi-tiet`).

Thứ tự này bảo đảm các bản ghi cha cần thiết đã tồn tại trước khi tạo bản ghi có khóa ngoại. Với hóa đơn, `MaPK` bắt buộc phải tham chiếu một phân công ca tồn tại; `MaKH` có thể để `null`. Với chi tiết hóa đơn, cần có cả hóa đơn và hàng hóa tương ứng. Dùng mã thử nghiệm riêng để tránh xung đột khóa chính hoặc dữ liệu đang có; đặc biệt, một khách hàng không được có nhiều thẻ thành viên còn hiệu lực.

Khi xóa dữ liệu thử nghiệm, xóa theo thứ tự ngược với quan hệ phụ thuộc: chi tiết hóa đơn trước hóa đơn, hóa đơn trước phân công ca; nhập hàng trước hàng hóa/nhà cung cấp; lương và phân công ca trước nhân viên; phân công ca trước ca làm việc; thẻ thành viên trước khách hàng; nhân viên trước chức vụ. Một số liên kết dùng `CASCADE`, nhưng nên kiểm tra phản hồi API và không dựa vào xóa dây chuyền để dọn dữ liệu nếu chưa chủ ý.

### Ví dụ tìm kiếm

```http
GET /hang-hoa/search?column=TenHang&value=nuoc
```

`column` phải là một trong các cột tìm kiếm của resource. `value` được tìm theo chuỗi con; API chuyển giá trị cột sang chuỗi để tìm kiếm, nên cả cột số/ngày cũng có thể được tìm.

### Ví dụ tạo và cập nhật

`POST` gửi các trường cần thiết theo JSON mẫu trong Swagger:

```http
POST /khach-hang
Content-Type: application/json

{
  "MaKH": "KH001",
  "HoTen": "Nguyễn Văn An",
  "SDT": "0987654321"
}
```

`PUT` nhận JSON chỉ gồm các trường muốn cập nhật. Khóa chính nằm trên URL và không được cập nhật.

## Khóa ngoại và thao tác xóa

Backend kiểm tra một số khóa ngoại trước khi tạo/cập nhật. MySQL vẫn là nơi thực thi ràng buộc cuối cùng. `DELETE` chỉ xóa bản ghi của resource được gọi; backend không gọi chuỗi API xóa khác. Tác động đến bảng liên quan do các khóa ngoại trong schema quyết định:

| Bản ghi cha bị xóa | Hành vi với bản ghi liên quan |
| --- | --- |
| Hóa đơn | Không xóa được khi còn chi tiết hóa đơn (`RESTRICT`); xóa chi tiết trước |
| Khách hàng | Thẻ thành viên ngăn xóa (`RESTRICT`); hóa đơn vẫn giữ và `MaKH` thành `NULL` (`SET NULL`) |
| Phân công ca | Không xóa được khi có hóa đơn tham chiếu (`RESTRICT`) |
| Ca làm việc | Không xóa được khi còn phân công ca tham chiếu (`RESTRICT`) |
| Nhân viên | Lương và phân công ca bị xóa theo (`CASCADE`); phân công đang được hóa đơn dùng có thể làm lệnh xóa bị từ chối |
| Hàng hóa | Không xóa được khi còn chi tiết hóa đơn hoặc phiếu nhập tham chiếu (`RESTRICT`) |
| Nhà cung cấp | Không xóa được khi còn phiếu nhập tham chiếu (`RESTRICT`) |
| Chức vụ | Không xóa được khi còn nhân viên thuộc chức vụ đó (`RESTRICT`) |

Quy tắc đầy đủ nằm trong các khai báo `FOREIGN KEY` của `schemas/schema-final.sql`.

## Xử lý lỗi

| HTTP status | Ý nghĩa thường gặp |
| --- | --- |
| `400 Bad Request` | Body rỗng, có cột không hợp lệ hoặc cố cập nhật khóa chính |
| `404 Not Found` | Không tìm thấy bản ghi theo khóa |
| `409 Conflict` | Khóa/ràng buộc bị xung đột; ví dụ xóa bản ghi còn được tham chiếu |
| `422 Unprocessable Entity` | Thiếu trường bắt buộc, sai định dạng, khóa ngoại không tồn tại hoặc vi phạm điều kiện dữ liệu |
| `500 Internal Server Error` | Lỗi máy chủ hoặc database chưa được xử lý thành lỗi đầu vào/xung đột |

Một số quy tắc đặc biệt được chuyển thành lỗi cụ thể. Ví dụ, mỗi khách hàng chỉ được có một thẻ thành viên còn hiệu lực; API tạo/cập nhật thẻ trả `409` nếu vi phạm quy tắc này.

## Cấu trúc mã nguồn

```text
backend/app/
  main.py                 # Khởi tạo FastAPI và đăng ký routers
  database/connection.py  # Đọc .env, tạo async engine và session
  routers/                # Định nghĩa prefix, bảng, khóa và ví dụ API
  services/crud.py        # Đăng ký các thao tác CRUD dùng chung
```

`register_crud_routes` tạo các endpoint cho từng bảng. Khai báo cột, trường bắt buộc, khóa, khóa ngoại và ví dụ request được đặt tại router tương ứng.
