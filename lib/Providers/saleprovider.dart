
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../Models/selecteditemmodel.dart';

class saleProvider extends ChangeNotifier{
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  final TextEditingController dialogSearchController = TextEditingController();
  final TextEditingController saleDateController = TextEditingController();

  double remainingbalance = 0 ;
  TextEditingController searchController = TextEditingController();
  List<SelectedItem> selectedItems = [];
  List<Item> filteredItems = [];
  List<Item> displayedItems = [];
  List<Item> items = [];
  List<Item> allItems = []; // Full list of items
  double total = 0.0; // Add this line
  String discount = '0'; // To store discount percentage
  double cashReceived = 0.0; // To store cash received
  double grandTotalamount = 0.0;






  saleProvider() {
    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    saleDateController.text = formattedDate;
    fetchItems();
  }


  double calculateBalance() {
    return cashReceived - total; // Calculate the balance
  }

  void initializeDialogItems() {
    filteredItems = List.from(allItems);
    notifyListeners();
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
            landingCost: double.parse(item['purchase_price']?.toString() ?? '0.0'),
            totalPiecesPerBox: item['total_pieces_per_box'] ?? 0, // Provide totalPiecesPerBox value here
            ratePerTab: double.parse(item['ratePerTab']?.toString() ?? '0.0'),
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

  void searchItems(String query) {
    if (query.isEmpty) {
      displayedItems = items;
    } else {
      displayedItems = items
          .where((item) =>
      item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.barcode.toString().contains(query) ||
          item.genericName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

// Method to calculate total from selected items
  void calculateTotal() {
    total = selectedItems.fold(0.0, (sum, item) {
      return sum + (item.ratePerTab ?? 0.0) * item.qty;
    });
    notifyListeners(); // Notify listeners about the change
  }


  double get grandTotal {
    double discountAmount = total * (double.tryParse(discount) ?? 0) / 100;
    return total - discountAmount; // Total after discount
  }

  // Calculate remaining balance
  void  remainingBalance() {
     remainingbalance =     grandTotal - cashReceived; // Cash received minus total after discount
    notifyListeners();
  }


  void removeSelectedItem(int index) {
    selectedItems.removeAt(index);
    calculateTotal();
    notifyListeners();
  }

  void updateSelectedItem(Item item) {
    // Check if the item is already in selectedItems
    final existingItemIndex = selectedItems.indexWhere((selectedItem) => selectedItem.id == item.id);

    if (existingItemIndex != -1) {
      // Item exists, increment the quantity
      selectedItems[existingItemIndex].qty += 1; // Use += to increment the quantity
    } else {
      // Item does not exist, add to the list
      selectedItems.add(SelectedItem(
        id: item.id,
        name: item.name,
        sellingRate: item.sellingRate,
        qty: 1, // Default quantity
        discount: '', // Default discount
        discountType: '', // Default discount type
        taxType: '', // Default tax type
        tax: 0.0, // Default tax
        landingCost: 0.0, // Default landing cost
        totalPiecesPerBox: 0, // Default total pieces per box
        ratePerTab: item.ratePerTab, // Assign the selling rate or any other logic here
      ));
    }

    calculateTotal(); // Recalculate total after adding/updating an item
    notifyListeners(); // Notify listeners about the change
  }


  // Reference to Firebase Realtime Database

  // Method to save a sale
  Future<void> saveSale() async {
    if (selectedItems.isEmpty) {
      // Show an error message if there are no items selected
      return;
    }

    // Create a sale record object
    final saleData = {
      'date': saleDateController.text,
      'items': selectedItems.map((item) => {
        'name': item.name,
        'price': item.ratePerTab,
        'quantity': item.qty,
        'subtotal': item.ratePerTab * item.qty,
      }).toList(),
      'total': total,
      'discount': discount,
      'cashReceived': cashReceived,
      'grandTotal': grandTotal,
      'remainingBalance': remainingbalance,
    };

    // Save to Firebase Realtime Database
    try {
      await databaseRef.child('sales').push().set(saleData);
      // Optionally clear or reset fields after saving
      clearSaleData();
      notifyListeners(); // Notify listeners to rebuild UI
    } catch (e) {
      // Handle errors (e.g., show a message)
      print('Error saving sale: $e');
    }
  }

  // Method to save and print
  Future<void> saveAndPrint() async {
    await saveSale(); // First save the sale
    // await printSaleDetails(); // Print after saving
  }

  void clearSaleData() {
    selectedItems.clear();
    saleDateController.clear();
    total = 0.0;
    discount = 0.0 as String;
    cashReceived = 0.0;
    grandTotalamount = 0.0;
    remainingbalance = 0.0;
    notifyListeners(); // Notify listeners to update UI
  }


}