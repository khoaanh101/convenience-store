// Dựng sidebar + header quanh <main id="app"> dựa vào data-page / data-title của <body>.
(function () {
  const pages = [
    ['index', 'Tổng quan', 'index.html'],
    ['hang-hoa', 'Hàng hóa', 'hang-hoa.html'],
    ['nhan-vien', 'Nhân viên', 'nhan-vien.html'],
    ['khach-hang', 'Khách hàng', 'khach-hang.html'],
    ['the-thanh-vien', 'Thẻ thành viên', 'the-thanh-vien.html'],
    ['ban-hang', 'Bán hàng', 'ban-hang.html'],
    ['hoa-don', 'Hóa đơn & Phiếu nhập', 'hoa-don.html'],
    ['nhap-hang', 'Nhập hàng', 'nhap-hang.html'],
  ];
  const cur = document.body.dataset.page;
  const app = document.getElementById('app');
  const shell = document.createElement('div');
  shell.className = 'shell';
  shell.innerHTML = `
    <nav class="side" id="side" aria-label="Menu chính">
      <div class="brand"><i>CH</i>Cửa hàng tiện lợi</div>
      <small>Quản lý</small>
      ${pages.map(p => `<a href="${p[2]}" class="${p[0] === cur ? 'on' : ''}">${p[1]}</a>`).join('')}
    </nav>
    <div class="main">
      <header class="top">
        <button class="btn burger" id="burger" aria-label="Mở menu">☰</button>
        <h1>${esc(document.body.dataset.title)}</h1>
        <button class="api" id="apiChip" title="Bấm để đổi địa chỉ API"><b></b>API</button>
        <div class="me" title="Quản lý">QL</div>
      </header>
    </div>`;
  document.body.insertBefore(shell, app);
  shell.querySelector('.main').appendChild(app);
  const toastBox = document.createElement('div'); toastBox.id = 'toast'; document.body.appendChild(toastBox);
  document.getElementById('burger').onclick = () => document.getElementById('side').classList.toggle('open');

  const chip = document.getElementById('apiChip');
  chip.onclick = () => {
    const v = prompt('Địa chỉ API backend:', API_BASE);
    if (v) { localStorage.setItem('API_BASE', v.trim()); location.reload(); }
  };
  fetch(API_BASE + '/').then(r => { if (!r.ok) throw 0; chip.classList.add('ok'); chip.lastChild.textContent = ' Đã kết nối'; })
    .catch(() => { chip.classList.add('bad'); chip.lastChild.textContent = ' Mất kết nối'; });
})();
