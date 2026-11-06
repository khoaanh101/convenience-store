from fastapi import FastAPI

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
