CrudPage({
  title: 'nhân viên', base: '/nhan-vien', slash: true, key: 'MaNV',
  searchCols: ['HoTen', 'MaNV', 'SDT', 'MaCV'],
  lookups: { cv: { path: '/chuc-vu/', value: 'MaCV', label: r => r.TenCV } },
  cols: [
    { k: 'MaNV', label: 'Mã NV', req: true, maxlength: 10 },
    { k: 'HoTen', label: 'Họ tên', req: true, maxlength: 100, full: true },
    { k: 'GioiTinh', label: 'Giới tính', type: 'select', req: true, options: [['Nam', 'Nam'], ['Nữ', 'Nữ']] },
    { k: 'NgaySinh', label: 'Ngày sinh', type: 'date', req: true },
    { k: 'SDT', label: 'Số điện thoại', req: true, maxlength: 10, pattern: PHONE, patternMsg: 'Số điện thoại phải gồm 10 số, bắt đầu 03, 05, 07, 08 hoặc 09.' },
    { k: 'MaCV', label: 'Chức vụ', type: 'select', lookup: 'cv', req: true },
  ],
});
