import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
class Item {
  final String id; // Unique identifier for the item
  final String name;
  final String genericName;
  final String barcode;
  final double sellingRate; // Add sellingRate
  final double landingCost; // Add landingCost

  Item({
    required this.id,
    required this.name,
    required this.genericName,
    required this.barcode,
    required this.sellingRate, // Add sellingRate to constructor
    required this.landingCost, // Add landingCost to constructor
  });
}
class SelectedItem {
  final String id; // Unique identifier for the item
  final String name;
  String discount;
  String discountType; // "percentage" or "amount"
  String taxType; // "percentage" or "amount"
  double tax; // Tax value as percentage or flat amount
  double sellingRate;
  double landingCost;
  int qty;

  SelectedItem({
    required this.id,
    required this.name,
    required this.discount,
    required this.discountType,
    required this.taxType,
    required this.tax,
    required this.sellingRate,
    required this.landingCost,
    required this.qty,
  });

  double get discountAmount {
    double discountValue = double.tryParse(discount) ?? 0.0;
    if (discountType == 'percentage') {
      return (landingCost * qty) * (discountValue / 100);
    } else {
      return discountValue * qty;
    }
  }

  double get taxAmount {
    double taxableAmount = landingCost * qty - discountAmount;
    double taxValue = tax ;

    if (taxType == 'percentage') {
      return taxableAmount * (taxValue / 100);
    } else {
      return taxValue * qty;
    }
  }

  double get totalExcludingTax {
    return (landingCost * qty) - discountAmount;
  }

  double get totalIncludingTax {
    return totalExcludingTax + taxAmount;
  }
}

class PurchaseProvider extends ChangeNotifier {
  final TextEditingController expiryDateController = TextEditingController();
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  List<String> suppliers = [];
  String? selectedSupplier;
  String? purchaseNumber;
  TextEditingController searchController = TextEditingController();
  List<Item> items = [];
  List<Item> filteredItems = [];
  List<Item> displayedItems = [];
  List<SelectedItem> selectedItems = [];
  double totalAmount = 0.0;
  double discountPercentage = 0.0; // Add this variable
  double cashPaid = 0.0; // Add this variable
  bool isEditing = false;
  List<Map<String, dynamic>> invoices = []; // List to hold invoice data


