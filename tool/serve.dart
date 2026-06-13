// Servidor estático simples para a build web (build/web).
// Uso: dart run tool/serve.dart [porta]
import 'dart:io';

const _types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript',
  '.mjs': 'application/javascript',
  '.json': 'application/json',
  '.css': 'text/css',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.map': 'application/json',
};

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args.first) ?? 8080 : 8080;
  final root = Directory('build/web').absolute;
  if (!root.existsSync()) {
    stderr.writeln('build/web não encontrado. Rode: flutter build web --release');
    exit(1);
  }

  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('Servindo ${root.path} em http://localhost:$port');

  await for (final req in server) {
    try {
      var path = req.uri.path;
      if (path == '/' || path.isEmpty) path = '/index.html';
      var file = File('${root.path}$path');
      // SPA fallback: caminho sem arquivo → index.html
      if (!file.existsSync()) file = File('${root.path}/index.html');

      final ext = file.path.contains('.')
          ? file.path.substring(file.path.lastIndexOf('.'))
          : '';
      req.response.headers
          .set('Content-Type', _types[ext] ?? 'application/octet-stream');
      req.response.headers.set('Cache-Control', 'no-cache');
      await req.response.addStream(file.openRead());
    } catch (_) {
      req.response.statusCode = HttpStatus.internalServerError;
    } finally {
      await req.response.close();
    }
  }
}
