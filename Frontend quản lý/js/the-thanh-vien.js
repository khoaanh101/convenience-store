const today = new Date().toISOString().slice(0, 10);
CrudPage({
  title: 'thẻ', base: '/khach-hang/thanh-vien', slash: false, key: 'MaThe',
  searchCols: ['MaThe', 'MaKH', 'TrangThaiThe'],
  lookups: { kh: { path: '/khach-hang/', value: 'MaKH', label: r => `${r.MaKH} – ${r.HoTen}` } },
  validate: d => { if (d.HSD && d.NgayMua && d.HSD < d.NgayMua) throw new Error('Hạn sử dụng không được trước ngày mua.'); },
  cols: [
    { k: 'MaThe', label: 'Mã thẻ', req: true, maxlength: 10 },
    { k: 'MaKH', label: 'Khách hàng', type: 'select', lookup: 'kh', req: true },
    { k: 'NgayMua', label: 'Ngày mua', type: 'date', req: true, def: today },
    { k: 'GiaThe', label: 'Giá thẻ', type: 'money', req: true },
    { k: 'HSD', label: 'Hạn sử dụng', type: 'date', req: true },
    { k: 'TrangThaiThe', label: 'Trạng thái', type: 'select', req: true, def: 'HoatDong',
      options: [['HoatDong', 'Hoạt động'], ['HetHan', 'Hết hạn'], ['DaHuy', 'Đã hủy']],
      hint: 'Mỗi khách hàng chỉ có một thẻ đang hoạt động.',
      render: v => `<span class="tag ${v === 'HoatDong' ? 'ok' : v === 'HetHan' ? 'warn' : 'bad'}">${{ HoatDong: 'Hoạt động', HetHan: 'Hết hạn', DaHuy: 'Đã hủy' }[v] || esc(v)}</span>` },
  ],
});
