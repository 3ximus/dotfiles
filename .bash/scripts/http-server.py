#!/bin/env python3

# A better implementation of simple http server, it allows for:
#  - logging of headers and body content
#  - serving files on a directory
#  - saving files in body into an output directory

import http.server
from http import HTTPStatus
import argparse
import sys
import os
import time
import tempfile

REQUEST_COUNT = 0

class HTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
  def do_POST(self):
    try:
      size = int(self.headers['Content-Length'])
      # store post data on the handler to be accessed later
      self.data = self.rfile.read(int(self.headers['Content-Length']))
      if args.output: self.save_file()
      self.log(HTTPStatus.OK, size)
      self.verbose_print()
      self.send_response(HTTPStatus.OK)
      self.end_headers()
      self.wfile.write(b'POST Request Successfull\n')
    except ValueError:
      self.log(HTTPStatus.INTERNAL_SERVER_ERROR)
      self.send_response(HTTPStatus.INTERNAL_SERVER_ERROR)
      self.end_headers()
      self.wfile.write(b'POST Request Failed\n')

  def do_GET(self):
    super().do_GET()
    self.log(self.statuscode or HTTPStatus.OK)
    self.verbose_print()

  def verbose_print(self):
    if args.headers:
      print(self.headers)
    if args.body and hasattr(self, 'data'):
      try:
        print(self.data.decode())
      except UnicodeDecodeError:
        print(self.data.hex())
    if args.headers or (args.body and hasattr(self, 'data')):
      print('-'*10,REQUEST_COUNT)

  def save_file(self):
    outdir = os.path.join(args.directory, args.output)
    if not os.path.isdir(outdir):
      os.mkdir(outdir)

    with tempfile.NamedTemporaryFile(prefix="", dir=outdir, delete=False) as ofile:
      print(f'+ \x1b[1;34msaving #{REQUEST_COUNT} > {ofile.name}\x1b[m')
      ofile.write(self.data)

  def log(self, code='-', size='-'):
    global REQUEST_COUNT
    now = time.time()
    year, month, day, hh, mm, ss, _, _, _ = time.localtime(now)
    timestamp = "%02d-%02d-%04d %02d:%02d:%02d" % (day, month, year, hh, mm, ss)
    REQUEST_COUNT += 1
    print(f' +{REQUEST_COUNT} {timestamp} {self.address_string()}  |  {self.requestline} {code} {size}')

  def log_error(self, format, *args):
    sys.stderr.write(f'\033[1;31m -\033[m {format % args}\n')

  def send_response(self, code, message=None):
    self.statuscode = code
    super().send_response(code, message);

  def send_error(self, code, message=None, explain=None):
    self.statuscode = code
    super().send_error(code, message, explain)

  def log_request(self, *_):
    pass

if __name__ == '__main__':
  parser = argparse.ArgumentParser(prog='Simple HTTP Server wrapper',)
  parser.add_argument('port', nargs='?', default=8000, type=int, help="(default: %(default)s)")
  parser.add_argument('-H', '--headers', action='store_true', help="print headers")
  parser.add_argument('-B', '--body', action='store_true', help="print body")
  parser.add_argument('-d', '--directory', default=os.getcwd(), nargs='?', help="serve this directory (default: './')")
  parser.add_argument('-o', '--output', help="save post data in given OUTPUT directory. The base directory of the output destination is determined with the -d flag ( DIRECTORY/OUTPUT ). If absolute path is given then that's used instead")
  args = parser.parse_args()

  class Server(http.server.ThreadingHTTPServer):
    def finish_request(self, request, client_address):
      self.RequestHandlerClass(request, client_address,
                               self, directory=args.directory)
  httpd = Server(('', args.port), HTTPRequestHandler)
  print(f'+ server running at http://localhost:{args.port}/')
  if args.directory and args.output:
    print(f'+ saving post data to: {os.path.join(args.directory, args.output)}')

  try:
    httpd.serve_forever()
  except KeyboardInterrupt:
    print('bye')
    sys.exit()
