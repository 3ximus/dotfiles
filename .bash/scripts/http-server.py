#!/bin/env python3

# A better implementation of simple http server, it allows for:
#  - logging of headers and body content
#  - serving files on a directory
#  - saving files in body into an output directory

import http.server
import argparse
import sys
import os
import tempfile

REQUEST_COUNT = 0


class HTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
  def do_POST(self):
    # store post data on the handler to be accessed later
    self.data = self.rfile.read(int(self.headers['Content-Length']))

    self.verbose_print()

    if args.output:
      self.save_file()

    self.send_response(200)
    self.end_headers()
    self.wfile.write(b'POST Request Successfull\n')

  def do_GET(self):
    self.verbose_print()

    # this will serve self.directory
    super().do_GET()

  def verbose_print(self):
    global REQUEST_COUNT
    REQUEST_COUNT += 1
    if args.verbose > 0:
      print(f'+ \x1b[1;34mREQUEST #{REQUEST_COUNT}\x1b[m')
      print(self.headers)
    if args.verbose > 1 and hasattr(self, 'data'):
      try:
        print(self.data.decode())
      except UnicodeDecodeError:
        print(self.data.hex())

  def save_file(self):
    outdir = os.path.join(args.directory, args.output)
    if not os.path.isdir(outdir):
      os.mkdir(outdir)

    with tempfile.NamedTemporaryFile(prefix="", dir=outdir, delete=False) as ofile:
      print(f'+ \x1b[1;34msaving #{REQUEST_COUNT} > {ofile.name}\x1b[m')
      ofile.write(self.data)

if __name__ == '__main__':
  parser = argparse.ArgumentParser(prog='Simple HTTP Server wrapper',)
  parser.add_argument('port', nargs='?', default=8000,
                      type=int, help="(default: %(default)s)")
  parser.add_argument('-v', '--verbose', action='count', default=0,
                      help="print headers. If given multiple times also prints the body")
  parser.add_argument('-d', '--directory', default=os.getcwd(), nargs='?',
                      help="serve this directory (default: './')")
  parser.add_argument('-o', '--output',
                      help="save post data in given OUTPUT directory. The base directory of the output destination is determined with the -d flag ( DIRECTORY/OUTPUT ). If absolute path is given then that's used instead")
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
