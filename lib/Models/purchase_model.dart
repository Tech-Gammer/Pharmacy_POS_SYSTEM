import 'package:firebase_database/firebase_database.dart';

class Purchase {
  int boxQty;
  int cashPaid;
  String date;
  List<dynamic> items;
  String purchaseNumber;
  int remainingBalance;
  String supplier;
  int totalAmount;
  int totalPieces;

  Purchase({
    required this.boxQty,
    required this.cashPaid,
    required this.date,
    required this.items,
    required this.purchaseNumber,
    required this.remainingBalance,
    required this.supplier,
    required this.totalAmount,
    required this.totalPieces,
  });

  factory Purchase.fromSnapshot(DataSnapshot snapshot) {
    return Purchase(
      boxQty: snapshot.child('box_qty').value as int,
      cashPaid: snapshot.child('cashpaid').value as int,
      date: snapshot.child('date').value as String,
      items: snapshot.child('items').value as List<dynamic>,
      purchaseNumber: snapshot.child('purchaseNumber').value as String,
      remainingBalance: snapshot.child('remainingBalance').value as int,
      supplier: snapshot.child('supplier').value as String,
      totalAmount: snapshot.child('totalAmount').value as int,
      totalPieces: snapshot.child('total_pieces').value as int,
    );
  }
}
