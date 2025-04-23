
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> fetchInventory() async {
  final res = await http.get(Uri.parse('http://localhost:8080/inventory'));
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    print('\n📦 Inventory:');
    data.forEach((key, value) {
      print('- $key: $value');
    });
  } else {
    print('❌ Failed to fetch inventory');
  }
}

Future<void> sendInventoryRequest(String method, String product, int amount) async {
  final url = Uri.parse('http://localhost:8080/inventory${method == 'put' || method == 'delete' ? '/$product' : ''}');
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({'product': product, 'amount': amount});
  http.Response res;

  try {
    if (method == 'post') {
      res = await http.post(url, headers: headers, body: body);
    } else if (method == 'put') {
      res = await http.put(url, headers: headers, body: body);
    } else if (method == 'delete') {
      res = await http.delete(url);
    } else {
      print('❓ Unsupported method');
      return;
    }

    print('✅ Response: ${res.body}');
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> compute(int n, String mode) async {
  final url = Uri.parse('http://localhost:8080/compute?mode=$mode&n=$n');
  final res = await http.get(url);
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    print('🧮 ${data['mode']} result: ${data['result']} (in ${data['duration_ms']}ms)');
  } else {
    print('❌ Compute failed: ${res.body}');
  }
}

Future<void> fetchWeather(String city) async {
  final url = Uri.parse('http://localhost:8080/weather?city=$city');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('\n🌤 Weather in ${data['name']}');
      print('- Description: ${data['weather'][0]['description']}');
      print('- Temperature: ${data['main']['temp']} °C');
      print('- Humidity: ${data['main']['humidity']}%');
      print('- Pressure: ${data['main']['pressure']} hPa');
    } else {
      print('Failed to get weather. Code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching weather: $e');
  }
}

void main() async {
  print('🚀 Smart Inventory CLI Started');
  while (true) {
    stdout.write('\nCommand (post, put, delete, fetch, compute sync/async <n>, weather <city>, exit): ');
    final input = stdin.readLineSync();
    if (input == null || input.trim().toLowerCase() == 'exit') break;

    final parts = input.trim().split(' ');
    try {
      switch (parts[0]) {
        case 'post':
        case 'put':
          await sendInventoryRequest(parts[0], parts[1], int.parse(parts[2]));
          break;
        case 'delete':
          await sendInventoryRequest('delete', parts[1], 0);
          break;
        case 'fetch':
          await fetchInventory();
          break;
        case 'compute':
          await compute(int.parse(parts[2]), parts[1]);
          break;
        case 'weather':
          await fetchWeather(parts[1]);
          break;
        default:
          print('❓ Unknown command.');
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
  print('👋 Exiting CLI');
}
