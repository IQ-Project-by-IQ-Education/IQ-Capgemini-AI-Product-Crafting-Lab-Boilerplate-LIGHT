# Optional local server for the LIGHT app - Python 3.7+ standard library only (no pip install).
# Serves the project folder on http://localhost:<port>/ to THIS computer only (loopback).
#   python3 tools/serve.py 8080
# Normally started by tools/launch.sh or tools/launch.ps1, not by hand.
import functools
import http.server
import os
import sys

port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        ".html": "text/html; charset=utf-8", ".js": "text/javascript; charset=utf-8", ".css": "text/css; charset=utf-8",
        ".json": "application/json", ".csv": "text/csv; charset=utf-8", ".txt": "text/plain; charset=utf-8",
        ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".gif": "image/gif", ".svg": "image/svg+xml",
        ".ico": "image/x-icon", ".webp": "image/webp", ".mp4": "video/mp4", ".woff": "font/woff", ".woff2": "font/woff2",
        ".sqlite": "application/x-sqlite3", "": "application/octet-stream",
    }

    def send_head(self):
        if self.path.split("?")[0] == "/favicon.ico":
            self.send_response(204)
            self.end_headers()
            return None
        return super().send_head()

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, *args):
        pass


class Server(http.server.ThreadingHTTPServer):
    daemon_threads = True

    def handle_error(self, request, client_address):
        pass  # a closed tab or an early hang-up is normal, stay quiet


try:
    server = Server(("127.0.0.1", port), functools.partial(Handler, directory=root))
except OSError:
    print("PORT BUSY: %d" % port, flush=True)
    sys.exit(2)
print("SERVING http://localhost:%d/" % port, flush=True)
server.serve_forever()
