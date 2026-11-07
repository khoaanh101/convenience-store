// Địa chỉ backend. Có thể đổi nhanh bằng cách bấm vào chip "API" trên header.
const API_BASE = (localStorage.getItem('API_BASE') || 'http://127.0.0.1:8000').replace(/\/$/, '');

async function api(method, path, body) {
  let res;
  try {
    res = await fetch(API_BASE + path, {
      method,
      headers: body ? { 'Content-Type': 'application/json' } : {},
      body: body ? JSON.stringify(body) : undefined,
    });
  } catch (e) {
    throw new Error('Không kết nối được API tại ' + API_BASE + '. Hãy kiểm tra backend đã chạy và đã bật CORS.');
  }
  let data = null;
  try { data = await res.json(); } catch (e) {}
  if (!res.ok) {
    let d = data && data.detail;
    if (Array.isArray(d)) d = d.map(x => x.msg).join('; ');
    throw new Error(d || 'Lỗi ' + res.status);
  }
  return data;
}

const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const money = n => n == null || n === '' ? '' : Number(n).toLocaleString('vi-VN') + ' ₫';
const dmy = d => d ? String(d).slice(0, 10).split('-').reverse().join('/') : '';
const daysLeft = d => Math.ceil((new Date(String(d).slice(0, 10)) - new Date(new Date().toDateString())) / 864e5);

function toast(msg, bad) {
  const box = document.getElementById('toast');
  const el = document.createElement('div');
  el.textContent = msg; if (bad) el.className = 'bad';
  box.appendChild(el); setTimeout(() => el.remove(), 3500);
}
