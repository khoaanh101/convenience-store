(async function () {
  const form = document.getElementById('receive');
  const fields = document.getElementById('receive-fields');
  const now = new Date();
  form.elements.NgayNhap.value = new Date(now.getTime() - now.getTimezoneOffset() * 60000)
    .toISOString().slice(0, 10);

  showStatus('Đang tải hàng hóa và nhà cung cấp…');
  try {
    const [items, suppliers] = await Promise.all([
      api('GET', '/hang-hoa/'),
      api('GET', '/nha-cung-cap/')
    ]);
    productPicker(items);
    fillOptions(form.elements.MaNCC, suppliers.map(s => [s.MaNCC, `${s.MaNCC} · ${s.TenNCC}`]), 'Chọn nhà cung cấp');
    fields.disabled = false;
    showStatus(suppliers.length ? '' : 'Cần có nhà cung cấp để nhập hàng.');
  } catch (error) {
    showStatus(error.message, 'bad');
    return;
  }

  form.onsubmit = async event => {
    event.preventDefault();
    if (fields.disabled) return;
    const payload = Object.fromEntries(new FormData(form));
    payload.SoLuong = Number(payload.SoLuong);
    fields.disabled = true;
    showStatus('Đang lưu nhập hàng…');
    try {
      const saved = await api('POST', '/api/phieu-nhap', payload);
      form.elements.MaNH.value = '';
      form.elements.SoLuong.value = '';
      form.elements.DonGia.value = '';
      showStatus(`Đã lưu mã nhập ${saved.MaNH}. Tồn kho sau nhập: ${saved.TonKho}.`, 'ok');
    } catch (error) {
      showStatus(error.message, 'bad');
    } finally {
      fields.disabled = false;
    }
  };
})();
