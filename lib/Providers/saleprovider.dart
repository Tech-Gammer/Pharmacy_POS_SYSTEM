
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Use an alias for the pdf package
// import 'package:printing/printing.dart';
import 'dart:html' as html; // Import for web functionalities
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import '../Models/selecteditemmodel.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/services.dart';
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
            totalPieces: item['total_pieces'] ?? 0, // Get total_pieces from database

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

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser; // Get current user
  }

  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser; // Get current user
    return user != null ? user.uid : ''; // Return user ID or empty string if not logged in
  }

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

  // Future<String?> saveSale(BuildContext context) async {
  //   if (selectedItems.isEmpty) {
  //     return null;
  //   }
  //
  //   // Retrieve the last transaction ID
  //   final snapshot = await databaseRef.child('sales').limitToLast(1).get();
  //   int lastTransactionId = 0;
  //
  //   if (snapshot.exists) {
  //     final lastSale = snapshot.value as Map<dynamic, dynamic>;
  //     final lastId = lastSale.entries.first.value['transactionID'];
  //     lastTransactionId = int.tryParse(lastId ?? '0') ?? 0;
  //   }
  //
  //   // Generate the next transaction ID
  //   final newTransactionId = (lastTransactionId + 1).toString();
  //   final currentDateTime = DateTime.now();
  //   final formattedDate = DateFormat('yyyy-MM-dd').format(currentDateTime); // Format date
  //   final formattedTime = DateFormat('HH:mm:ss').format(currentDateTime); // Format time
  //
  //   final saleData = {
  //     'transactionID': newTransactionId,
  //     'date': saleDateController.text,
  //     'time': formattedTime, // Add the formatted time
  //     'items': selectedItems.map((item) => {
  //       'itemID':item.id,
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
  //     'userId': getCurrentUserId(),
  //   };
  //
  //   // Check quantities before saving
  //   for (var item in selectedItems) {
  //     final itemRef = databaseRef.child('items/${item.id}');
  //     final itemSnapshot = await itemRef.get();
  //
  //     if (itemSnapshot.exists) {
  //       final itemData = itemSnapshot.value as Map<dynamic, dynamic>;
  //       int currentQuantity = itemData['total_pieces'] as int;
  //       int minimumQuantity = itemData['minimum_quantity'] as int;
  //
  //       // Check if the requested quantity exceeds the available quantity
  //       if (item.qty > currentQuantity) {
  //         showDialog(
  //           context: context,
  //           builder: (_) => AlertDialog(
  //             title: const Text("Insufficient Quantity"),
  //             content: Text("You cannot sell ${item.qty} of ${item.name} because only $currentQuantity pieces are available."),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: const Text("OK"),
  //               ),
  //             ],
  //           ),
  //         );
  //         return null;
  //       }
  //
  //       // Check if the quantity is zero
  //       if (currentQuantity == 0) {
  //         showDialog(
  //           context: context,
  //           builder: (_) => AlertDialog(
  //             title: const Text("Cannot Sell Item"),
  //             content: Text("You cannot sell ${item.name} because its quantity is zero."),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: const Text("OK"),
  //               ),
  //             ],
  //           ),
  //         );
  //         return null;
  //       }
  //
  //       // Check if the quantity is less than or equal to the minimum quantity
  //       if (currentQuantity <= minimumQuantity) {
  //         showDialog(
  //           context: context,
  //           builder: (_) => AlertDialog(
  //             title: const Text("Low Stock Warning"),
  //             content: Text("The quantity of ${item.name} is low (only $currentQuantity left)."),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: const Text("OK"),
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  //     }
  //   }
  //
  //   try {
  //     // Save the sale data
  //     await databaseRef.child('sales').push().set(saleData);
  //
  //     // Update the `total_pieces` in the `items` node
  //     for (var item in selectedItems) {
  //       final itemRef = databaseRef.child('items/${item.id}/total_pieces');
  //       final itemSnapshot = await itemRef.get();
  //
  //       if (itemSnapshot.exists) {
  //         int currentQuantity = itemSnapshot.value as int;
  //         int newQuantity = currentQuantity - item.qty;
  //
  //         // Ensure new quantity is not negative
  //         if (newQuantity < 0) newQuantity = 0;
  //
  //         await itemRef.set(newQuantity);
  //       }
  //     }
  //
  //     notifyListeners();
  //     return newTransactionId; // Return the transaction ID
  //   } catch (e) {
  //     print('Error saving sale: $e');
  //     return null;
  //   }
  // }
  //
  // Future<void> printReceipt() async {
  //   // Set up printer details (update with your printer IP and port)
  //   final printerIp = '192.168.0.100'; // Replace with actual printer IP if using network printing
  //   final printerPort = 9100; // Common port for network thermal printers
  //
  //   // Initialize printer connection
  //   final profile = await CapabilityProfile.load();
  //   final printer = NetworkPrinter(PaperSize.mm80, profile);
  //
  //   final PosPrintResult res = await printer.connect(printerIp, port: printerPort);
  //
  //   if (res == PosPrintResult.success) {
  //     // Start printing receipt content
  //     printer.text(
  //       'Mughal Pharmacy',
  //       styles: PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2, bold: true),
  //     );
  //     printer.text('With Us, It\'s Most Personal', styles: PosStyles(align: PosAlign.center));
  //     printer.text('Store#: 1384', styles: PosStyles(align: PosAlign.center));
  //     printer.text('Alam Chow Gujranwala, Punjab Pakistan', styles: PosStyles(align: PosAlign.center));
  //     printer.text('+92 307-6455926', styles: PosStyles(align: PosAlign.center));
  //     printer.hr(); // Divider line
  //
  //     // Transaction details (use your actual data here)
  //     final transactionId = '12345';
  //     final cashierName = 'John Doe';
  //     final dateTime = DateTime.now();
  //     final formattedDate = DateFormat('MM/dd/yyyy').format(dateTime);
  //     final formattedTime = DateFormat('hh:mm a').format(dateTime);
  //
  //     printer.text('Transaction #$transactionId');
  //     printer.text('Cashier: $cashierName');
  //     printer.text('Date: $formattedDate  Time: $formattedTime');
  //     printer.hr();
  //
  //     // Print itemized list of products
  //     // Sample items; replace with your `selectedItems` list.
  //     final selectedItems = [
  //       {'qty': 2, 'name': 'Aspirin', 'rate': 10.0, 'subtotal': 20.0},
  //       {'qty': 1, 'name': 'Bandage', 'rate': 5.0, 'subtotal': 5.0},
  //     ];
  //     for (var item in selectedItems) {
  //       printer.row([
  //         PosColumn(text: '${item['qty']} x ${item['name']}', width: 6),
  //         PosColumn(text: '${item['rate']} rs', width: 3, styles: PosStyles(align: PosAlign.right)),
  //         PosColumn(text: '${item['subtotal']} rs', width: 3, styles: PosStyles(align: PosAlign.right)),
  //       ]);
  //     }
  //
  //     printer.hr(); // Divider line
  //
  //     // Summary (subtotal, discount, etc.)
  //     final subtotal = 25.0;
  //     final discount = 5.0;
  //     final total = 20.0;
  //     final cashReceived = 50.0;
  //     final remainingBalance = 30.0;
  //
  //     printer.row([
  //       PosColumn(text: 'Subtotal', width: 6),
  //       PosColumn(text: '$subtotal rs', width: 6, styles: PosStyles(align: PosAlign.right)),
  //     ]);
  //     printer.row([
  //       PosColumn(text: 'Discount', width: 6),
  //       PosColumn(text: '$discount rs', width: 6, styles: PosStyles(align: PosAlign.right)),
  //     ]);
  //     printer.row([
  //       PosColumn(text: 'TOTAL', width: 6, styles: PosStyles(bold: true)),
  //       PosColumn(text: '$total rs', width: 6, styles: PosStyles(align: PosAlign.right, bold: true)),
  //     ]);
  //     printer.row([
  //       PosColumn(text: 'Cash Received', width: 6),
  //       PosColumn(text: '$cashReceived rs', width: 6, styles: PosStyles(align: PosAlign.right)),
  //     ]);
  //     printer.row([
  //       PosColumn(text: 'Remaining Balance', width: 6),
  //       PosColumn(text: '$remainingBalance rs', width: 6, styles: PosStyles(align: PosAlign.right)),
  //     ]);
  //
  //     printer.hr();
  //     printer.text('THANKS FOR SHOPPING WITH US', styles: PosStyles(align: PosAlign.center, bold: true));
  //
  //     // Add QR or barcode if required
  //     printer.qrcode('https://mughalpharmacy.example.com'); // Replace with your own data
  //
  //     printer.feed(2); // Add some space at the end
  //     printer.cut(); // Cut the paper
  //
  //     // Disconnect printer
  //     printer.disconnect();
  //   } else {
  //     print('Failed to connect to printer: $res');
  //   }
  // }


  Future<String?> saveSale(BuildContext context) async {
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
    final newTransactionId = (lastTransactionId + 1).toString();
    final currentDateTime = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDateTime); // Format date
    final formattedTime = DateFormat('HH:mm:ss').format(currentDateTime); // Format time

    final saleData = {
      'transactionID': newTransactionId,
      'date': formattedDate,
      'time': formattedTime, // Add the formatted time
      'items': selectedItems.map((item) => {
        'itemID': item.id,
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

    // Check quantities before saving
    for (var item in selectedItems) {
      final itemRef = databaseRef.child('items/${item.id}');
      final itemSnapshot = await itemRef.get();

      if (itemSnapshot.exists) {
        final itemData = itemSnapshot.value as Map<dynamic, dynamic>;
        int currentQuantity = itemData['total_pieces'] as int;
        int minimumQuantity = itemData['minimum_quantity'] as int;

        // Check if the requested quantity exceeds the available quantity
        if (item.qty > currentQuantity) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Insufficient Quantity"),
              content: Text("You cannot sell ${item.qty} of ${item.name} because only $currentQuantity pieces are available."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
          return null;
        }

        // Check if the quantity is zero
        if (currentQuantity == 0) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Cannot Sell Item"),
              content: Text("You cannot sell ${item.name} because its quantity is zero."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
          return null;
        }

        // Check if the quantity is less than or equal to the minimum quantity
        if (currentQuantity <= minimumQuantity) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Low Stock Warning"),
              content: Text("The quantity of ${item.name} is low (only $currentQuantity left)."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    }

    try {
      // Save the sale data
      await databaseRef.child('sales').push().set(saleData);

      // Update the `total_pieces` in the `items` node
      for (var item in selectedItems) {
        final itemRef = databaseRef.child('items/${item.id}/total_pieces');
        final itemSnapshot = await itemRef.get();

        if (itemSnapshot.exists) {
          int currentQuantity = itemSnapshot.value as int;
          int newQuantity = currentQuantity - item.qty;

          // Ensure new quantity is not negative
          if (newQuantity < 0) newQuantity = 0;

          await itemRef.set(newQuantity);
        }
      }

      notifyListeners();

      // Print receipt after saving
      await printReceipt(newTransactionId, saleData);

      return newTransactionId; // Return the transaction ID
    } catch (e) {
      print('Error saving sale: $e');
      return null;
    }
  }

  Future<void> printReceipt(String transactionId, Map<String, dynamic> saleData) async {
    // Set up printer details (update with your printer IP and port)
    final printerIp = '192.168.0.100'; // Replace with actual printer IP if using network printing
    final printerPort = 9100; // Common port for network thermal printers

    // Initialize printer connection
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);

    final PosPrintResult res = await printer.connect(printerIp, port: printerPort);

    if (res == PosPrintResult.success) {
      // Start printing receipt content
      printer.text(
        'Mughal Pharmacy',
        styles: PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2, bold: true),
      );
      printer.text('With Us, It\'s Most Personal', styles: PosStyles(align: PosAlign.center));
      printer.text('Store#: 1384', styles: PosStyles(align: PosAlign.center));
      printer.text('Alam Chow Gujranwala, Punjab Pakistan', styles: PosStyles(align: PosAlign.center));
      printer.text('+92 307-6455926', styles: PosStyles(align: PosAlign.center));
      printer.hr(); // Divider line

      // Transaction details
      final cashierName = 'John Doe'; // Replace with actual cashier name if needed
      final dateTime = DateTime.now();
      final formattedDate = DateFormat('MM/dd/yyyy').format(dateTime);
      final formattedTime = DateFormat('hh:mm a').format(dateTime);

      printer.text('Transaction #$transactionId');
      printer.text('Cashier: $cashierName');
      printer.text('Date: $formattedDate  Time: $formattedTime');
      printer.hr();

      // Print itemized list of products using saleData['items']
      for (var item in saleData['items']) {
        printer.row([
          PosColumn(text: '${item['quantity']} x ${item['name']}', width: 6),
          PosColumn(text: '${item['price']} rs', width: 3, styles: PosStyles(align: PosAlign.right)),
          PosColumn(text: '${item['subtotal']} rs', width: 3, styles: PosStyles(align: PosAlign.right)),
        ]);
      }

      printer.hr(); // Divider line

      // Summary (subtotal, discount, etc.)
      printer.row([
        PosColumn(text: 'TOTAL', width: 6, styles: PosStyles(bold: true)),
        PosColumn(text: '${saleData['grandTotal']} rs', width: 6, styles: PosStyles(align: PosAlign.right, bold: true)),
      ]);
      printer.row([
        PosColumn(text: 'Cash Received', width: 6),
        PosColumn(text: '${saleData['cashReceived']} rs', width: 6, styles: PosStyles(align: PosAlign.right)),
      ]);
      printer.row([
        PosColumn(text: 'Remaining Balance', width: 6),
        PosColumn(text: '${saleData['remainingBalance']} rs', width: 6, styles: PosStyles(align: PosAlign.right)),
      ]);

      printer.hr();
      printer.text('THANKS FOR SHOPPING WITH US', styles: PosStyles(align: PosAlign.center, bold: true));

      // Add QR or barcode if required
      printer.qrcode('https://mughalpharmacy.example.com'); // Replace with your own data

      printer.feed(2); // Add some space at the end
      printer.cut(); // Cut the paper

      // Disconnect printer
      printer.disconnect();
    } else {
      print('Failed to connect to printer: $res');
    }
  }


  // Future<void> saveAndPrint(BuildContext context) async {
  //
  //   String? transactionId = await saveSale(context);
  //   if (transactionId == null) {
  //     // Handle the error if the transaction ID wasn't generated (e.g., show an error message)
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to save sale. Please try again.')),
  //     );
  //     return;
  //   }
  //   // Generate the PDF
  //   final pdf = pw.Document();
  //   // Get current date and time
  //   final DateTime now = DateTime.now();
  //   final String formattedDate = DateFormat('MM/dd/yyyy').format(now); // Format the date
  //   final String formattedTime = DateFormat('hh:mm a').format(now); // Format the time
  //   String cashierName = await getCurrentUserName(); // Get the user name asynchronously
  //   double discountper = double.tryParse(discountController.text) ?? 0.0; // Get discount rate from controller
  //   double totalAfterDiscount = total - (total * (discountper / 100)); // Calculate total after applying the discount
  //   double totaldiscount = totalAfterDiscount - total;
  //   double posCharges = 1.0; // POS charges
  //   double grandTotal = totalAfterDiscount + posCharges; // Calculate grand total
  //
  //   const pdfPageFormat = PdfPageFormat(70 * PdfPageFormat.mm, double.infinity); // 80 mm width, unlimited height
  //
  //   // Add content to the PDF (customize as needed)
  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: pdfPageFormat, // Set the custom page format
  //       build: (pw.Context context) => pw.Padding(
  //         padding: const pw.EdgeInsets.all(10), // Add padding to all sides (adjust as needed)
  //         child: pw.Column(
  //         crossAxisAlignment: pw.CrossAxisAlignment.start,
  //         children: [
  //           pw.Center(
  //             child: pw.Text(
  //               'Mughal Pharmacy',
  //               style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
  //             ),
  //           ),
  //           pw.Center(
  //             child: pw.Text('With Us, It\'s Most Personal'),
  //           ),
  //           pw.SizedBox(height: 10),
  //           pw.Text('Store#: 1384',style: const pw.TextStyle(fontSize: 10)),
  //           pw.Text('Alam Chow Gujranwala',style: const pw.TextStyle(fontSize: 10)),
  //           pw.Text('Punjab Pakistan',style: const pw.TextStyle(fontSize: 10)),
  //           pw.Text('+92 307-6455926',style: const pw.TextStyle(fontSize: 10)),
  //           pw.SizedBox(height: 10),
  //           pw.Text('Register #47', style: const pw.TextStyle(fontSize: 10)),
  //           pw.Text('Transaction #$transactionId', style: const pw.TextStyle(fontSize: 10)),
  //           pw.Text('Cashier: $cashierName', style: const pw.TextStyle(fontSize: 10)), // Display current user name
  //           pw.Text('Date: $formattedDate    Time: $formattedTime',style: const pw.TextStyle(fontSize: 10)), // Current date and time
  //           pw.Divider(),
  //           pw.Text('Items:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //           ...selectedItems.map((item) => pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text('${item.qty} x ${item.name} @ ${item.ratePerTab.toStringAsFixed(2)} rs',style: const pw.TextStyle(fontSize: 10)), // Display quantity, item name, and rate per tab
  //               pw.Text(' ${(item.ratePerTab * item.qty).toStringAsFixed(2)} rs',style: const pw.TextStyle(fontSize: 10)),
  //             ],
  //           )),
  //           pw.Divider(),
  //           pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text('Subtotal'),
  //               pw.Text(' ${total.toStringAsFixed(2)} rs'),
  //             ],
  //           ),
  //           pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text('Discount'),
  //               pw.Text(' ${totaldiscount.toStringAsFixed(2)} rs'), // Total after discount
  //             ],
  //           ),
  //           pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text('POS Charges'),
  //               pw.Text(' ${posCharges.toStringAsFixed(2)} rs'), // Show POS charges
  //             ],
  //           ),
  //           pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //               pw.Text(' ${grandTotal.toStringAsFixed(2)} rs', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             ],
  //           ),
  //           pw.SizedBox(height: 10),
  //           pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text('Cash Received'),
  //               pw.Text(' ${cashReceived.toStringAsFixed(2)} rs'),
  //             ],
  //           ),
  //           pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text('Remaining Balance'),
  //               pw.Text(' ${remainingbalance.toStringAsFixed(2)} rs'),
  //             ],
  //           ),
  //           pw.SizedBox(height: 10),
  //           pw.Center(
  //             child: pw.BarcodeWidget(
  //               barcode: pw.Barcode.code128(),
  //               data: '95543358064310030',
  //               width: 150,
  //               height: 50,
  //             ),
  //           ),
  //           pw.Center(
  //             child: pw.Text('THANKS FOR SHOPPING WITH US', style: const pw.TextStyle(fontSize: 8)),
  //           ),
  //         ],
  //       ),
  //     ),
  //     )
  //   );
  //   // Handle PDF download for web
  //   if (kIsWeb) {
  //     final pdfBytes = await pdf.save();
  //     final blob = html.Blob([pdfBytes], 'application/pdf');
  //     final url = html.Url.createObjectUrlFromBlob(blob);
  //     final anchor = html.AnchorElement(href: url)
  //       ..setAttribute('download', 'receipt_${DateTime.now()}.pdf')
  //       ..click();
  //
  //     // Open the PDF in a new tab
  //     html.window.open(url, '_blank');
  //
  //     // Revoke object URL to free memory
  //     html.Url.revokeObjectUrl(url);
  //     print(selectedItems);
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('PDF downloaded and opened successfully!')),
  //     );
  //     clearSaleData();
  //
  //   } else {
  //     // For mobile, use the printing package
  //     await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  //   }
  //
  //   notifyListeners(); // Notify listeners if there are changes
  // }

//sadjasakl


  Future<Map<String, dynamic>?> getSaleByTransactionId(String transactionId) async {
    final snapshot = await databaseRef.child('sales').get();

    if (snapshot.exists) {
      final salesMap = snapshot.value as Map<dynamic, dynamic>;

      for (var key in salesMap.keys) {
        final sale = salesMap[key] as Map<dynamic, dynamic>;

        if (sale['transactionID'] == transactionId) {
          return sale.cast<String, dynamic>(); // Ensure correct type
        }
      }
    }
    return null; // Return null if no sale found with the given transactionID
  }

  Future<void> returnItem(String transactionId, String itemId, int quantity) async {
    final saleRef = databaseRef.child('sales');
    final itemRef = databaseRef.child('items/$itemId/total_pieces');

    // Step 1: Get the sale details by transaction ID
    final saleSnapshot = await saleRef.orderByChild('transactionID').equalTo(transactionId).get();

    if (saleSnapshot.exists) {
      final salesMap = saleSnapshot.value as Map<dynamic, dynamic>;

      for (var key in salesMap.keys) {
        final sale = salesMap[key] as Map<dynamic, dynamic>;
        final items = sale['items'] as List<dynamic>;

        // Step 2: Update the item quantities
        for (var item in items) {
          if (item['itemID'] == itemId) {
            int currentQuantity = int.tryParse(item['quantity'].toString()) ?? 0;
            int newQuantity = currentQuantity - quantity;

            if (newQuantity < 0) {
              throw Exception("Cannot return more than sold. Available: $currentQuantity, Attempted: $quantity");
            }

            item['quantity'] = newQuantity.toString();
            item['subtotal'] = (newQuantity * double.parse(item['price'])).toString(); // Update item subtotal

            await saleRef.child(key).update({'items': items}); // Update the sale with new quantities

            // Update the total pieces in the items node
            final itemSnapshot = await itemRef.get();
            if (itemSnapshot.exists) {
              int currentTotalPieces = int.tryParse(itemSnapshot.value.toString()) ?? 0;
              await itemRef.set(currentTotalPieces + quantity); // Add returned quantity to total pieces
            }
            // Step 3: Add return date and time
            String returnDateTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
            // String returnTime = DateFormat('HH:mm:ss').format(DateTime.now());

            await saleRef.child(key).update({
              'returnDateTime': returnDateTime,
              // 'returnTime': returnTime,
            });

            // Step 4: Recalculate the totals
            await _recalculateSaleTotals(saleRef, key, items, sale['cashReceived'], sale['discount']);
            break; // Exit after updating the matched item
          }
        }
      }

      notifyListeners(); // Update the UI to reflect changes in totals
    } else {
      throw Exception("Sale not found for transaction ID $transactionId");
    }
  }

  Future<void> _recalculateSaleTotals(DatabaseReference saleRef, String saleKey, List<dynamic> items, String cashReceived, String discount) async {
    double total = 0.0;
    // Calculate the new total based on updated item quantities and prices
    for (var item in items) {
      int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      total += price * quantity;
    }

    // Parse discount and cashReceived from strings
    // double discountAmount = double.tryParse(discount) ?? 0.0;
    double discountPercentage = double.tryParse(discount) ?? 0.0;
    double cashReceivedAmount = double.tryParse(cashReceived) ?? 0.0;

    // Calculate discount amount based on percentage
    double discountAmount = (total * discountPercentage) / 100;

    // Calculate grand total
    double grandTotal = total - discountAmount;
    double remainingBalance = cashReceivedAmount - grandTotal;
    String returnDateTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    // Step 4: Update the sale record in the database
    await saleRef.child(saleKey).update({
      'returnDateTime': returnDateTime,
      'total': total.toString(),
      'grandTotal': grandTotal.toString(),
      'remainingBalance': remainingBalance.toString(),
      'cashReceived': cashReceivedAmount.toString(), // if cashReceived needs updating
      'items': items, // Update all items with new subtotal values
      // Add any other necessary updates here
    });
  }
}
