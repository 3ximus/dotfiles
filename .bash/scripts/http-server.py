#!/bin/env -S python3 -u

# A better implementation of simple http server, it allows for:
#  - logging of headers and body content
#  - serving files on a directory
#  - saving files in body into an output directory
#  - serving custom response headers
#
# see usage: http-server.py -h

import argparse
import base64
import builtins
from http import HTTPStatus
import http.server
import os
import re
import sys
import tempfile
import time
from typing import override

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

def parse_headers(headers):
  d = {}
  for header in headers:
    if ':' in header:
      params = header.split(':', 1)
      d[params[0].strip()] = params[1].strip()
  return d

class HTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
  @override
  def do_POST(self):
    global REQUEST_COUNT
    try:
      size = int(self.headers['Content-Length'])
      # store post data on the handler to be accessed later
      self.data = self.rfile.read(int(self.headers['Content-Length']))
      if args.output: self.save_post_data()
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
    finally:
      REQUEST_COUNT += 1
      if REQUEST_COUNT >= args.kill_after:
        self.server.shutdown()

  @override
  def do_GET(self):
    global REQUEST_COUNT
    super().do_GET()
    self.log(self.statuscode or HTTPStatus.OK)
    self.verbose_print()
    REQUEST_COUNT += 1
    if REQUEST_COUNT >= args.kill_after:
      self.server.shutdown()

  @override
  def do_HEAD(self):
    super().do_HEAD()
    self.log(self.statuscode or HTTPStatus.OK)
    self.verbose_print()
    REQUEST_COUNT += 1
    if REQUEST_COUNT >= args.kill_after:
      self.server.shutdown()

  def verbose_print(self):
    if args.headers:
      print(self.headers)
    if args.body and hasattr(self, 'data'):
      try:
        print(self.data.decode())
      except UnicodeDecodeError:
        print(base64.encodebytes(self.data).decode())
    if args.headers or (args.body and hasattr(self, 'data')):
      print(f'\033[1;30m{'-'*20} {REQUEST_COUNT}\033[m')

  def save_post_data(self):
    outdir = os.path.join(args.directory, args.output)
    if not os.path.isdir(outdir):
      os.mkdir(outdir)

    with tempfile.NamedTemporaryFile(prefix="", dir=outdir, delete=False) as ofile:
      print(f'+ \x1b[1;34msaving #{REQUEST_COUNT} >\x1b[m {ofile.name}')
      ofile.write(self.data)

      if self.headers.get('Content-Type').startswith('multipart/form-data'):
        boundary = self.headers.get('Content-Type').split('boundary=')[-1]
        for part in self.parse_multipart(self.data, boundary):
          headers = part['headers']
          body = part['body']
          if 'Content-Disposition' in headers:
            if 'filename' in headers['Content-Disposition']:
              filename = headers['Content-Disposition'].split('filename="')[-1].split('"')[0]
              with open(f'{ofile.name}.{filename}', 'wb') as ofile_part:
                print(f'+ \x1b[1;34msaving #{REQUEST_COUNT} (attachment) >\x1b[m {ofile_part.name}')
                ofile_part.write(body)

  def parse_multipart(self, data, boundary):
    """Parse multipart form data."""
    boundary = boundary.encode()
    parts = data.split(b'--' + boundary)
    parsed_data = []

    for part in parts:
      if not part or part == b'--\r\n': continue
      headers, _, body = part.partition(b'\r\n\r\n')
      headers = headers.decode('utf-8').split('\r\n')
      header_dict = {}
      for header in headers:
        if ': ' in header:
          key, value = header.split(': ', 1)
          header_dict[key] = value
      parsed_data.append({"headers": header_dict, "body": body.rstrip(b'\r\n')})
    return parsed_data

  def log(self, code='-', size='-'):
    now = time.time()
    year, month, day, hh, mm, ss, _, _, _ = time.localtime(now)
    timestamp = "%02d-%02d-%04d %02d:%02d:%02d" % (day, month, year, hh, mm, ss)
    codeStr = f'\033[1;31m{code}\033[m' if int(code)//100 >= 4  else f'\033[1;32m{code}\033[m'
    method, path, protocol = self.requestline.split() # hopefully this is safe
    print(f' +\033[1;30m{REQUEST_COUNT}\033[m {timestamp} \033[1;33m{self.address_string()}\033[m  |  \033[1;34m{method}\033[m {path} \033[1;30m{protocol}\033[m {codeStr} {size}')

  def send_custom_headers(self):
    if not args.response_headers: return
    for k, v in custom_headers.items():
      self.send_header(k, v)

  @override
  def end_headers(self):
    self.send_custom_headers()
    super().end_headers()

  @override
  def log_error(self, _, *args):
    if args[0] == 404: return
    sys.stderr.write(f'\033[1;31m -\033[m {'\033[1;31m%d: %s\033[m' % args}\n')

  @override
  def send_response(self, code, message=None):
    self.statuscode = code
    super().send_response(code, message);

  @override
  def send_error(self, code, message=None, explain=None):
    self.statuscode = code
    super().send_error(code, message, explain)

  @override
  def log_request(self, *_):
    pass


if __name__ == '__main__':
  parser = argparse.ArgumentParser(prog='http-server.py',)
  parser.add_argument('port', nargs='?', default=8000, type=int, help="(default: %(default)s)")
  parser.add_argument('-H', '--headers', action='store_true', help="print headers")
  parser.add_argument('-B', '--body', action='store_true', help="print body")
  parser.add_argument('-R', '--response-headers', nargs='*', help="set response headers (eg: 'Set-Cookie: <cookie-name>=<cookie-value>')")
  parser.add_argument('-d', '--directory', default=os.getcwd(), nargs='?', help="serve this directory (default: './')")
  parser.add_argument('-o', '--output', help="save post data in given OUTPUT directory. The base directory of the output destination is determined with the -d flag ( DIRECTORY/OUTPUT ). If absolute path is given then that's used instead")
  parser.add_argument('-k', '--kill-after', type=int, help="kill server after n requests")
  parser.add_argument('--color', action='store_true', help="force use colors even when output is redirected")
  args = parser.parse_args()

  class Server(http.server.ThreadingHTTPServer):
    def finish_request(self, request, client_address):
      self.RequestHandlerClass(request, client_address,
                               self, directory=args.directory)
  COLORED_OUTPUT = args.color or sys.stdout.isatty()
  try:
    httpd = Server(('', args.port), HTTPRequestHandler)
  except PermissionError as exception:
    if os.geteuid() != 0:
      os.execvp("sudo", ["sudo", sys.executable] + sys.argv)
    raise exception
  print(f'+ http server running: \033[1;32mhttp://localhost:{args.port}/\033[m')
  if args.directory and args.output:
    print(f'+ saving post data to: {os.path.join(args.directory, args.output)}')
  if args.response_headers:
    print(f'+ using custom headers:')
    custom_headers = parse_headers(args.response_headers)
    for k, v in custom_headers.items():
      print(f'    {k}: {v}')

  try:
    httpd.serve_forever()
  except KeyboardInterrupt:
    print('\rbye!')
    sys.exit()
