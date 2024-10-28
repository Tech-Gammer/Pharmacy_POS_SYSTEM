
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Use an alias for the pdf package
import 'package:printing/printing.dart';
import 'dart:html' as html; // Import for web functionalities
import 'package:flutter/foundation.dart'; // Import for kIsWeb

import '../Models/selecteditemmodel.dart';

class SaleProvider extends ChangeNotifier {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  final TextEditingController dialogSearchController = TextEditingController();
  final TextEditingController saleDateController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController cashReceivedController = TextEditingController();

  double remainingbalance = 0.0;
  TextEditingController searchController = TextEditingController();
  List<SelectedItem> selectedItems = [];
  List<Item> filteredItems = [];
  List<Item> displayedItems = [];
  List<Item> items = [];
  List<Item> allItems = []; // Full list of items
  double total = 0.0;
  double discount = 0.0; // Changed to double
  double cashReceived = 0.0;
  double grandTotalamount = 0.0;

  SaleProvider() {
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
        Map<dynamic, dynamic> itemsMap = snapshot.value as Map<dynamic, dynamic>;
        items = itemsMap.values.map((item) {
          return Item(
            id: item['item_id'] ?? 'Unnamed Item Id',
            name: item['item_name'] ?? 'Unnamed Item',
            genericName: item['generic_name'] ?? 'Unnamed Generic',
            barcode: item['barcode'] ?? '000000',
            sellingRate: double.parse(item['net_price']?.toString() ?? '0.0'),
            landingCost: double.parse(item['purchase_price']?.toString() ?? '0.0'),
            totalPiecesPerBox: item['total_pieces_per_box'] ?? 0,
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
      displayedItems = items.where((item) =>
      item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.barcode.toString().contains(query) ||
          item.genericName.toLowerCase().contains(query.toLowerCase())).toList();
    }
    notifyListeners();
  }

  void calculateTotal() {
    total = selectedItems.fold(0.0, (sum, item) {
      return sum + (item.ratePerTab ?? 0.0) * item.qty;
    });
    notifyListeners();
  }

  double get grandTotal {
    double discountAmount = total * discount / 100;
    return total - discountAmount;
  }

  void remainingBalance() {
    remainingbalance = grandTotal - cashReceived;
    notifyListeners();
  }

  void removeSelectedItem(int index) {
    selectedItems.removeAt(index);
    calculateTotal();
    notifyListeners();
  }

  void updateSelectedItem(Item item) {
    final existingItemIndex = selectedItems.indexWhere((selectedItem) => selectedItem.id == item.id);

    if (existingItemIndex != -1) {
      selectedItems[existingItemIndex].qty += 1;
    } else {
      selectedItems.add(SelectedItem(
        id: item.id,
        name: item.name,
        sellingRate: item.sellingRate,
        qty: 1,
        discount: '',
        discountType: '',
        taxType: '',
        tax: 0.0,
        landingCost: 0.0,
        totalPiecesPerBox: 0,
        ratePerTab: item.ratePerTab,
      ));
    }

    calculateTotal();
    notifyListeners();
  }

  // Get current user
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser; // Get current user
  }

  // Get current user ID
  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    return user != null ? user.uid : ''; // Return user ID or empty string if not logged in
  }
  // Get current user name
  Future<String> getCurrentUserName() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      String userId = user.uid; // Get user ID
      final DatabaseReference usersRef = FirebaseDatabase.instance.ref('users/$userId'); // Reference to user node

      // Fetch user data as a DatabaseEvent
      final DatabaseEvent event = await usersRef.once();
      final DataSnapshot snapshot = event.snapshot; // Get the DataSnapshot

