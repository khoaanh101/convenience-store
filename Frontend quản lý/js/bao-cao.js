(function () {
  const app = document.getElementById('app');
  const now = new Date();
  const today = new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString().slice(0, 10);
  const monthStart = today.slice(0, 8) + '01';
  const reports = {
    revenue: {
      title: 'Doanh thu bán hàng',
      path: '/bao-cao/doanh-thu',
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
    stock: {
      title: 'Nhập hàng',
      path: '/bao-cao/nhap-hang',
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

  app.innerHTML = `<div class="report-tabs" role="tablist" aria-label="Chọn báo cáo">
    <button class="btn pri" type="button" role="tab" aria-selected="true" data-report="revenue">Doanh thu bán hàng</button>
    <button class="btn" type="button" role="tab" aria-selected="false" data-report="stock">Nhập hàng</button>
  </div><section id="report"></section>`;

  const reportElement = document.getElementById('report');
  let activeReport = 'revenue';
  let currentData = null;
  const el = selector => reportElement.querySelector(selector);

  function reportUrl(report, exportFile) {
    const params = new URLSearchParams({
      from_date: el('#fromDate').value,
      to_date: el('#toDate').value,
    });
    return `${report.path}${exportFile ? '/xuat' : ''}?${params}`;
  }

  function drawTable(report, rows) {
    if (!rows.length) return '<div class="empty">Không có dữ liệu trong khoảng thời gian này.</div>';
    return `<div class="card"><div class="tw"><table><thead><tr>${report.columns.map(([, label]) => `<th>${esc(label)}</th>`).join('')}</tr></thead>
      <tbody>${rows.map(row => `<tr>${report.columns.map(([key]) => {
        const value = row[key];
        const formatted = key === 'TongTien' || key === 'DonGia' || key === 'ThanhTien'
          ? money(value)
          : key === 'ThoiGian' ? new Date(value).toLocaleString('vi-VN')
            : key === 'NgayNhap' ? dmy(value) : esc(value);
        return `<td class="${['SoLuong', 'TongTien', 'DonGia', 'ThanhTien'].includes(key) ? 'num' : ''}">${formatted ?? ''}</td>`;
      }).join('')}</tr>`).join('')}</tbody></table></div></div>`;
  }

  function draw(report, data) {
    const stat = report.summary.map(([key, label, isMoney]) =>
      `<div class="card stat"><b>${isMoney ? money(data.summary[key]) : Number(data.summary[key]).toLocaleString('vi-VN')}</b><span>${label}</span></div>`
    ).join('');
    reportElement.querySelector('#reportResult').innerHTML = `
      <div class="report-meta"><span><b>Người lập:</b> ${esc(report.author)}</span><span><b>Nơi nhận:</b> ${esc(report.recipient)}</span></div>
      <div class="stats">${stat}</div>
      ${drawTable(report, data.rows)}
      <p class="count">${data.rows.length.toLocaleString('vi-VN')} dòng dữ liệu</p>`;
  }

  async function loadReport() {
    const report = reports[activeReport];
    const result = el('#reportResult');
    const fromDate = el('#fromDate').value;
    const toDate = el('#toDate').value;
    if (!fromDate || !toDate) {
      result.innerHTML = '<div class="card err">Vui lòng chọn đầy đủ khoảng ngày.</div>';
      currentData = null;
      return;
    }
    if (fromDate > toDate) {
      result.innerHTML = '<div class="card err">Ngày bắt đầu không được sau ngày kết thúc.</div>';
      currentData = null;
      return;
    }

    result.innerHTML = '<div class="card empty">Đang tải báo cáo…</div>';
    currentData = null;
    try {
      currentData = await api('GET', reportUrl(report, false));
      draw(report, currentData);
    } catch (error) {
      result.innerHTML = `<div class="card err">${esc(error.message)}</div>`;
    }
  }

  async function exportReport() {
    const report = reports[activeReport];
    if (!currentData || currentData.from_date !== el('#fromDate').value || currentData.to_date !== el('#toDate').value) {
      toast('Hãy xem lại báo cáo với khoảng ngày đã chọn trước khi xuất file.', true);
      return;
    }
    try {
      const response = await fetch(API_BASE + reportUrl(report, true));
      if (!response.ok) {
        let detail = `Lỗi ${response.status}`;
        try {
          const data = await response.json();
          detail = data.detail || detail;
        } catch (error) {
          // Giữ thông báo HTTP nếu phản hồi không phải JSON.
        }
        throw new Error(detail);
      }
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = activeReport === 'revenue' ? 'bao-cao-doanh-thu.xlsx' : 'bao-cao-nhap-hang.xlsx';
      link.click();
      setTimeout(() => URL.revokeObjectURL(url), 1000);
    } catch (error) {
      toast(error.message, true);
    }
  }

  function renderReport() {
    const report = reports[activeReport];
    reportElement.innerHTML = `<div class="card report-intro">
      <h2>${esc(report.title)}</h2>
      <p>Báo cáo được lập bởi <b>${esc(report.author)}</b> và gửi cho <b>${esc(report.recipient)}</b>.</p>
    </div>
    <form class="bar report-filter" id="reportFilter">
      <label>Từ ngày <input id="fromDate" type="date" value="${monthStart}" required></label>
      <label>Đến ngày <input id="toDate" type="date" value="${today}" required></label>
      <button class="btn pri" type="submit">Xem báo cáo</button>
      <button class="btn" type="button" id="exportReport">Xuất Excel</button>
    </form>
    <div id="reportResult" aria-live="polite"></div>`;
    el('#reportFilter').onsubmit = event => {
      event.preventDefault();
      loadReport();
    };
    el('#exportReport').onclick = exportReport;
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
