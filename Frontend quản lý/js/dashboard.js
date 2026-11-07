(async function () {
  const app = document.getElementById('app');
  app.innerHTML = '<div class="empty">Đang tải số liệu…</div>';
  try {
    const [hh, nv, kh, the] = await Promise.all([api('GET', '/hang-hoa/'), api('GET', '/nhan-vien/'), api('GET', '/khach-hang/'), api('GET', '/khach-hang/thanh-vien')]);
    const stat = (n, l, href) => `<a class="card stat" href="${href}"><b>${n}</b><span>${l}</span></a>`;
    const sap = hh.filter(h => h.HSD && daysLeft(h.HSD) <= 7).sort((a, b) => a.HSD < b.HSD ? -1 : 1);
    const thap = hh.filter(h => h.SoLuongHangTonKho <= 10).sort((a, b) => a.SoLuongHangTonKho - b.SoLuongHangTonKho);
    const list = (t, arr, f) => `<div class="card"><h3>${t}</h3>${arr.length ? arr.slice(0, 8).map(f).join('') : '<div class="empty">Không có mục nào cần chú ý.</div>'}</div>`;
    app.innerHTML = `<div class="stats">
      ${stat(hh.length, 'Mặt hàng', 'hang-hoa.html')}${stat(nv.length, 'Nhân viên', 'nhan-vien.html')}
      ${stat(kh.length, 'Khách hàng', 'khach-hang.html')}${stat(the.filter(t => t.TrangThaiThe === 'HoatDong').length, 'Thẻ đang hoạt động', 'the-thanh-vien.html')}</div>
      <div class="grid2">
      ${list('Hàng sắp hoặc đã hết hạn (7 ngày)', sap, h => { const d = daysLeft(h.HSD); return `<div class="row"><span>${esc(h.TenHang)}</span><span class="tag ${d < 0 ? 'bad' : 'warn'}">${d < 0 ? 'Đã hết hạn' : 'Còn ' + d + ' ngày'}</span></div>`; })}
      ${list('Hàng tồn kho thấp (10 trở xuống)', thap, h => `<div class="row"><span>${esc(h.TenHang)}</span><span class="tag warn">Còn ${h.SoLuongHangTonKho}</span></div>`)}</div>`;
  } catch (e) { app.innerHTML = `<div class="card err">${esc(e.message)}</div>`; }
})();
