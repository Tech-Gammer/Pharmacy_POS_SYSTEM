import 'package:flutter/material.dart';

class PurchasePage extends StatefulWidget {
  @override
  _PurchasePageState createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Top Section
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Supplier'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'search Supplier',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Invoice Date'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '26-10-2024',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Invoice No'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '001',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Data Table for Products
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Product')),
                    DataColumn(label: Text('Discount')),
                    DataColumn(label: Text('Selling Rate')),
                    DataColumn(label: Text('Landing Cost')),
                    DataColumn(label: Text('Rate')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Unit')),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('Panadol 100')),
                      DataCell(Text('0%')),
                      DataCell(Text('600.00')),
                      DataCell(Text('500.00')),
                      DataCell(TextField()), // Editable Rate
                      DataCell(Text('1')),
                      DataCell(Text('500.00')),
                      DataCell(Text('Box')),
                    ]),
                  ],
                ),
              ),
            ),

            // Bottom Section
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Discount %'),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '0.00%',
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cash Paid'),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '0.00',
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount'),
                    Text('500.00'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}