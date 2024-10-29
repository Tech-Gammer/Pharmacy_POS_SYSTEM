// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../Models/salemodel.dart';
//
// class AllSalesPage extends StatelessWidget {
//   final List<Sale> salesList;
//
//   AllSalesPage({required this.salesList});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("All Sales")),
//       body: ListView.builder(
//         itemCount: salesList.length,
//         itemBuilder: (context, index) {
//           final sale = salesList[index];
//           return ListTile(
//             title: Text('Transaction ID: ${sale.transactionId}'),
//             subtitle: Text('Total Amount: ${sale.totalAmount}'),
//             onTap: () {
//               // Optionally, navigate to sale detail page
//             },
//           );
//         },
//       ),
//     );
//   }
// }
