from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import (
    chuc_vu,
    hang_hoa,
    hoa_don,
    khach_hang,
    luong_nv,
    nha_cung_cap,
    nhan_vien,
    nhap_hang,
    phan_cong_ca,
)

app = FastAPI(
    title="Cua hang tien loi API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

for router in (
    chuc_vu.router,
    hang_hoa.router,
    hoa_don.router,
    khach_hang.router,
    luong_nv.router,
    nha_cung_cap.router,
    nhan_vien.router,
    nhap_hang.router,
    phan_cong_ca.router,
):
    app.include_router(router)

@app.get("/")
async def root():
    return {
        "message": "Backend is running"
    }

# Endpoint giao tiếp với Frontend nghiệp vụ.
app.add_api_route("/api/hoa-don", hoa_don.ban_hang, methods=["POST"], status_code=201)
app.add_api_route("/api/phieu-nhap", nhap_hang.tiep_nhan, methods=["POST"], status_code=201)
