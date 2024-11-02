import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PurchaseTotal extends StatefulWidget {
  @override
  _PurchaseTotalState createState() => _PurchaseTotalState();
}

class _PurchaseTotalState extends State<PurchaseTotal> {
  List<Map<String, dynamic>> purchases = [];
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    DatabaseReference purchasesRef = FirebaseDatabase.instance.ref('purchases');
    final snapshot = await purchasesRef.get();
    if (snapshot.exists) {
      List<Map<String, dynamic>> tempPurchases = [];
      snapshot.children.forEach((purchaseSnapshot) {
        // Get the date of the purchase from Firebase and try to parse it
        String dateStr = purchaseSnapshot.child('date').value as String;
        DateTime? purchaseDate;

        try {
          purchaseDate = DateFormat('dd/MM/yyyy').parse(dateStr);
        } catch (e) {
          print("Date parsing error: $e");
          return; // Skip this record if date parsing fails
        }

        // Check if the purchase date is within the selected date range, or show all if no range selected
        if (selectedDateRange == null ||
            (purchaseDate.isAtSameMomentAs(selectedDateRange!.start) || purchaseDate.isAfter(selectedDateRange!.start)) &&
                (purchaseDate.isAtSameMomentAs(selectedDateRange!.end) || purchaseDate.isBefore(selectedDateRange!.end))) {
          tempPurchases.add({
            'box_qty': purchaseSnapshot.child('box_qty').value,
            'cashpaid': purchaseSnapshot.child('cashpaid').value,
            'date': dateStr,
            'purchaseNumber': purchaseSnapshot.child('purchaseNumber').value,
            'remainingBalance': purchaseSnapshot.child('remainingBalance').value,
            'supplier': purchaseSnapshot.child('supplier').value,
            'totalAmount': purchaseSnapshot.child('totalAmount').value,
            'total_pieces': purchaseSnapshot.child('total_pieces').value,
          });
        }
      });

      // Update the purchases list
      setState(() {
        purchases = tempPurchases;
      });
    }
  }

  Future<void> selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      fetchPurchases();
    }
  }

  Future<void> generatePdfReport() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Purchase Report', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 10),
            selectedDateRange != null
                ? pw.Text("Date Range: ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)}")
                : pw.Text("All Dates"),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Supplier',
                'Purchase Number',
                'Total Amount',
                'Cash Paid',
                'Remaining Balance',
                'Total Pieces',
              ],
              data: purchases.map((purchase) {
                return [
                  purchase['date'],
                  purchase['supplier'],
                  purchase['purchaseNumber'],
                  purchase['totalAmount'],
                  purchase['cashpaid'],
                  purchase['remainingBalance'],
                  purchase['total_pieces'],
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
        title: Text('Purchase Report'),
        backgroundColor: Colors.teal,

        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: selectDateRange,
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: generatePdfReport,
          ),
        ],
      ),
      body: Column(
        children: [
          selectedDateRange != null
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Selected Date Range: ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDateRange!.end)}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
              : Container(),
          purchases.isEmpty
              ? Expanded(child: Center(child: Text("No purchases found for the selected date range")))
              : Expanded(
            child: ListView.builder(
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final purchase = purchases[index];
                return ListTile(
                  title: Text("Purchase Number: ${purchase['purchaseNumber']}"),
                  subtitle: Text("Date: ${purchase['date']} | Supplier: ${purchase['supplier']}"),
                  trailing: Text("Total: ${purchase['totalAmount']}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
