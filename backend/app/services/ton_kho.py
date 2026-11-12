from fastapi import HTTPException
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession


async def lock_product(session: AsyncSession, code: str):
    result = await session.execute(
        text(
            "SELECT MaHH, Gia, SoLuongHangTonKho FROM hang_hoa "
            "WHERE MaHH = :code FOR UPDATE"
        ),
        {"code": code},
    )
    product = result.mappings().one_or_none()
    if product is None:
        raise HTTPException(422, f"Mã hàng {code} không tồn tại.")
    return product


async def finish_stock_change(
    session: AsyncSession, code: str, before: int, delta: int
) -> int:
    """Đối chiếu tồn sau khi INSERT, kể cả khi database đã cài trigger."""
    after = before + delta
    current = (await lock_product(session, code))["SoLuongHangTonKho"]
    if current == after:
        return after
    if current != before:
        raise HTTPException(409, f"Tồn kho hàng {code} thay đổi sai số lượng.")
    await session.execute(
        text("UPDATE hang_hoa SET SoLuongHangTonKho = :after WHERE MaHH = :code"),
        {"after": after, "code": code},
    )
    return after
