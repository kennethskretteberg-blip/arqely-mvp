const http = require('http');
const fs = require('fs');
const path = require('path');

const FILE = path.join(__dirname, 'romtegner.html');
const PORT = 4000;

const MIME = { '.pdf': 'application/pdf', '.png': 'image/png', '.jpg': 'image/jpeg', '.svg': 'image/svg+xml', '.js': 'text/javascript', '.html': 'text/html; charset=utf-8', '.css': 'text/css' };
http.createServer((req, res) => {
  const ext = path.extname(req.url).toLowerCase();
  if (ext && MIME[ext]) {
    const filePath = path.join(__dirname, decodeURIComponent(req.url));
    fs.readFile(filePath, (err, data) => {
      if (err) { res.writeHead(404); res.end('Not found'); return; }
      res.writeHead(200, { 'Content-Type': MIME[ext] });
      res.end(data);
    });
    return;
  }
  fs.readFile(FILE, (err, data) => {
    if (err) { res.writeHead(500); res.end('Error: ' + err.message); return; }
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(data);
  });
}).listen(PORT, () => console.log(`Romtegner → http://localhost:${PORT}`));
