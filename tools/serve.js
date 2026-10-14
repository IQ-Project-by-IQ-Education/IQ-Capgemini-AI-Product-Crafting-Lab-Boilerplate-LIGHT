// Optional local server for the LIGHT app - Node built-in modules only (no npm install, no packages).
// Serves the project folder on http://localhost:<port>/ to THIS computer only (loopback).
//   node tools/serve.js 8080
// Normally started by tools/launch.sh or tools/launch.ps1, not by hand.
var http = require("http");
var fs = require("fs");
var path = require("path");

var port = Number(process.argv[2]) || 8080;
var root = path.resolve(__dirname, "..");
var types = {
  ".html": "text/html; charset=utf-8", ".js": "text/javascript; charset=utf-8", ".css": "text/css; charset=utf-8",
  ".json": "application/json", ".csv": "text/csv; charset=utf-8", ".txt": "text/plain; charset=utf-8",
  ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".gif": "image/gif", ".svg": "image/svg+xml",
  ".ico": "image/x-icon", ".webp": "image/webp", ".mp4": "video/mp4", ".woff": "font/woff", ".woff2": "font/woff2",
  ".sqlite": "application/x-sqlite3",
};

var server = http.createServer(function (req, res) {
  var urlPath;
  try { urlPath = decodeURIComponent(req.url.split(/[?#]/)[0]); } catch (e) { urlPath = "/"; }
  if (urlPath === "/") urlPath = "/index.html";
  if (urlPath === "/favicon.ico") { res.writeHead(204); return res.end(); }
  var file = path.resolve(root, "." + urlPath);
  if (file.toLowerCase().indexOf((root + path.sep).toLowerCase()) !== 0) { res.writeHead(404); return res.end("Not found"); }
  fs.readFile(file, function (err, body) {
    if (err) { res.writeHead(404); return res.end("Not found"); }
    res.writeHead(200, {
      "Content-Type": types[path.extname(file).toLowerCase()] || "application/octet-stream",
      "Content-Length": body.length,
      "Cache-Control": "no-store",
    });
    res.end(body);
  });
});

server.on("error", function (e) {
  console.log(e.code === "EADDRINUSE" ? "PORT BUSY: " + port : "ERROR: " + e.message);
  process.exit(2);
});
server.listen(port, "127.0.0.1", function () { console.log("SERVING http://localhost:" + port + "/"); });
