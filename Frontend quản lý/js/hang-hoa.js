CrudPage({
  title: 'hàng hóa', base: '/hang-hoa', slash: true, key: 'MaHH',
  searchCols: ['TenHang', 'MaHH', 'Loai'],
  cols: [
    { k: 'MaHH', label: 'Mã hàng', req: true, maxlength: 10 },
    { k: 'TenHang', label: 'Tên hàng', req: true, maxlength: 100, full: true },
    { k: 'Loai', label: 'Loại', req: true, maxlength: 50 },
    { k: 'Gia', label: 'Giá bán', type: 'money', req: true },
    { k: 'HSD', label: 'Hạn sử dụng', type: 'date', hint: 'Để trống nếu hàng không có hạn dùng.',
      render: v => { if (!v) return '<span class="tag">Không có</span>'; const d = daysLeft(v);
        return dmy(v) + ' ' + (d < 0 ? '<span class="tag bad">Hết hạn</span>' : d <= 7 ? `<span class="tag warn">Còn ${d} ngày</span>` : ''); } },
    { k: 'SoLuongHangTonKho', label: 'Tồn kho', type: 'number', def: 0,
      hint: 'Tồn kho tự cập nhật khi nhập hàng hoặc bán hàng.',
      render: v => v <= 10 ? `${v} <span class="tag warn">Sắp hết</span>` : v },
  ],
});
