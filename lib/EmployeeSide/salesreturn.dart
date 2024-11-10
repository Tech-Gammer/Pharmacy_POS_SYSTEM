import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/saleprovider.dart'if (kIsWeb) 'saleprovider_other.dart';
// import 'saleprovider_web.dart' if (kIsWeb) 'saleprovider_other.dart';
class SalesReturnSearchScreen extends StatelessWidget {
  final TextEditingController saleIdController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/employeepage');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Sales Return'),
        backgroundColor: Colors.teal,
      ),      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: saleIdController,
              decoration: const InputDecoration(labelText: 'Transaction ID'),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Sale Date'),
              readOnly: true,
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  dateController.text = date.toIso8601String();
                }
              },
            ),
            ElevatedButton(
              onPressed: () async {
                final transactionId = saleIdController.text;
                final saleProvider = Provider.of<SaleProvider>(context, listen: false);
                final saleData = await saleProvider.getSaleByTransactionId(transactionId);

                if (saleData != null) {
                 // Navigate to a new screen to show sale details
                  Navigator.push(
                     context, MaterialPageRoute(
                              builder: (context) => SaleDetailsScreen(saleData: saleData),
                            ),
                          );
                } else {
                  // Display error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No sale found with Transaction ID $transactionId')),
                  );
                }
              },
              child: const Text('Search Sale'),
            ),

          ],
        ),
      ),
    );
  }
}

class SaleDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> saleData;

  SaleDetailsScreen({required this.saleData});

  @override
  Widget build(BuildContext context) {
    final items = saleData['items'] as List<dynamic>? ?? [];
    final saleProvider = Provider.of<SaleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Sale Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${saleData['transactionID']}'),
            Text('Date: ${saleData['date']}  Time: ${saleData['time']}'),
            Text('Grand Total: ${saleData['grandTotal']}', style: TextStyle(fontSize: 18)),
            Text('Cash Received: ${saleData['cashReceived']}'),
            Text('Discount %: ${saleData['discount']}'),
            Text('Remaining Balance: ${saleData['remainingBalance']}'),
            Text('Total without Disc: ${saleData['total']}', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.map((item) => ListTile(
              title: Text(item['name']),
              subtitle: Text('Quantity: ${item['quantity']} - Price: ${item['price']}'),
              trailing: Text('Subtotal: ${item['subtotal']}'),
              onTap: () => _showReturnDialog(context, item, saleProvider, saleData['transactionID']),
            )),

          ],
        ),
      ),
    );
  }

  void _showReturnDialog(BuildContext context, dynamic item, SaleProvider saleProvider, String transactionId) {
    final returnQtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Return Item: ${item['name'] ?? 'Unknown'}'),
          content: TextField(
            controller: returnQtyController,
            decoration: InputDecoration(labelText: 'Return Quantity'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final returnQty = int.tryParse(returnQtyController.text) ?? 0;
                final itemQuantity = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;

                if (returnQty > 0 && returnQty <= itemQuantity) {
                  if (transactionId.isNotEmpty && item['itemID'] != null) {
                    await saleProvider.returnItem(transactionId, item['itemID'], returnQty);
                    saleProvider.calculateTotal(); // Recalculate totals

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Return successful and totals updated!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transaction ID or Item ID is missing')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid return quantity')),
                  );
                }
              },
              child: const Text('Return'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }


}
