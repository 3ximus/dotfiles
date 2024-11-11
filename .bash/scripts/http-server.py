#!/bin/env -S python3 -u

# A better implementation of simple http server, it allows for:
#  - logging of headers and body content
#  - serving files on a directory
#  - saving files in body into an output directory

import argparse
import builtins
from http import HTTPStatus
import http.server
import os
import re
import sys
import tempfile
import time

REQUEST_COUNT = 0
COLORED_OUTPUT = False

ANSI_ESCAPE = re.compile(r'\x1b\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]')
def custom_print(*args, **kwargs):
  '''Override default print function to remove ANSI sequnces if not TTY output'''
  text = " ".join(str(arg) for arg in args)
  if not COLORED_OUTPUT:
    text = ANSI_ESCAPE.sub('', text)
  builtins._original_print(text, **kwargs)
builtins._original_print = print
builtins.print = custom_print


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
      self.wfile.write(b'success\n')
    except ValueError:
      self.log(HTTPStatus.INTERNAL_SERVER_ERROR)
      self.send_response(HTTPStatus.INTERNAL_SERVER_ERROR)
      self.end_headers()
      self.wfile.write(b'failed\n')

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
      print(f'\033[1;30m{'-'*20} {REQUEST_COUNT}\033[m')

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
    codeStr = f'\033[1;31m{code}\033[m' if int(code)//100 >= 4  else f'\033[1;32m{code}\033[m'
    REQUEST_COUNT += 1
    print(f' +\033[1;30m{REQUEST_COUNT}\033[m {timestamp} \033[1;33m{self.address_string()}\033[m  |  \033[1;34m{self.requestline}\033[m {codeStr} {size}')

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
  parser.add_argument('--color', action='store_true', help="force use colors even when output is redirected")
  args = parser.parse_args()

  class Server(http.server.ThreadingHTTPServer):
    def finish_request(self, request, client_address):
      self.RequestHandlerClass(request, client_address,
                               self, directory=args.directory)
  COLORED_OUTPUT = args.color or sys.stdout.isatty()
  httpd = Server(('', args.port), HTTPRequestHandler)
  print(f'+ http server running: \033[1;32mhttp://localhost:{args.port}/\033[m')
  if args.directory and args.output:
    print(f'+ saving post data to: {os.path.join(args.directory, args.output)}')

  try:
    httpd.serve_forever()
  except KeyboardInterrupt:
    print('bye')
    sys.exit()