  PurchaseProvider() {
    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    expiryDateController.text = formattedDate;
    fetchSuppliers();
    fetchItems();
  }

  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }

  void updateDiscount(String value) {
    discountPercentage = double.tryParse(value) ?? 0.0;
    calculateTotal(); // Recalculate total when discount is updated
    notifyListeners(); // Notify listeners for UI updates
  }

  // Method to update cash paid
  void updateCashPaid(String value) {
    cashPaid = double.tryParse(value) ?? 0.0;
    notifyListeners(); // Notify listeners for UI updates
  }

  void searchItems(String query) {
    if (query.isEmpty) {
      displayedItems = items;
    } else {
      displayedItems = items
          .where((item) =>
          item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> fetchSuppliers() async {
    try {
      final DatabaseEvent event = await databaseRef.child('suppliers').once();
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> suppliersMap = snapshot.value as Map<
            dynamic,
            dynamic>;
        suppliers = suppliersMap.values
            .map<String>((supplier) =>
        supplier['name']?.toString() ?? 'Unnamed Supplier')
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching suppliers: $e');
    }
  }

  Future<void> fetchItems() async {
    try {
      final DatabaseEvent event = await databaseRef.child('items').once();
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> itemsMap = snapshot.value as Map<dynamic,
            dynamic>;
        items = itemsMap.values.map((item) {
          return Item(
            id: item['item_id'] ?? 'Unnamed Item Id',
            name: item['item_name'] ?? 'Unnamed Item',
            genericName: item['generic_name'] ?? 'Unnamed Generic',
            barcode: item['barcode'] ?? '000000',
            sellingRate: double.parse(item['net_price']?.toString() ?? '0.0'),
            landingCost: double.parse(
                item['purchase_price']?.toString() ?? '0.0'),
          );
        }).toList();
        filteredItems = List.from(items);
        displayedItems = List.from(items);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  void generatePurchaseNumber() {
    purchaseNumber = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    notifyListeners();
  }

  void updateSelectedItem(Item? item) {
    if (item != null) {
      bool itemExists = selectedItems.any((selectedItem) =>
      selectedItem.name == item.name);

      if (!itemExists) {
        selectedItems.add(SelectedItem(
          id: item.id,
          // Add the item ID here
          name: item.name,
          discount: '0',
          discountType: 'percentage',
          taxType: 'percentage',
          tax: 0.0,
          sellingRate: item.sellingRate,
          landingCost: item.landingCost,
          qty: 1,
        ));
        calculateTotal();
        notifyListeners();
      }
    }
  }

  void calculateTotal() {
    double totalBeforeDiscount = selectedItems.fold(
      0.0,
          (previousValue, item) => previousValue + item.totalIncludingTax,
    );

    // Calculate total after applying discount
    totalAmount = totalBeforeDiscount -
        (totalBeforeDiscount * (discountPercentage / 100));
  }

  double parseDiscount(String discount) {
    final cleanedDiscount = discount.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanedDiscount) ?? 0.0;
  }

  void updateSelectedItemField(int index, String field, String newValue) {
    SelectedItem selectedItem = selectedItems[index];
    switch (field) {
      case 'qty':
        selectedItem.qty = int.tryParse(newValue) ?? selectedItem.qty;
        break;
      case 'discount':
        selectedItem.discount = newValue;
        break;
      case 'tax':
        selectedItem.tax =
        newValue.isEmpty ? 0.0 : double.tryParse(newValue) ?? selectedItem.tax;
        // selectedItem.tax = double.tryParse(newValue) ?? selectedItem.tax;
        break;
      case 'sellingRate':
        selectedItem.sellingRate =
            double.tryParse(newValue) ?? selectedItem.sellingRate;
        break;
      case 'landingCost':
        selectedItem.landingCost =
            double.tryParse(newValue) ?? selectedItem.landingCost;
        break;
    }
    calculateTotal();
    notifyListeners();
  }

  void removeSelectedItem(int index) {
    selectedItems.removeAt(index);
    calculateTotal();
    notifyListeners();
  }

  Future<void> savePurchase() async {
    if (selectedSupplier == null || selectedItems.isEmpty) {
      print("Please select a supplier and add items to the purchase.");
      return;
    }

    try {
      // Generate a unique purchase ID
      String purchaseId = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();

      double remainingBalance = totalAmount - cashPaid;

      // Create a purchase entry
      Map<String, dynamic> purchaseData = {
        'supplier': selectedSupplier,
        'purchaseNumber': purchaseNumber,
        'date': expiryDateController.text,
        'totalAmount': totalAmount,
        'cashpaid': cashPaid,
        'remainingBalance': remainingBalance, // Add remaining balance here
        'items': [], // List to store item details
      };
      // Loop through selected items and add to purchase data
      for (var item in selectedItems) {
        purchaseData['items'].add({
          'itemId': item.id,
          'item_name': item.name,
          'qty': item.qty,
          'discountType': item.discountType,
          'discount': item.discount,
          'discountAmount': item.discountAmount,
          'taxType': item.taxType,
          'tax': item.tax,
          'taxAmount': item.taxAmount,
          'sellingRate': item.sellingRate,
          'landingCost': item.landingCost,
          'totalExcludingTax': item.totalExcludingTax,
          'totalIncludingTax': item.totalIncludingTax,
        });
      }

      // Save the purchase to the database
      await databaseRef.child('purchases/$purchaseId').set(purchaseData);

      // Clear all fields after saving
      clearPurchaseData();
      print("Purchase saved successfully.");
    } catch (e) {
      print("Error saving purchase: $e");
    }
  }

  // Method to clear all purchase-related data
  void clearPurchaseData() {
    selectedSupplier = null;
    purchaseNumber = null;
    totalAmount = 0.0;
    cashPaid = 0.0;
    selectedItems.clear();
    expiryDateController.clear();
    searchController.clear(); // If you want to clear search as well
    notifyListeners(); // Notify listeners to update UI
  }

  Future<void> fetchInvoices() async {
    try {
      final snapshot = await databaseRef.child('purchases').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        invoices = data.entries.map((entry) {
          final purchaseData = entry.value as Map<dynamic, dynamic>;
          final itemsList = purchaseData['items'] as List<dynamic>?;

          // Map each item to a more detailed structure
          List<Map<String, dynamic>> items = itemsList?.map((item) {
            final itemData = item as Map<dynamic, dynamic>;
            return {
              'discount': itemData['discount'] ?? '0',
              'discountAmount': itemData['discountAmount'] ?? 0,
              'discountType': itemData['discountType'] ?? '',
              'itemId': itemData['itemId'] ?? '',
              'item_name': itemData['item_name'] ?? '',
            };
          }).toList() ?? [];

          return {
            'supplier':(purchaseData['supplier'] ?? 'N/A'),
            'totalAmount': (purchaseData['totalAmount'] ?? 0) as int,
            'purchaseNumber': entry.key.toString(),
            'cashpaid': (purchaseData['cashpaid'] ?? 0) as int,
            'date': (purchaseData['date'] ?? '') as String,
            'items': items,
          };
        }).toList();
        notifyListeners();
      }
    } catch (error) {
      print('Failed to fetch invoices: $error');
    }
  }
}