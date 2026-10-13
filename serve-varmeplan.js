const http = require('http');
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
