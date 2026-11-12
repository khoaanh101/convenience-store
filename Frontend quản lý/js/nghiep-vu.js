function showStatus(message, kind = '') {
  const status = document.getElementById('status');
  status.textContent = message;
  status.className = ['flow-status', kind].filter(Boolean).join(' ');
}

function fillOptions(select, choices, placeholder) {
  select.replaceChildren(new Option(placeholder, ''));
  for (const [code, label] of choices) select.add(new Option(label, code));
}

function productPicker(products) {
  const query = document.getElementById('product-query');
  const select = document.getElementById('product');
  const render = () => {
    const selected = select.value;
    const term = query.value.trim().toLocaleLowerCase('vi');
    const matches = products.filter(product =>
      product.MaHH.toLocaleLowerCase('vi').includes(term) ||
      product.TenHang.toLocaleLowerCase('vi').includes(term) ||
      String(product.MaVach || '').toLocaleLowerCase('vi').includes(term)
    );
    fillOptions(select, matches.map(product => [
      product.MaHH,
      `${product.MaHH} · ${product.TenHang}`
    ]), matches.length ? 'Chọn mặt hàng' : 'Không tìm thấy mặt hàng');
    if (matches.some(product => product.MaHH === selected)) select.value = selected;
  };
  query.addEventListener('input', render);
  render();
}



document.addEventListener('invalid', event => {
  event.target.classList.add('invalid');
  showStatus(event.target.validationMessage, 'bad');
}, true);
document.addEventListener('input', event => event.target.classList.remove('invalid'));

async function showDocument(type, code) {
  let dialog = document.getElementById('document-modal');
  if (!dialog) {
    dialog = document.createElement('dialog');
    dialog.id = 'document-modal';
    dialog.setAttribute('aria-label', 'Chi tiết chứng từ');
    document.body.append(dialog);
  }
  dialog.innerHTML = '<h2>Chi tiết chứng từ</h2><div class="document-content">Đang tải…</div><form method="dialog" class="foot"><button class="btn">Đóng</button></form>';
  dialog.showModal();
  const content = dialog.querySelector('.document-content');
  try {
    let record, lines;
    if (type === 'sale') {
      record = await api('GET', '/hoa-don/' + encodeURIComponent(code) + '/chi-tiet');
      lines = record.MatHang;
    } else {
      record = await api('GET', '/nhap-hang/' + encodeURIComponent(code));
      lines = [{ MaHH: record.MaHH, SoLuong: record.SoLuong, Gia: record.DonGia,
        ThanhTien: Number(record.DonGia) * record.SoLuong }];
    }
    content.innerHTML = `<p><strong>${esc(code)}</strong> · ${esc(record.ThoiGian || record.NgayNhap)}</p>
      <p>${esc(record.HoTen || record.MaKH || record.MaNCC || 'Khách lẻ')}</p>
      <div class="tw"><table><thead><tr><th>Mặt hàng</th><th>Số lượng</th><th>Đơn giá</th><th>Thành tiền</th></tr></thead>
      <tbody>${lines.map(line => `<tr><td>${esc(line.TenHang || line.MaHH)}</td>
      <td>${esc(line.SoLuong)}</td><td>${money(line.Gia)}</td><td>${money(line.ThanhTien)}</td></tr>`).join('')}</tbody></table></div>
      <p><strong>Tổng tiền ${money(record.TongTien ?? lines.reduce((sum, line) => sum + Number(line.ThanhTien), 0))}</strong></p>`;
  } catch (error) {
    content.textContent = error.message;
  }
}
