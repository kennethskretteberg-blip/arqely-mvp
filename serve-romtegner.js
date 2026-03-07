const http = require('http');
const fs = require('fs');
const path = require('path');

const FILE = path.join(__dirname, 'romtegner.html');
const PORT = 4000;

http.createServer((req, res) => {
  fs.readFile(FILE, (err, data) => {
    if (err) { res.writeHead(500); res.end('Error: ' + err.message); return; }
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(data);
  });
}).listen(PORT, () => console.log(`Romtegner → http://localhost:${PORT}`));
