
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const SmartInventoryApp());

class SmartInventoryApp extends StatelessWidget {
  const SmartInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Inventory',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InventoryDashboard(),
    );
  }
}

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  Map<String, dynamic> inventory = {};
  String weather = '';
  final TextEditingController productCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();

  Future<void> fetchInventory() async {
    final res = await http.get(Uri.parse('http://localhost:8080/inventory'));
    if (res.statusCode == 200) {
      setState(() {
        inventory = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchWeather() async {
    final res = await http.get(Uri.parse('http://localhost:8080/weather?city=Hanoi'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        weather = data['weather'][0]['description'] + ', ${data['main']['temp']}°C';
      });
    }
  }

  Future<void> sendRequest(String method) async {
    final product = productCtrl.text.trim();
    final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
    final url = Uri.parse('http://localhost:8080/inventory${method == 'put' || method == 'delete' ? '/$product' : ''}');
    final body = jsonEncode({'product': product, 'amount': amount});
    http.Response res;

    try {
      if (method == 'post') {
        res = await http.post(url, body: body, headers: {'Content-Type': 'application/json'});
      } else if (method == 'put') {
        res = await http.put(url, body: body, headers: {'Content-Type': 'application/json'});
      } else if (method == 'delete') {
        res = await http.delete(url);
      } else {
        throw Exception('Unsupported method');
      }

      if (res.statusCode == 200) {
        await fetchInventory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: ${res.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Exception: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInventory();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📦 Smart Inventory Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🌤 Weather: $weather', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('📋 Inventory:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: inventory.entries
                    .map((e) => ListTile(title: Text('${e.key}'), trailing: Text('Qty: ${e.value}')))
                    .toList(),
              ),
            ),
            const Divider(),
            const Text('➕➖ CRUD Product', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Expanded(child: TextField(controller: productCtrl, decoration: const InputDecoration(labelText: 'Product'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount'))),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: () => sendRequest('post'), child: const Text('Create')),
                const SizedBox(width: 5),
                ElevatedButton(onPressed: () => sendRequest('put'), child: const Text('Update')),
                const SizedBox(width: 5),
                ElevatedButton(onPressed: () => sendRequest('delete'), child: const Text('Delete')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
