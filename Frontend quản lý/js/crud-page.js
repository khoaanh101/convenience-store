/* Trang CRUD dùng chung. cfg:
   title, base ('/hang-hoa'), slash (true nếu list/create có dấu / cuối), key,
   cols: [{k,label,type:text|number|date|money|select,req,options|lookup,hint,render,form:false,keyEdit:false}]
   lookups: {name:{path,value,label}}  searchCols: [k...]  extraLoad: async()=>obj  */
function CrudPage(cfg) {
  const app = document.getElementById('app');
  const coll = cfg.base + (cfg.slash ? '/' : '');
  const S = { rows: [], lk: {}, extra: {}, editing: null };

  app.innerHTML = `
    <div class="bar">
      <form id="sf" class="bar" style="margin:0">
        <select id="sc">${cfg.searchCols.map(k => `<option value="${k}">${esc(cfg.cols.find(c => c.k === k).label)}</option>`).join('')}</select>
        <input id="sv" type="search" placeholder="Nhập từ khóa rồi nhấn Enter" size="26">
        <button class="btn">Tìm</button>
      </form>
      <span class="sp"></span>
      <button class="btn pri" id="add">Thêm ${esc(cfg.title)}</button>
    </div>
    <div class="card"><div class="tw" id="tb"></div></div>
    <div class="count" id="cnt"></div>
    <dialog id="dlg"><form id="df" method="dialog" novalidate>
      <h2 id="dt"></h2><div class="fields" id="ff"></div>
      <div class="foot"><button type="button" class="btn" id="cancel">Hủy</button><button class="btn pri" id="save">Lưu</button></div>
    </form></dialog>`;
  const $ = id => document.getElementById(id);

  const opts = c => c.options || (S.lk[c.lookup] || []);
  const optLabel = (c, v) => { const o = opts(c).find(o => String(o[0]) === String(v)); return o ? o[1] : v; };

  function cell(c, r) {
    const v = r[c.k];
    if (c.render) return c.render(v, r, S);
    if (c.type === 'money') return money(v);
    if (c.type === 'date') return dmy(v);
    if (c.type === 'select') return esc(optLabel(c, v));
    return esc(v);
  }

  function draw() {
    const num = c => c.type === 'number' || c.type === 'money';
    $('tb').innerHTML = S.rows.length ? `<table><thead><tr>${cfg.cols.filter(c => !c.hide).map(c => `<th class="${num(c) ? 'num' : ''}">${esc(c.label)}</th>`).join('')}<th></th></tr></thead><tbody>
      ${S.rows.map(r => `<tr>${cfg.cols.filter(c => !c.hide).map(c => `<td class="${num(c) ? 'num' : ''}">${cell(c, r)}</td>`).join('')}
      <td class="act"><button class="btn sm" data-e="${esc(r[cfg.key])}">Sửa</button> <button class="btn sm del" data-d="${esc(r[cfg.key])}">Xóa</button></td></tr>`).join('')}</tbody></table>`
      : `<div class="empty">Không có dữ liệu. Chọn “Thêm ${esc(cfg.title)}” để tạo bản ghi đầu tiên.</div>`;
    $('cnt').textContent = S.rows.length + ' bản ghi';
  }

  async function load() {
    $('tb').innerHTML = '<div class="empty">Đang tải dữ liệu…</div>';
    try {
      const q = $('sv').value.trim();
      S.rows = await api('GET', q ? `${cfg.base}/search?column=${$('sc').value}&value=${encodeURIComponent(q)}` : coll);
      draw();
    } catch (e) { $('tb').innerHTML = `<div class="err">${esc(e.message)}</div>`; $('cnt').textContent = ''; }
  }

  async function loadRefs() {
    try {
      for (const [n, l] of Object.entries(cfg.lookups || {}))
        S.lk[n] = (await api('GET', l.path)).map(r => [r[l.value], l.label(r)]);
      if (cfg.extraLoad) S.extra = await cfg.extraLoad();
    } catch (e) { /* bảng chính vẫn hiển thị; lỗi sẽ hiện ở load() */ }
  }

  function openForm(row) {
    S.editing = row;
    $('dt').textContent = (row ? 'Sửa ' : 'Thêm ') + cfg.title;
    $('ff').innerHTML = cfg.cols.filter(c => c.form !== false && (row ? c.edit !== false : c.create !== false)).map(c => {
      const dis = row && c.k === cfg.key ? 'disabled' : '';
      const v = row ? (row[c.k] ?? '') : (c.def ?? '');
      let inp;
      if (c.type === 'select') inp = `<select name="${c.k}" ${dis}>${c.req ? '' : '<option value=""></option>'}${opts(c).map(o => `<option value="${esc(o[0])}" ${String(o[0]) === String(v) ? 'selected' : ''}>${esc(o[1])}</option>`).join('')}</select>`;
      else inp = `<input name="${c.k}" ${dis} type="${c.type === 'date' ? 'date' : c.type === 'text' || !c.type ? 'text' : 'number'}" ${c.type === 'number' || c.type === 'money' ? 'min="0"' : ''} value="${esc(String(v).slice(0, 10) === v && c.type === 'date' ? v : v)}" ${c.maxlength ? `maxlength="${c.maxlength}"` : ''}>`;
      return `<label class="${c.full ? 'full' : ''}">${esc(c.label)}${c.req ? ' *' : ''}${inp}${c.hint ? `<span class="hint">${esc(c.hint)}</span>` : ''}</label>`;
    }).join('') + '<div class="ferr" id="ferr"></div>';
    $('dlg').showModal();
  }

  function collect() {
    const out = {};
    for (const c of cfg.cols.filter(c => c.form !== false && (S.editing ? c.edit !== false : c.create !== false))) {
      if (S.editing && c.k === cfg.key) continue;
      let v = document.querySelector(`#ff [name="${c.k}"]`).value.trim();
      if (v === '') { if (c.req) throw new Error(`Vui lòng nhập ${c.label}.`); if (S.editing) out[c.k] = null; continue; }
      if (c.pattern && !c.pattern.test(v)) throw new Error(c.patternMsg || `${c.label} không hợp lệ.`);
      out[c.k] = c.type === 'number' || c.type === 'money' ? Number(v) : v;
    }
    if (cfg.validate) cfg.validate(out);
    return out;
  }

  $('sf').onsubmit = e => { e.preventDefault(); load(); };
  $('add').onclick = () => openForm(null);
  $('cancel').onclick = () => $('dlg').close();
  $('tb').onclick = async e => {
    const ed = e.target.dataset.e, de = e.target.dataset.d;
    if (ed != null) openForm(S.rows.find(r => String(r[cfg.key]) === ed));
    if (de != null && confirm(`Xóa ${cfg.title} ${de}? Thao tác này không thể hoàn tác.`)) {
      try { await api('DELETE', `${cfg.base}/${encodeURIComponent(de)}`); toast('Đã xóa ' + de); load(); }
      catch (err) { toast(err.message, true); }
    }
  };
  $('df').onsubmit = async e => {
    e.preventDefault(); $('ferr').textContent = '';
    try {
      const data = collect(); $('save').disabled = true;
      if (S.editing) await api('PUT', `${cfg.base}/${encodeURIComponent(S.editing[cfg.key])}`, data);
      else if (cfg.createRequest) await cfg.createRequest(data);
      else await api('POST', coll, data);
      $('dlg').close(); toast(S.editing ? 'Đã lưu thay đổi' : 'Đã thêm ' + cfg.title); load();
    } catch (err) { $('ferr').textContent = err.message; }
    finally { $('save').disabled = false; }
  };

  loadRefs().then(load);
}
const PHONE = /^0[35789][0-9]{8}$/;
