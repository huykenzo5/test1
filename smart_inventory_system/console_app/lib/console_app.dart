
// console_app/bin/console_app.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class InventoryManager {
  final Map<String, int> _inventory = {};

  void restock(String product, int amount) {
    if (amount < 0) throw Exception('Cannot restock negative amount.');
    _inventory[product] = (_inventory[product] ?? 0) + amount;
    print('Restocked \$amount of \$product. Current stock: \${_inventory[product]}');
  }

  void withdraw(String product, int amount) {
    if (!_inventory.containsKey(product)) throw Exception('Product not found.');
    if (_inventory[product]! < amount) throw Exception('Out of stock.');
    _inventory[product] = _inventory[product]! - amount;
    print('Withdrew \$amount of \$product. Remaining: \${_inventory[product]}');
  }

  void showInventory() {
    print('\n📦 Current Inventory:');
    _inventory.forEach((key, value) => print('- \$key: \$value'));
  }
}

int computeSync(int n) {
  int sum = 0;
  for (int i = 1; i <= n; i++) {
    sum += i;
  }
  return sum;
}

Future<int> computeAsync(int n) async {
  int sum = 0;
  for (int i = 1; i <= n; i++) {
    sum += i;
    if (i % (n ~/ 10 == 0 ? 1 : n ~/ 10) == 0) {
      await Future.delayed(Duration(milliseconds: 1));
    }
  }
  return sum;
}

Future<void> fetchWeather(String city, String apiKey) async {
  final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=\$city&appid=\$apiKey&units=metric');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('\n🌤 Weather in \${data['name']}');
      print('- Description: \${data['weather'][0]['description']}');
      print('- Temperature: \${data['main']['temp']} °C');
      print('- Humidity: \${data['main']['humidity']}%');
      print('- Pressure: \${data['main']['pressure']} hPa');
    } else {
      print('Failed to get weather. Code: \${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching weather: \$e');
  }
}

void main() async {
  final manager = InventoryManager();
  const apiKey = '67ad8438a7d5081609bfefee3c0b5ea7';
  print('🚀 Smart Inventory CLI Started');

  while (true) {
    stdout.write('\nCommand (restock, withdraw, show, compute, weather, exit): ');
    final input = stdin.readLineSync();
    if (input == null || input.trim().toLowerCase() == 'exit') break;

    final parts = input.split(' ');
    try {
      switch (parts[0]) {
        case 'restock':
          manager.restock(parts[1], int.parse(parts[2]));
          break;
        case 'withdraw':
          manager.withdraw(parts[1], int.parse(parts[2]));
          break;
        case 'show':
          manager.showInventory();
          break;
        case 'compute':
          int n = int.parse(parts[1]);
          int resultSync = computeSync(n);
          print('🧮 Sync result: \$resultSync');
          int resultAsync = await computeAsync(n);
          print('🧮 Async result: \$resultAsync');
          break;
        case 'weather':
          await fetchWeather(parts[1], apiKey);
          break;
        default:
          print('❓ Unknown command.');
      }
    } catch (e) {
      print('❌ Error: \$e');
    }
  }

  print('👋 Exiting Smart Inventory CLI');
}
