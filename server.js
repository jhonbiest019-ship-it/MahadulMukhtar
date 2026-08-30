const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const WEB_DIR = path.join(__dirname, 'web_preview');

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.apk': 'application/vnd.android.package-archive',
};

const server = http.createServer((req, res) => {
  let reqPath = req.url === '/' ? '/index.html' : req.url;

  // Serve APK directly if requested
  if (reqPath.endsWith('.apk')) {
    const apkPathInWeb = path.join(WEB_DIR, 'AlMukhtar_Institute.apk');
    const apkPathInRoot = path.join(__dirname, 'AlMukhtar_Institute.apk');
    const apkPathInBuild = path.join(__dirname, 'build', 'app', 'outputs', 'flutter-apk', 'app-release.apk');

    let targetApk = apkPathInWeb;
    if (!fs.existsSync(targetApk)) targetApk = apkPathInRoot;
    if (!fs.existsSync(targetApk)) targetApk = apkPathInBuild;

    if (fs.existsSync(targetApk)) {
      const stat = fs.statSync(targetApk);
      res.writeHead(200, {
        'Content-Type': 'application/vnd.android.package-archive',
        'Content-Length': stat.size,
        'Content-Disposition': 'attachment; filename="AlMukhtar_Institute.apk"'
      });
      return fs.createReadStream(targetApk).pipe(res);
    }
  }

  const filePath = path.join(WEB_DIR, path.normalize(reqPath));
  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, data) => {
    if (err) {
      fs.readFile(path.join(WEB_DIR, 'index.html'), (indexErr, indexData) => {
        if (indexErr) {
          res.writeHead(500, { 'Content-Type': 'text/plain' });
          res.end('Server Error');
        } else {
          res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
          res.end(indexData);
        }
      });
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(data);
    }
  });
});

server.listen(PORT, () => {
  console.log(`\n==================================================`);
  console.log(`  🕌 Al Mukhtar Islamic Institute Web System`);
  console.log(`  Running at: http://localhost:${PORT}`);
  console.log(`==================================================\n`);
});
