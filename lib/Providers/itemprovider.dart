import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Models/itemmodel.dart';

class ItemProvider with ChangeNotifier {
  final databaseRef = FirebaseDatabase.instance.ref().child('items');

  List<Item> _items = [];
  List<Item> get items => _items;


  //
  // Future<void> addItem({
  //   required String id,
  //   required String itemName,
  //   required double purchasePrice,
  //   required double salePrice,
  //   required double tax,
  //   required double netPrice,
  //   required String barcode,
  //   required String unit,
  //   required int quantity,
  //   required String expiryDate,
  //   required String managerId, // Add manager ID
  // }) async {
  //   await databaseRef.push().set({
  //     "itemId": id,
  //     "item_name": itemName,
  //     "purchase_price": purchasePrice,
  //     "sale_price": salePrice,
  //     "tax": tax,
  //     "net_price": netPrice,
  //     "barcode": barcode,
  //     "unit": unit,
  //     "quantity": quantity,
  //     "expiry_date": expiryDate,
  //     "manager_id": managerId, // Save manager ID
  //   });
  //
  //   notifyListeners(); // Notify listeners about the change
  // }
// Update existing item in the database

  Future<void> addItem({
    required String itemName,
    required double purchasePrice,
    required double salePrice,
    required double tax,
    required double netPrice,
    required String barcode,
    required String unit,
    required int quantity,
    required String expiryDate,
    required String managerId,
  }) async {
    // Get a new reference with a unique key
    final newItemRef = databaseRef.push();

    // Use the key (itemId) generated by Firebase
    final itemId = newItemRef.key;

    // Save the item data to Firebase using the generated itemId
    await newItemRef.set({
      "item_id": itemId, // Save the item ID
      "item_name": itemName,
      "purchase_price": purchasePrice,
      "sale_price": salePrice,
      "tax": tax,
      "net_price": netPrice,
      "barcode": barcode,
      "unit": unit,
      "quantity": quantity,
      "expiry_date": expiryDate,
      "manager_id": managerId,
    });

    // Optionally update the local _items list
    _items.add(Item(
      id: itemId!,
      itemName: itemName,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      tax: tax,
      netPrice: netPrice,
      barcode: barcode,
      unit: unit,
      quantity: quantity,
      expiryDate: expiryDate,
      managerId: managerId,
    ));

    notifyListeners(); // Notify listeners about the change
  }







  Future<void> updateItem({
    required String itemId,
    required String itemName,
    required double purchasePrice,
    required double salePrice,
    required double tax,
    required double netPrice,
    required String barcode,
    required String unit,
    required int quantity,
    required String expiryDate,
    required String managerId,
  }) async {
    // Find the item in the list and update it locally
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      // Update local list
      _items[index] = Item(
        id: itemId,
        itemName: itemName,
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        tax: tax,
        netPrice: netPrice,
        barcode: barcode,
        unit: unit,
        quantity: quantity,
        expiryDate: expiryDate,
        managerId: managerId,
      );

      // Update the item in Firebase using item_id node
      await databaseRef.child(itemId).update({
        "item_id": itemId, // Ensure item_id is updated if necessary
        "item_name": itemName,
        "purchase_price": purchasePrice,
        "sale_price": salePrice,
        "tax": tax,
        "net_price": netPrice,
        "barcode": barcode,
        "unit": unit,
        "quantity": quantity,
        "expiry_date": expiryDate,
        "manager_id": managerId, // Update the manager ID
      });

      notifyListeners(); // Notify listeners that data has changed
    }
  }


  Future<void> fetchItems() async {
    try {
      print("NEW");
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _items = data.entries.map((entry) {
            return Item.fromFirebase(entry.key, entry.value);
          }).toList();
        }
      }
      notifyListeners();
    } catch (error) {
      print("Failed to load items: $error");
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      // Delete the item from Firebase using its itemId
      await databaseRef.child(itemId).remove();

      // Also remove the item locally from the _items list
      _items.removeWhere((item) => item.id == itemId);

      notifyListeners(); // Notify listeners that an item has been deleted
    } catch (error) {
      print("Failed to delete item: $error");
    }
  }


}
