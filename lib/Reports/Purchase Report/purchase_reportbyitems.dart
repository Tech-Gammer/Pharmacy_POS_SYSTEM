import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ItemPurchaseReportPage extends StatefulWidget {
  @override
  _ItemPurchaseReportPageState createState() => _ItemPurchaseReportPageState();
}

class _ItemPurchaseReportPageState extends State<ItemPurchaseReportPage> {
  List<Map<String, dynamic>> itemPurchases = [];

  @override
  void initState() {
    super.initState();
    fetchItemPurchases();
  }

  Future<void> fetchItemPurchases() async {
    DatabaseReference purchasesRef = FirebaseDatabase.instance.ref('purchases');
    final snapshot = await purchasesRef.get();
    if (snapshot.exists) {
      List<Map<String, dynamic>> tempItemPurchases = [];

      snapshot.children.forEach((purchaseSnapshot) {
        String purchaseNumber = purchaseSnapshot.child('purchaseNumber').value as String;
        String date = purchaseSnapshot.child('date').value as String;
        String supplier = purchaseSnapshot.child('supplier').value as String;

        // Iterate over items in each purchase
        purchaseSnapshot.child('items').children.forEach((itemSnapshot) {
          // Extract details for each item
          String itemName = itemSnapshot.child('item_name').value as String? ?? 'Unknown Item';
          int boxQty = itemSnapshot.child('box_qty').value as int? ?? 0;
          double landingCost = itemSnapshot.child('landingCost').value as double? ?? 0.0;

          tempItemPurchases.add({
            'purchaseNumber': purchaseNumber,
            'date': date,
            'supplier': supplier,
            'item_name': itemName,
            'box_qty': boxQty,
            'landingCost': landingCost,
          });
        });
      });

      setState(() {
        itemPurchases = tempItemPurchases;
      });
    }
  }

  Future<void> generatePdfReport() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Item Purchase Report', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Supplier',
                'Purchase Number',
                'Item Name',
                'Quantity',
                'landingCost',
              ],
              data: itemPurchases.map((itemPurchase) {
                return [
                  itemPurchase['date'],
                  itemPurchase['supplier'],
                  itemPurchase['purchaseNumber'],
                  itemPurchase['item_name'],
                  itemPurchase['box_qty'].toString(),
                  itemPurchase['landingCost'].toString(),
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Item Purchase Report'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: generatePdfReport,
          ),
        ],
      ),
      body: itemPurchases.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: itemPurchases.length,
        itemBuilder: (context, index) {
          final itemPurchase = itemPurchases[index];
          return ListTile(
            title: Text("Item: ${itemPurchase['item_name']}"),
            subtitle: Text(
              "Purchase No: ${itemPurchase['purchaseNumber']} | Date: ${itemPurchase['date']} | Supplier: ${itemPurchase['supplier']}\n"
                  "Quantity: ${itemPurchase['box_qty']} | Price: ${itemPurchase['landingCost']}",
            ),
          );
        },
      ),
    );
  }
}
