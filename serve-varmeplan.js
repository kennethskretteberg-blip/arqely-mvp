const http = require('http');
const START_ISO = new Date().toISOString();
const fs = require('fs');
const path = require('path');

const FILE = path.join(__dirname, 'index.html');
const PORT = process.env.PORT || 4000;

const MIME = { '.pdf': 'application/pdf', '.png': 'image/png', '.jpg': 'image/jpeg', '.svg': 'image/svg+xml', '.js': 'text/javascript', '.html': 'text/html; charset=utf-8', '.css': 'text/css' };
const DEV_AUTH_FILE = path.join(__dirname, '.dev-auth.json');

http.createServer((req, res) => {
  // Dev-auth endpoint: serves test credentials for auto-login
  if (req.url === '/__dev-auth') {
    fs.readFile(DEV_AUTH_FILE, (err, data) => {
      if (err) { res.writeHead(404); res.end('No .dev-auth.json found'); return; }
      res.writeHead(200, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
      res.end(data);
    });
    return;
  }
  // 068 (kabelmotor): skrive-endepunkt for romgalleriet. Nettleseren kan ikke laste ned filer
  // i forhandsvisningsruten, og galleriet (docs/kabel/galleri.html) skal kunne regenereres med
  // EN kommando i 069/070. Derfor: POST /__write-galleri skriver NOYAKTIG den ene filen, ingen
  // annen sti er mulig. Dette er dev-serveren - den deployes ikke (vercel.json serverer index.html).
  if (req.method === 'POST' && req.url === '/__write-galleri') {
    const chunks = [];
    req.on('data', c => chunks.push(c));
    req.on('end', () => {
      const target = path.join(__dirname, 'docs', 'kabel', 'galleri.html');
      fs.mkdir(path.dirname(target), { recursive: true }, () => {
        fs.writeFile(target, Buffer.concat(chunks), err => {
          res.writeHead(err ? 500 : 200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
          res.end(JSON.stringify(err ? { ok: false, error: err.message } : { ok: true, bytes: Buffer.concat(chunks).length, path: 'docs/kabel/galleri.html' }));
        });
      });
    });
    return;
  }

  // 096: figurskriving for rapporten. NOYAKTIG én fil, som de to andre.
  if (req.method === 'POST' && req.url === '/__write-figur') {
    const chunks = [];
    req.on('data', c => chunks.push(c));
    req.on('end', () => {
      const target = path.join(__dirname, 'docs', 'kabel', 'fasit', '096-rom8.svg');
      const buf = Buffer.concat(chunks);
      fs.mkdir(path.dirname(target), { recursive: true }, () => {
        fs.writeFile(target, buf, err => {
          res.writeHead(err ? 500 : 200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(err ? { ok: false, error: err.message } : { ok: true, bytes: buf.length, path: 'docs/kabel/fasit/096-rom8.svg' }));
        });
      });
    });
    return;
  }

  // 095: lesing av baselinjen. ⚠ MAA vaere et eget endepunkt: den statiske ruten faller tilbake
  // til index.html for /docs/..., saa `fetch('/docs/kabel/baseline.json')` ga status 200 med HTML
  // og en stille JSON-feil i klienten — porten kunne ALDRI lese baselinjen sin.
  if (req.method === 'GET' && req.url === '/__baseline') {
    const target = path.join(__dirname, 'docs', 'kabel', 'baseline.json');
    fs.readFile(target, (err, buf) => {
      if (err) { res.writeHead(404, { 'Content-Type': 'application/json' }); res.end('{"ok":false,"error":"ingen baseline.json"}'); return; }
      res.writeHead(200, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
      res.end(buf);
    });
    return;
  }

  // 095: samme moenster, for den lagrede baselinjen til den raske geo-suiten. NOYAKTIG én fil.
  if (req.method === 'POST' && req.url === '/__write-baseline') {
    const chunks = [];
    req.on('data', c => chunks.push(c));
    req.on('end', () => {
      const target = path.join(__dirname, 'docs', 'kabel', 'baseline.json');
      const buf = Buffer.concat(chunks);
      fs.writeFile(target, buf, err => {
        res.writeHead(err ? 500 : 200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(err ? { ok: false, error: err.message } : { ok: true, bytes: buf.length, path: 'docs/kabel/baseline.json' }));
      });
    });
    return;
  }

  // 088: byggstempel. Kenneth og jeg brukte tre runder paa aa lete etter en feil som viste seg
  // aa vaere «ser du paa ny eller gammel kode?». Dette gjoer det til et blikk i statuslinja.
  if (req.url === '/__build.json') {
    const { execSync } = require('child_process');
    const g = (c) => { try { return execSync(c, { cwd: __dirname }).toString().trim(); } catch (e) { return '?'; } };
    res.writeHead(200, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
    res.end(JSON.stringify({ branch: g('git rev-parse --abbrev-ref HEAD'),
                             hash: g('git rev-parse --short HEAD'),
                             started: START_ISO }));
    return;
  }

  const ext = path.extname(req.url).toLowerCase();
  if (ext && MIME[ext]) {
    const filePath = path.join(__dirname, decodeURIComponent(req.url));
    fs.readFile(filePath, (err, data) => {
      if (err) { res.writeHead(404); res.end('Not found'); return; }
      res.writeHead(200, { 'Content-Type': MIME[ext], 'Cache-Control': 'no-store' });
      res.end(data);
    });
    return;
  }
  fs.readFile(FILE, (err, data) => {
    if (err) { res.writeHead(500); res.end('Error: ' + err.message); return; }
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'no-store, no-cache, must-revalidate, max-age=0', 'Pragma': 'no-cache', 'Expires': '0' });
    res.end(data);
  });
}).listen(PORT, () => console.log(`Varmeplan → http://localhost:${PORT}`));
