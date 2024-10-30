// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class SalesListPage extends StatefulWidget {
//   @override
//   _SalesListPageState createState() => _SalesListPageState();
// }
//
// class _SalesListPageState extends State<SalesListPage> {
//   final DatabaseReference salesRef = FirebaseDatabase.instance.ref().child('sales');
//   List<Map<dynamic, dynamic>> salesList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchSales();
//   }
//
//   Future<void> _fetchSales() async {
//     final snapshot = await salesRef.get();
//     final salesData = snapshot.value as Map<dynamic, dynamic>?;
//
//     if (salesData != null) {
//       setState(() {
//         salesList = salesData.entries.map((entry) {
//           final sale = entry.value as Map<dynamic, dynamic>;
//           return {
//             'transactionID': sale['transactionID'],
//             'date': sale['date'],
//             'time': sale['time'],
//             'total': sale['total'],
//             'discount': sale['discount'],
//             'grandTotal': sale['grandTotal'],
//             'items': sale['items'],
//             'remainingBalance': sale['remainingBalance'],
//           };
//         }).toList();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sales History'),
//       ),
//       body: salesList.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//         itemCount: salesList.length,
//         itemBuilder: (context, index) {
//           final sale = salesList[index];
//           return Card(
//             margin: const EdgeInsets.all(8),
//             child: ListTile(
//               title: Text('Transaction ID: ${sale['transactionID']}'),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Date: ${sale['date']}'),
//                   Text('Time: ${sale['time']}'),
//                   Text('Total: ${sale['total']}'),
//                   Text('Discount: ${sale['discount']}'),
//                   Text('Grand Total: ${sale['grandTotal']}'),
//                   Text('Remaining Balance: ${sale['remainingBalance']}'),
//                   const SizedBox(height: 8),
//                   const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
//                   for (var item in sale['items'])
//                     Padding(
//                       padding: const EdgeInsets.only(left: 8.0),
//                       child: Text(
//                         '- ${item['name']} x ${item['quantity']} @ ${item['price']} each',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                 ],
//               ),
//               isThreeLine: true,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SalesListPage extends StatefulWidget {
  @override
  _SalesListPageState createState() => _SalesListPageState();
}

class _SalesListPageState extends State<SalesListPage> {
  final DatabaseReference salesRef = FirebaseDatabase.instance.ref().child('sales');
  List<Map<dynamic, dynamic>> salesList = [];
  int _limit = 25; // Number of sales to load per page
  bool _isLoading = false; // To indicate if more data is being loaded
  bool _hasMore = true; // Flag to check if more data is available

  @override
  void initState() {
    super.initState();
    _fetchSales(); // Load initial sales data
  }

  Future<void> _fetchSales() async {
    if (_isLoading || !_hasMore) return; // Prevent multiple fetches
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await salesRef.limitToFirst(salesList.length + _limit).get();
      final salesData = snapshot.value as Map<dynamic, dynamic>?;

      if (salesData != null) {
        final newSalesList = salesData.entries.map((entry) {
          final sale = entry.value as Map<dynamic, dynamic>;
          return {
            'transactionID': sale['transactionID'],
            'date': sale['date'],
            'time': sale['time'],
            'total': sale['total'],
            'discount': sale['discount'],
            'grandTotal': sale['grandTotal'],
            'items': sale['items'],
            'remainingBalance': sale['remainingBalance'],
          };
        }).toList();

        setState(() {
          salesList = newSalesList;
          _hasMore = newSalesList.length == salesList.length + _limit; // Update if more data is available
        });
      } else {
        setState(() {
          _hasMore = false; // No more data to load
        });
      }
    } catch (e) {
      print('Error fetching sales data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        title: const Text('Total Sales List'),
        backgroundColor: Colors.teal,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !_isLoading && _hasMore) {
            _fetchSales();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: salesList.length + 1, // Add one for the loading indicator
          itemBuilder: (context, index) {
            if (index == salesList.length) {
              // Display loading indicator if fetching more sales
              return _hasMore ? const Center(child: CircularProgressIndicator()) : Container();
            }

            final sale = salesList[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('Transaction ID: ${sale['transactionID']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${sale['date']}'),
                    Text('Time: ${sale['time']}'),
                    Text('Total: ${sale['total']}'),
                    Text('Discount: ${sale['discount']}'),
                    Text('Grand Total: ${sale['grandTotal']}'),
                    Text('Remaining Balance: ${double.parse(sale['remainingBalance']).toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                    for (var item in sale['items'])
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '- ${item['name']} x ${item['quantity']} @ ${item['price']} each',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
    );
  }
}

