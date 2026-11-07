# Frontend quản lý – Cửa hàng tiện lợi

HTML + CSS + JavaScript thuần, gọi API FastAPI của thành viên 2.

## Cấu trúc
- `index.html` – Tổng quan (dashboard); `hang-hoa.html`, `nhan-vien.html`, `khach-hang.html`, `the-thanh-vien.html`
- `js/api.js` – địa chỉ API + hàm `api()`; `js/layout.js` – sidebar/header; `js/crud-page.js` – bảng + form thêm/sửa/xóa/tìm kiếm dùng chung
- Mỗi trang chỉ cần một file cấu hình ngắn (`js/hang-hoa.js`, …) khai báo cột và bảng.

## Chạy
1. Bật CORS cho backend (`backend/app/main.py`), thêm sau `app = FastAPI(...)`:
```python
from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])
```
2. Chạy backend: `uv run fastapi dev backend/app/main.py` (mặc định http://127.0.0.1:8000).
3. Trong thư mục này: `python -m http.server 5500`, mở http://127.0.0.1:5500.
4. API ở địa chỉ khác: bấm chip “API” trên header để đổi.

Lưu ý: list/tạo mới dùng đường dẫn có dấu `/` cuối (`/hang-hoa/`) để tránh redirect 307 làm hỏng POST khi gọi chéo origin.
