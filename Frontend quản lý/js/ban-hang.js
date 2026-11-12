(async function () {
  const form = document.getElementById('sale');
  const fields = document.getElementById('sale-fields');
  const cart = document.getElementById('cart');
  const picker = document.getElementById('product');
  const lines = new Map();
  let products;

  showStatus('Đang tải hàng hóa, khách hàng và ca làm…');
  try {
    const [items, customers, shifts] = await Promise.all([
      api('GET', '/hang-hoa/'),
      api('GET', '/khach-hang/'),
      api('GET', '/phan-cong-ca/')
    ]);
    products = new Map(items.map(item => [item.MaHH, item]));
    productPicker(items);
    fillOptions(form.elements.MaKH, customers.map(c => [c.MaKH, `${c.MaKH} · ${c.HoTen}`]), 'Khách lẻ');
    fillOptions(form.elements.MaPK, shifts.map(s => [
      s.MaPK, `${s.MaPK} · ${s.MaNV} · ${dmy(s.NgayLam)}`
    ]), 'Chọn phân công ca');
    fields.disabled = false;
    showStatus(shifts.length ? '' : 'Cần có ít nhất một phân công ca để lập hóa đơn.');
  } catch (error) {
    showStatus(error.message, 'bad');
    return;
  }

  function updateTotals() {
    let total = 0;
    for (const [code, line] of lines) {
      const product = products.get(code);
      const amount = line.input.validity.valid ? Number(product.Gia) * line.input.valueAsNumber : 0;
      line.amount.textContent = money(amount);
      total += amount;
    }
    document.getElementById('total').textContent = money(total);
  }

  function renderEmptyCart() {
    if (!lines.size) cart.innerHTML = '<tr><td colspan="6" class="empty">Chưa có mặt hàng.</td></tr>';
  }
  renderEmptyCart();

  document.getElementById('add-product').onclick = () => {
    const product = products.get(picker.value);
    if (product && !(Number(product.Gia) > 0)) {
      showStatus('Giá bán phải lớn hơn 0.', 'bad');
      return;
    }
    if (!product || product.SoLuongHangTonKho < 1) {
      showStatus(product ? 'Mặt hàng đã hết tồn kho.' : 'Hãy chọn một mặt hàng.', 'bad');
      return;
    }
    const code = product.MaHH;
    const existing = lines.get(code);
    if (existing) {
      const next = (existing.input.valueAsNumber || 0) + 1;
      if (next > product.SoLuongHangTonKho) {
        showStatus(`${product.TenHang} chỉ còn ${product.SoLuongHangTonKho} sản phẩm.`, 'bad');
        return;
      }
      existing.input.value = next;
    } else {
      if (!lines.size) cart.replaceChildren();
      const row = cart.insertRow();
      row.innerHTML = `
        <td>${esc(code)} · ${esc(product.TenHang)}</td>
        <td>${esc(product.SoLuongHangTonKho)}</td><td>${money(product.Gia)}</td>
        <td><input class="cart-quantity" type="number" min="1" step="1"
                   max="${esc(product.SoLuongHangTonKho)}" value="1" required
                   aria-label="Số lượng ${esc(product.TenHang)}"></td>
        <td></td><td><button type="button" class="btn sm del">Bỏ</button></td>`;
      const input = row.querySelector('input');
      lines.set(code, { input, amount: row.cells[4] });
      input.oninput = updateTotals;
      row.querySelector('button').onclick = () => {
        lines.delete(code);
        row.remove();
        renderEmptyCart();
        updateTotals();
      };
    }
    showStatus('');
    updateTotals();
  };

  form.onsubmit = async event => {
    event.preventDefault();
    if (fields.disabled) return;
    if (!lines.size) {
      showStatus('Hóa đơn phải có ít nhất một mặt hàng.', 'bad');
      return;
    }
    const data = new FormData(form);
    const payload = {
      MaHD: data.get('MaHD').trim(),
      MaPK: data.get('MaPK'),
      MaKH: data.get('MaKH') || null,
      MatHang: Array.from(lines, ([MaHH, line]) => ({ MaHH, SoLuong: line.input.valueAsNumber }))
    };
    fields.disabled = true;
    showStatus('Đang lưu hóa đơn…');
    try {
      const saved = await api('POST', '/api/hoa-don', payload);
      lines.clear();
      cart.replaceChildren();
      renderEmptyCart();
      updateTotals();
      form.elements.MaHD.value = '';
      showStatus('Đã lưu hóa đơn ' + saved.MaHD + '.');
      try {
        const items = await api('GET', '/hang-hoa/');
        products = new Map(items.map(item => [item.MaHH, item]));
        fields.disabled = false;
      } catch (error) {
        showStatus('Đã lưu hóa đơn. Tải lại trang để cập nhật tồn kho.', 'bad');
      }
      await showDocument('sale', saved.MaHD);
    } catch (error) {
      showStatus(error.message, 'bad');
      fields.disabled = false;
    }
  };
})();
