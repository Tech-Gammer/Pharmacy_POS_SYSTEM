import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SalesReportByItemPage extends StatefulWidget {
  @override
  _SalesReportByItemPageState createState() => _SalesReportByItemPageState();
}

class _SalesReportByItemPageState extends State<SalesReportByItemPage> {
  final databaseReference = FirebaseDatabase.instance.ref().child("sales");
  DateTimeRange? selectedDateRange;
  Map<String, Map<String, dynamic>> itemSalesData = {};

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

// Fetch and aggregate sales data by item from Firebase
  void fetchSalesData() async {
    final snapshot = await databaseReference.get();
    if (snapshot.value != null) {
      Map<dynamic, dynamic> salesMap = snapshot.value as Map<dynamic, dynamic>;

      // Initialize item sales data
      Map<String, Map<String, dynamic>> tempItemSalesData = {};

      salesMap.forEach((key, sale) {
        Map<String, dynamic> saleData = Map<String, dynamic>.from(sale);

        // Check if the sale date is within the selected date range
        final dateFormat = DateFormat("dd/MM/yyyy");
        final saleDate = dateFormat.parse(saleData['date']);

        if (selectedDateRange == null ||
            (saleDate.isAtSameMomentAs(selectedDateRange!.start) || saleDate.isAtSameMomentAs(selectedDateRange!.end) ||
                (saleDate.isAfter(selectedDateRange!.start) && saleDate.isBefore(selectedDateRange!.end)))) {

          List<dynamic> items = saleData['items'] ?? [];
          for (var item in items) {
            String itemName = item['name'];

            // Convert quantity and price to int or double as needed
            int itemQuantity = int.tryParse(item['quantity'].toString()) ?? 0;
            double itemPrice = double.tryParse(item['price'].toString()) ?? 0.0;
            double itemTotalPrice = itemPrice * itemQuantity;

            if (tempItemSalesData.containsKey(itemName)) {
              tempItemSalesData[itemName]!['totalQuantity'] += itemQuantity;
              tempItemSalesData[itemName]!['totalSales'] += itemTotalPrice;
            } else {
              tempItemSalesData[itemName] = {
                'totalQuantity': itemQuantity,
                'totalSales': itemTotalPrice,
              };
            }
          }
        }
      });

      setState(() {
        itemSalesData = tempItemSalesData;
      });
    }
  }

  // Function to show date range picker and fetch filtered sales data
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      fetchSalesData();
    }
  }

  // Function to generate PDF report for the item sales data
  Future<void> generateItemSalesReportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Sales Report By Item', style: pw.TextStyle(fontSize: 24)),
            if (selectedDateRange != null)
              pw.Text(
                  'Date Range: ${selectedDateRange!.start.toString().split(' ')[0]} to ${selectedDateRange!.end.toString().split(' ')[0]}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Item Name', 'Total Quantity', 'Total Sales'],
              data: itemSalesData.entries.map((entry) {
                return [
                  entry.key,
                  entry.value['totalQuantity'],
                  entry.value['totalSales'].toStringAsFixed(2)
                ];
              }).toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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
        title: Text('Sales Report By Item'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: itemSalesData.isNotEmpty ? generateItemSalesReportPdf : null,
            tooltip: 'Generate PDF Report',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              selectedDateRange != null
                  ? 'Selected Date Range: ${selectedDateRange!.start.toString().split(' ')[0]} - ${selectedDateRange!.end.toString().split(' ')[0]}'
                  : 'No Date Range Selected',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Expanded(
              child: itemSalesData.isNotEmpty
                  ? ListView.builder(
                itemCount: itemSalesData.length,
                itemBuilder: (context, index) {
                  String itemName = itemSalesData.keys.elementAt(index);
                  int totalQuantity = itemSalesData[itemName]!['totalQuantity'];
                  double totalSales = itemSalesData[itemName]!['totalSales'];

                  return Card(
                    child: ListTile(
                      title: Text('Item: $itemName'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Quantity Sold: $totalQuantity'),
                          Text('Total Sales: ${totalSales.toStringAsFixed(2)}rs'),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : Center(child: Text('No sales data found for the selected date range')),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: itemSalesData.isNotEmpty ? generateItemSalesReportPdf : null,
              child: Text('Generate PDF Report'),
            ),
          ],
        ),
      ),
    );
  }
}
