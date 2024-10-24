import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  void addMedication() async {
    String id = 'medId${DateTime.now().millisecondsSinceEpoch}'; // Unique ID for medication
    await FirebaseDatabase.instance.ref('medications/$id').set({
      'name': nameController.text,
      'price': double.parse(priceController.text),
      'stock': int.parse(stockController.text),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Medication Name')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price')),
            TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stock')),
            ElevatedButton(
              onPressed: addMedication,
              child: const Text('Add Medication'),
            ),
          ],
        ),
      ),
    );
  }
}