      // Check if snapshot exists and retrieve user name
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        return userData['name'] ?? 'Unknown User'; // Assuming 'name' is the field storing the user's name
      }
    }
    return 'Guest'; // Default return if user is not found
  }


  void clearSaleData() {
    selectedItems.clear();
    saleDateController.clear();
    total = 0.0;
    discount = 0.0;
    cashReceived = 0.0;
    grandTotalamount = 0.0;
    remainingbalance = 0.0;
    // Clear controllers for discount and cash received
    discountController.clear();
    cashReceivedController.clear();
    notifyListeners();
  }


  // Future<String?> saveSaleAndGetId() async {
  //   if (selectedItems.isEmpty) {
  //     return '';
  //   }
  //
  //   // Generate a unique sale ID
  //   final saleId = databaseRef.child('sales').push().key;
  //
  //   final saleData = {
  //     'saleId': saleId, // Include the auto-generated sale ID
  //     'date': saleDateController.text,
  //     'items': selectedItems.map((item) => {
  //       'name': item.name,
  //       'price': item.ratePerTab.toString(),
  //       'quantity': item.qty.toString(),
  //       'subtotal': (item.ratePerTab * item.qty).toString(),
  //     }).toList(),
  //     'total': total.toString(),
  //     'discount': discount.toString(),
  //     'cashReceived': cashReceived.toString(),
  //     'grandTotal': grandTotal.toString(),
  //     'remainingBalance': remainingbalance.toString(),
  //     'userId': getCurrentUserId(), // Add current user ID
  //   };
  //
  //   try {
  //     // Save the sale data with the unique ID
  //     await databaseRef.child('sales').child(saleId!).set(saleData);
  //     notifyListeners();
  //     return saleId; // Return the sale ID
  //   } catch (e) {
  //     print('Error saving sale: $e');
  //     return '';
  //   }
  // }

  Future<String?> saveSale() async {
    if (selectedItems.isEmpty) {
      return null;
    }

    // Retrieve the last transaction ID
    final snapshot = await databaseRef.child('sales').limitToLast(1).get();
    int lastTransactionId = 0;

    if (snapshot.exists) {
      final lastSale = snapshot.value as Map<dynamic, dynamic>;
      final lastId = lastSale.entries.first.value['transactionID'];
      lastTransactionId = int.tryParse(lastId ?? '0') ?? 0;

    }

    // Generate the next transaction ID
    final newTransactionId = (lastTransactionId + 1).toString().padLeft(5, '0');

    final saleData = {
      'transactionID': newTransactionId,
      'date': saleDateController.text,
      'items': selectedItems.map((item) => {
        'name': item.name,
        'price': item.ratePerTab.toString(),
        'quantity': item.qty.toString(),
        'subtotal': (item.ratePerTab * item.qty).toString(),
      }).toList(),
      'total': total.toString(),
      'discount': discount.toString(),
      'cashReceived': cashReceived.toString(),
      'grandTotal': grandTotal.toString(),
      'remainingBalance': remainingbalance.toString(),
      'userId': getCurrentUserId(),
    };

    try {
      await databaseRef.child('sales').push().set(saleData);
      notifyListeners();
      return newTransactionId; // Return the transaction ID
    } catch (e) {
      print('Error saving sale: $e');
      return null;
    }
  }


  Future<void> saveAndPrint(BuildContext context) async {
    // Save the sale first and get the sale ID
    // String? saleId = await saveSaleAndGetId(); // Modify the saveSale method to return the sale ID
    // Call saveSale and retrieve the transaction ID
    String? transactionId = await saveSale();
    if (transactionId == null) {
      // Handle the error if the transaction ID wasn't generated (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save sale. Please try again.')),
      );
      return;
    }
    // Generate the PDF
    final pdf = pw.Document();
    // Get current date and time
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('MM/dd/yyyy').format(now); // Format the date
    final String formattedTime = DateFormat('hh:mm a').format(now); // Format the time
    String cashierName = await getCurrentUserName(); // Get the user name asynchronously
    double discountper = double.tryParse(discountController.text) ?? 0.0; // Get discount rate from controller
    double totalAfterDiscount = total - (total * (discountper / 100)); // Calculate total after applying the discount
    double totaldiscount = totalAfterDiscount - total;
    double posCharges = 1.0; // POS charges
    double grandTotal = totalAfterDiscount + posCharges; // Calculate grand total

    const pdfPageFormat = PdfPageFormat(80 * PdfPageFormat.mm, double.infinity); // 80 mm width, unlimited height

    // Add content to the PDF (customize as needed)
    pdf.addPage(
      pw.Page(
        pageFormat: pdfPageFormat, // Set the custom page format
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(10), // Add padding to all sides (adjust as needed)
          child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'Mughal Pharmacy',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(
              child: pw.Text('With Us, It\'s Most Personal'),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Store#: 1384'),
            pw.Text('Alam Chow Gujranwala'),
            pw.Text('Punjab Pakistan'),
            pw.Text('+92 307-6455926'),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Register #47', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Transaction #$transactionId', style: const pw.TextStyle(fontSize: 10)), // Display Sale ID
              ],
            ),
            pw.Text('Cashier: $cashierName', style: const pw.TextStyle(fontSize: 12)), // Display current user name
            pw.Text('Date: $formattedDate    Time: $formattedTime'), // Current date and time
            pw.Divider(),
            pw.Text('Items:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...selectedItems.map((item) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('${item.qty} x ${item.name} @ ${item.ratePerTab.toStringAsFixed(2)} rs'), // Display quantity, item name, and rate per tab
                pw.Text(' ${(item.ratePerTab * item.qty).toStringAsFixed(2)} rs'),
              ],
            )),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal'),
                pw.Text(' ${total.toStringAsFixed(2)} rs'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Discount'),
                pw.Text(' ${totaldiscount.toStringAsFixed(2)} rs'), // Total after discount
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('POS Charges'),
                pw.Text(' ${posCharges.toStringAsFixed(2)} rs'), // Show POS charges
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(' ${grandTotal.toStringAsFixed(2)} rs', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Cash Received'),
                pw.Text(' ${cashReceived.toStringAsFixed(2)} rs'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Remaining Balance'),
                pw.Text(' ${remainingbalance.toStringAsFixed(2)} rs'),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: '95543358064310030',
                width: 200,
                height: 60,
              ),
            ),
            pw.Center(
              child: pw.Text('THANKS FOR SHOPPING WITH US'),
            ),
          ],
        ),
      ),
      )
    );
    // Handle PDF download for web
    if (kIsWeb) {
      final pdfBytes = await pdf.save();
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'receipt_${DateTime.now()}.pdf')
        ..click();

      // Open the PDF in a new tab
      html.window.open(url, '_blank');

      // Revoke object URL to free memory
      html.Url.revokeObjectUrl(url);
      print(selectedItems);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF downloaded and opened successfully!')),
      );
      clearSaleData();

    } else {
      // For mobile, use the printing package
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    }

    notifyListeners(); // Notify listeners if there are changes
  }

}
