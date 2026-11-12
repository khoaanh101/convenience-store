(async function () {
  const form = document.getElementById('search');
  const button = form.querySelector('button');
  const results = document.getElementById('results');
  let customerNames;
  button.disabled = true;
  try {
    const customers = await api('GET', '/khach-hang/');
    customerNames = new Map(customers.map(c => [c.MaKH, c.HoTen]));
    fillOptions(form.elements.MaKH, customerNames, 'Tất cả khách hàng');
  } catch (error) {
    showStatus(error.message, 'bad');
    return;
  }

  async function loadDocuments() {
    const data = new FormData(form);
    const type = data.get('Loai');
    const code = data.get('MaHD').trim().toLowerCase();
    const date = data.get('Ngay');
    const customer = data.get('MaKH');
    button.disabled = true;
    results.replaceChildren();
    showStatus('Đang tải chứng từ…');
    try {
      const rows = await api('GET', type === 'sale' ? '/hoa-don/' : '/nhap-hang/');
      const documents = rows.map(row => ({
        code: row.MaHD || row.MaNH,
        date: row.ThoiGian || row.NgayNhap,
        party: customerNames.get(row.MaKH) || row.MaKH || row.MaNCC || 'Khách lẻ',
        customer: row.MaKH
      })).filter(row => row.code.toLowerCase().includes(code) &&
        (!date || String(row.date).slice(0, 10) === date) &&
        (type !== 'sale' || !customer || row.customer === customer))
        .sort((a, b) => String(b.date).localeCompare(String(a.date)));
      results.innerHTML = documents.length ? `<table>
        <thead><tr><th>Mã chứng từ</th><th>Ngày tạo</th><th>Khách hàng / Nhà cung cấp</th></tr></thead>
        <tbody>${documents.map(row => `<tr>
          <td><button class="btn sm" data-code="${esc(row.code)}">${esc(row.code)}</button></td>
          <td>${esc(String(row.date).replace('T', ' '))}</td><td>${esc(row.party)}</td>
        </tr>`).join('')}</tbody></table>` : '<p class="empty">Không tìm thấy chứng từ phù hợp.</p>';
      results.querySelectorAll('[data-code]').forEach(item => {
        item.onclick = () => showDocument(type, item.dataset.code);
      });
      showStatus('');
    } catch (error) {
      showStatus(error.message, 'bad');
    } finally {
      button.disabled = false;
    }
  }

  form.elements.Loai.onchange = () => {
    form.elements.MaKH.disabled = form.elements.Loai.value === 'receipt';
  };
  form.onsubmit = event => {
    event.preventDefault();
    if (!button.disabled) loadDocuments();
  };
  await loadDocuments();
  const code = new URLSearchParams(location.search).get('id');
  if (code) await showDocument('sale', code);
})();
