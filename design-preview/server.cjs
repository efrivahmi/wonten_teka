const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
http.createServer((req, res) => {
  if (req.url?.split('?')[0] !== '/') { res.writeHead(404); res.end('Not found'); return; }
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.end(fs.readFileSync(path.join(__dirname, 'index.html')));
}).listen(4174, '127.0.0.1', () => process.stdout.write('Design preview: http://127.0.0.1:4174\n'));
