
// backend/bin/server.dart - sử dụng MySQL (phpMyAdmin)
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import 'package:mysql1/mysql1.dart';

late MySqlConnection db;

Future<void> connectMySQL() async {
  final settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'appuser',
    password: '123456',
    db: 'smart_inventory',
  );
  db = await MySqlConnection.connect(settings);
  await db.query('''
    CREATE TABLE IF NOT EXISTS inventory (
      product VARCHAR(255) PRIMARY KEY,
      quantity INT NOT NULL
    );
  ''');
}

final router = Router()
  ..get('/inventory', (Request req) async {
    final results = await db.query('SELECT * FROM inventory');
    final map = {for (final row in results) row[0]: row[1]};
    return Response.ok(jsonEncode(map), headers: {'Content-Type': 'application/json'});
  })
  ..post('/inventory', (Request req) async {
    final data = jsonDecode(await req.readAsString());
    final product = data['product'] as String;
    final amount = (data['amount'] as num).toInt();
    try {
      await db.query('INSERT INTO inventory (product, quantity) VALUES (?, ?)', [product, amount]);
      return Response.ok('Created');
    } catch (e) {
      return Response(400, body: 'Error: $e');
    }
  })
  ..put('/inventory/<product>', (Request req, String product) async {
    final data = jsonDecode(await req.readAsString());
    final amount = (data['amount'] as num).toInt();
    await db.query('UPDATE inventory SET quantity = ? WHERE product = ?', [amount, product]);
    return Response.ok('Updated');
  })
  ..delete('/inventory/<product>', (Request req, String product) async {
    await db.query('DELETE FROM inventory WHERE product = ?', [product]);
    return Response.ok('Deleted');
  })
  ..get('/compute', (Request req) async {
    final mode = req.url.queryParameters['mode'] ?? 'sync';
    final n = int.tryParse(req.url.queryParameters['n'] ?? '') ?? 100000;
    if (n < 0) return Response(400, body: 'n must be positive');
    int result = 0;
    final start = DateTime.now();
    if (mode == 'async') {
      for (int i = 1; i <= n; i++) {
        result += i;
        if (i % (n ~/ 10 == 0 ? 1 : n ~/ 10) == 0) {
          await Future.delayed(Duration(milliseconds: 5));
        }
      }
    } else {
      for (int i = 1; i <= n; i++) {
        result += i;
      }
    }
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    return Response.ok(jsonEncode({
      'result': result,
      'duration_ms': elapsed,
      'mode': mode
    }), headers: {'Content-Type': 'application/json'});
  })
  ..get('/weather', (Request req) async {
    final city = req.url.queryParameters['city'] ?? 'Hanoi';
    final apiKey = '67ad8438a7d5081609bfefee3c0b5ea7';
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');
    try {
      final res = await http.get(url);
      if (res.statusCode != 200) {
        return Response(500, body: 'Failed to fetch weather');
      }
      return Response.ok(res.body, headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  })
  ..options('/<ignored|.*>', (Request request) async {
    return Response.ok('OK', headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    });
  });

Response _cors(Response res) => res.change(headers: {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  ...res.headers,
});

void main() async {
  await connectMySQL();
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware((innerHandler) {
        return (request) async {
          final response = await innerHandler(request);
          return _cors(response);
        };
      })
      .addHandler(router);
  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('✅ MySQL backend running at http://${server.address.host}:${server.port}');
}
