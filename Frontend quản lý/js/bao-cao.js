(function () {
  const app = document.getElementById('app');
  const now = new Date();
  const today = new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString().slice(0, 10);
  const monthStart = today.slice(0, 8) + '01';

  // filter: 'range' = lọc theo khoảng ngày; 'stock' = lọc theo ngưỡng tồn kho / số ngày hết hạn.
  const reports = {
    revenue: {
      title: 'Doanh thu bán hàng',
      filter: 'range',
      path: '/bao-cao/doanh-thu',
      file: 'bao-cao-doanh-thu.xlsx',
      columns: [
        ['MaHD', 'Mã hóa đơn'],
        ['ThoiGian', 'Thời gian'],
        ['KhachHang', 'Khách hàng'],
        ['NhanVien', 'Nhân viên'],
        ['SoLuong', 'Số lượng'],
        ['TongTien', 'Tổng tiền'],
      ],
      summary: [
        ['so_hoa_don', 'Số hóa đơn'],
        ['tong_so_luong', 'Sản phẩm đã bán'],
        ['tong_doanh_thu', 'Tổng doanh thu', true],
      ],
      author: 'Quản lý cửa hàng',
      recipient: 'Chủ cửa hàng / ban quản lý',
    },
    inventory: {
      title: 'Hàng tồn kho thấp / sắp hết hạn',
      filter: 'stock',
      path: '/bao-cao/ton-kho',
      file: 'bao-cao-ton-kho.xlsx',
      columns: [
        ['MaHH', 'Mã hàng'],
        ['TenHang', 'Tên hàng'],
        ['Loai', 'Loại'],
        ['TonKho', 'Tồn kho'],
        ['HSD', 'Hạn sử dụng'],
        ['TinhTrang', 'Tình trạng'],
        ['NCCGanNhat', 'NCC gần nhất'],
      ],
      summary: [
        ['so_mat_hang', 'Mặt hàng cần chú ý'],
        ['da_het_han', 'Đã hết hạn'],
        ['sap_het_han', 'Sắp hết hạn'],
        ['het_hang', 'Hết hàng'],
        ['ton_thap', 'Tồn thấp'],
      ],
      author: 'Nhân viên kho',
      recipient: 'Quản lý cửa hàng / bộ phận nhập hàng',
    },
    stock: {
      title: 'Nhập hàng',
      filter: 'range',
      path: '/bao-cao/nhap-hang',
      file: 'bao-cao-nhap-hang.xlsx',
      columns: [
        ['MaNH', 'Mã phiếu nhập'],
        ['NgayNhap', 'Ngày nhập'],
        ['TenNCC', 'Nhà cung cấp'],
        ['MaHH', 'Mã hàng'],
        ['TenHang', 'Tên hàng'],
        ['SoLuong', 'Số lượng'],
        ['DonGia', 'Đơn giá'],
        ['ThanhTien', 'Thành tiền'],
      ],
      summary: [
        ['so_phieu_nhap', 'Số phiếu nhập'],
        ['tong_so_luong', 'Số lượng nhập'],
        ['tong_chi_phi', 'Tổng chi phí', true],
      ],
      author: 'Nhân viên phụ trách kho',
      recipient: 'Quản lý cửa hàng / kế toán',
    },
  };
  const NUM_COLS = ['SoLuong', 'TongTien', 'DonGia', 'ThanhTien', 'TonKho'];

  app.innerHTML = `<div class="report-tabs noprint" role="tablist" aria-label="Chọn báo cáo">
    <button class="btn pri" type="button" role="tab" aria-selected="true" data-report="revenue">Doanh thu bán hàng</button>
    <button class="btn" type="button" role="tab" aria-selected="false" data-report="inventory">Hàng tồn kho</button>
    <button class="btn" type="button" role="tab" aria-selected="false" data-report="stock">Nhập hàng</button>
  </div><section id="report"></section>`;

  const reportElement = document.getElementById('report');
  let activeReport = 'revenue';
  let currentData = null;
  let currentQuery = '';
  const el = selector => reportElement.querySelector(selector);

  // Tham số lọc hiện tại của báo cáo đang chọn (dùng cho cả xem, xuất file và kiểm tra dữ liệu còn mới).
  function currentParams(report) {
    return report.filter === 'stock'
      ? new URLSearchParams({ nguong: el('#nguong').value, han: el('#han').value })
      : new URLSearchParams({ from_date: el('#fromDate').value, to_date: el('#toDate').value });
  }
  const reportUrl = (report, exportFile) => `${report.path}${exportFile ? '/xuat' : ''}?${currentParams(report)}`;

  function validate(report) {
    if (report.filter === 'stock') {
      const n = el('#nguong').value, h = el('#han').value;
      if (n === '' || h === '' || Number(n) < 0 || Number(h) < 0 || !Number.isInteger(Number(n)) || !Number.isInteger(Number(h)))
        return 'Ngưỡng tồn kho và số ngày hết hạn phải là số nguyên không âm.';
      return '';
    }
    const f = el('#fromDate').value, t = el('#toDate').value;
    if (!f || !t) return 'Vui lòng chọn đầy đủ khoảng ngày.';
    if (f > t) return 'Ngày bắt đầu không được sau ngày kết thúc.';
    return '';
  }

  function periodText(report) {
    return report.filter === 'stock'
      ? `Tại ngày ${dmy(today)} · tồn kho từ ${el('#nguong').value} trở xuống hoặc hết hạn trong ${el('#han').value} ngày`
      : `Từ ${dmy(el('#fromDate').value)} đến ${dmy(el('#toDate').value)}`;
  }

  function cellHtml(key, value) {
    if (value == null) return '';
    if (['TongTien', 'DonGia', 'ThanhTien'].includes(key)) return money(value);
    if (key === 'ThoiGian') return new Date(value).toLocaleString('vi-VN');
    if (key === 'NgayNhap') return dmy(value);
    if (key === 'HSD') return value ? dmy(value) : '<span class="tag">Không có</span>';
    if (key === 'TinhTrang') return `<span class="tag ${value === 'Sắp hết hạn' || value === 'Tồn thấp' ? 'warn' : 'bad'}">${esc(value)}</span>`;
    if (key === 'TonKho') return Number(value).toLocaleString('vi-VN');
    return esc(value);
  }

  function drawTable(report, rows) {
    if (!rows.length) return '<div class="card empty">Không có dữ liệu cho điều kiện đã chọn.</div>';
    return `<div class="card"><div class="tw"><table><thead><tr><th class="num">STT</th>${report.columns.map(([k, label]) => `<th class="${NUM_COLS.includes(k) ? 'num' : ''}">${esc(label)}</th>`).join('')}</tr></thead>
      <tbody>${rows.map((row, i) => `<tr><td class="num">${i + 1}</td>${report.columns.map(([key]) =>
        `<td class="${NUM_COLS.includes(key) ? 'num' : ''}">${cellHtml(key, row[key])}</td>`).join('')}</tr>`).join('')}</tbody></table></div></div>`;
  }

  function draw(report, data) {
    const stat = report.summary.map(([key, label, isMoney]) =>
      `<div class="card stat"><b>${isMoney ? money(data.summary[key]) : Number(data.summary[key]).toLocaleString('vi-VN')}</b><span>${label}</span></div>`
    ).join('');
    el('#reportResult').innerHTML = `
      <div class="print-head"><b>CỬA HÀNG TIỆN LỢI</b><h2>${esc(report.title.toUpperCase())}</h2>
        <p>${esc(periodText(report))}</p><p>Ngày lập: ${dmy(today)}</p></div>
      <div class="report-meta"><span><b>Người lập:</b> ${esc(report.author)}</span><span><b>Nơi nhận:</b> ${esc(report.recipient)}</span></div>
      <div class="stats">${stat}</div>
      ${drawTable(report, data.rows)}
      <p class="count">${data.rows.length.toLocaleString('vi-VN')} dòng dữ liệu</p>
      <div class="print-sign"><div><b>Người lập báo cáo</b><small>${esc(report.author)}</small><em>(Ký, ghi rõ họ tên)</em></div>
        <div><b>Người nhận báo cáo</b><small>${esc(report.recipient)}</small><em>(Ký, ghi rõ họ tên)</em></div></div>`;
  }

  async function loadReport() {
    const report = reports[activeReport];
    const result = el('#reportResult');
    const bad = validate(report);
    currentData = null;
    if (bad) { result.innerHTML = `<div class="card err">${esc(bad)}</div>`; return; }
    result.innerHTML = '<div class="card empty">Đang tải báo cáo…</div>';
    try {
      const query = currentParams(report).toString();
      currentData = await api('GET', reportUrl(report, false));
      currentQuery = query;
      draw(report, currentData);
    } catch (error) {
      result.innerHTML = `<div class="card err">${esc(error.message)}</div>`;
    }
  }

  async function exportReport() {
    const report = reports[activeReport];
    if (!currentData || currentQuery !== currentParams(report).toString()) {
      toast('Hãy bấm “Xem báo cáo” với điều kiện đã chọn trước khi xuất file.', true);
      return;
    }
    try {
      const response = await fetch(API_BASE + reportUrl(report, true));
      if (!response.ok) {
        let detail = `Lỗi ${response.status}`;
        try { detail = (await response.json()).detail || detail; } catch (error) { /* giữ thông báo HTTP */ }
        throw new Error(detail);
      }
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = report.file;
      link.click();
      setTimeout(() => URL.revokeObjectURL(url), 1000);
    } catch (error) {
      toast(error.message, true);
    }
  }

  function printReport() {
    const report = reports[activeReport];
    if (!currentData || currentQuery !== currentParams(report).toString()) {
      toast('Hãy bấm “Xem báo cáo” với điều kiện đã chọn trước khi in.', true);
      return;
    }
    const old = document.title;
    document.title = report.file.replace('.xlsx', '') + '_' + today;   // tên file PDF gợi ý
    window.print();
    document.title = old;
  }

  function renderReport() {
    const report = reports[activeReport];
    const filters = report.filter === 'stock'
      ? `<label>Tồn kho từ (trở xuống) <input id="nguong" type="number" min="0" step="1" value="10" required></label>
         <label>Hết hạn trong (ngày) <input id="han" type="number" min="0" step="1" value="7" required></label>`
      : `<label>Từ ngày <input id="fromDate" type="date" value="${monthStart}" required></label>
         <label>Đến ngày <input id="toDate" type="date" value="${today}" required></label>`;
    reportElement.innerHTML = `<div class="card report-intro noprint">
      <h2>${esc(report.title)}</h2>
      <p>Báo cáo được lập bởi <b>${esc(report.author)}</b> và gửi cho <b>${esc(report.recipient)}</b>.</p>
    </div>
    <form class="bar report-filter noprint" id="reportFilter">
      ${filters}
      <button class="btn pri" type="submit">Xem báo cáo</button>
      <button class="btn" type="button" id="exportReport">Xuất Excel</button>
      <button class="btn" type="button" id="printReport">In / Lưu PDF</button>
    </form>
    <div id="reportResult" aria-live="polite"></div>`;
    el('#reportFilter').onsubmit = event => { event.preventDefault(); loadReport(); };
    el('#exportReport').onclick = exportReport;
    el('#printReport').onclick = printReport;
    loadReport();
  }

  app.querySelector('.report-tabs').onclick = event => {
    const button = event.target.closest('[data-report]');
    if (!button || button.dataset.report === activeReport) return;
    activeReport = button.dataset.report;
    currentData = null;
    app.querySelectorAll('[data-report]').forEach(tab => {
      const selected = tab.dataset.report === activeReport;
      tab.classList.toggle('pri', selected);
      tab.setAttribute('aria-selected', String(selected));
    });
    renderReport();
  };

  renderReport();
})();
