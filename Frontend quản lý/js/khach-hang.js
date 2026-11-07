CrudPage({
  title: 'khách hàng', base: '/khach-hang', slash: true, key: 'MaKH',
  searchCols: ['HoTen', 'MaKH', 'SDT'],
  extraLoad: async () => { const t = await api('GET', '/khach-hang/thanh-vien'); const m = {};
    t.filter(x => x.TrangThaiThe === 'HoatDong').forEach(x => m[x.MaKH] = x.MaThe); return { active: m }; },
  cols: [
    { k: 'MaKH', label: 'Mã KH', req: true, maxlength: 10 },
    { k: 'HoTen', label: 'Họ tên', req: true, maxlength: 100, full: true },
    { k: 'SDT', label: 'Số điện thoại', req: true, maxlength: 10, full: true, pattern: PHONE, patternMsg: 'Số điện thoại phải gồm 10 số, bắt đầu 03, 05, 07, 08 hoặc 09.' },
    { k: 'MaKH', label: 'Thẻ thành viên', form: false, render: (v, r, S) => S.extra.active && S.extra.active[v] ? `<span class="tag ok">${esc(S.extra.active[v])}</span>` : '<span class="tag">Chưa có</span>' },
  ],
});
