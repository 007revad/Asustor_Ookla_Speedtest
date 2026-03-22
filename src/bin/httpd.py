#!/usr/bin/env python3
import os, sys
from http.server import HTTPServer, CGIHTTPRequestHandler

class NoDemoteCGIHandler(CGIHTTPRequestHandler):
    def run_cgi(self):
        # Prevent Python dropping to nobody before executing CGI
        old_setuid = os.setuid
        os.setuid = lambda uid: None
        try:
            super().run_cgi()
        finally:
            os.setuid = old_setuid

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 39876
    os.chdir(sys.argv[2] if len(sys.argv) > 2 else '.')
    HTTPServer(('', port), NoDemoteCGIHandler).serve_forever()