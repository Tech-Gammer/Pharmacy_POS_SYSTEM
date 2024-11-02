import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SalesReportPage extends StatefulWidget {
  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final databaseReference = FirebaseDatabase.instance.ref().child("sales");
  DateTimeRange? selectedDateRange;
  List<Map<String, dynamic>> salesData = [];
  List<Map<String, dynamic>> filteredSales = [];

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  void fetchSalesData() async {
    final snapshot = await databaseReference.get();
    if (snapshot.value != null) {
      Map<dynamic, dynamic> salesMap = snapshot.value as Map<dynamic, dynamic>;
      salesData = salesMap.entries.map((entry) {
        Map<String, dynamic> sale = Map<String, dynamic>.from(entry.value);
        sale['id'] = entry.key;
        return sale;
      }).toList();

      print(salesData); // Debugging: Check the data format here

      setState(() {
        filteredSales = salesData;
      });
    }
  }

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
      _filterSalesByDateRange();
    }
  }


  void _filterSalesByDateRange() {
    final dateFormat = DateFormat("dd/MM/yyyy"); // Define the date format

    filteredSales = salesData.where((sale) {
      try {
        // Parse the sale date with the specified format
        final saleDate = dateFormat.parse(sale['date']);

        // Include sales on the start and end dates
        return (saleDate.isAtSameMomentAs(selectedDateRange!.start) ||
            saleDate.isAtSameMomentAs(selectedDateRange!.end) ||
            (saleDate.isAfter(selectedDateRange!.start) &&
                saleDate.isBefore(selectedDateRange!.end)));
      } catch (e) {
        print("Error parsing date: ${sale['date']}");
        return false;
      }
    }).toList();

    setState(() {});
  }

  Future<void> generateSalesReportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Sales Report', style: const pw.TextStyle(fontSize: 24)),
            pw.Text('Date Range: ${selectedDateRange!.start} to ${selectedDateRange!.end}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Date', 'Transaction ID', 'Total', 'Cash Received', 'Remaining Balance'],
              data: filteredSales.map((sale) {
                return [
                  sale['date'],
                  sale['transactionID'],
                  sale['total'],
                  sale['cashReceived'],
                  sale['remainingBalance']
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
        title: const Text('Sales Report'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: filteredSales.isNotEmpty ? generateSalesReportPdf : null,
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
              style: const TextStyle(fontSize: 16),
            ),
            Expanded(
              child: filteredSales.isNotEmpty
                  ? ListView.builder(
                itemCount: filteredSales.length,
                itemBuilder: (context, index) {
                  final sale = filteredSales[index];
                  return Card(
                    child: ListTile(
                      title: Text('Transaction ID: ${sale['transactionID']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${sale['date']}'),
                          Text('Total: ${sale['total']}'),
                          Text('Cash Received: ${sale['cashReceived']}'),
                          Text('Remaining Balance: ${sale['remainingBalance']}'),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : const Center(child: Text('No sales found for the selected date range')),
            ),
          ],
        ),
      ),
    );
  }
}
