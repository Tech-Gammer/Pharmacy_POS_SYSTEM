class SelectedItem {
  final String id; // Unique identifier for the item
  final String name;
  final int totalPiecesPerBox; // Total pieces per box
  String discount;
  String discountType; // "percentage" or "amount"
  String taxType; // "percentage" or "amount"
  double tax; // Tax value as percentage or flat amount
  double sellingRate;
  double landingCost;
  int qty;
  double ratePerTab; // Make sure this is defined


  SelectedItem({
    required this.id,
    required this.name,
    required this.discount,
    required this.discountType,
    required this.taxType,
    required this.tax,
    required this.sellingRate,
    required this.landingCost,
    required this.qty,
    required this.totalPiecesPerBox, // Add this property
    required this.ratePerTab, // Make sure it's required if necessary
  });
}

class Item {
  final String id; // Unique identifier for the item
  final String name;
  final String genericName;
  final String barcode;
  final double sellingRate; // Add sellingRate
  final double landingCost; // Add landingCost
  final int totalPiecesPerBox; // Add this property
  final double ratePerTab;

  Item({
    required this.id,
    required this.name,
    required this.genericName,
    required this.barcode,
    required this.sellingRate, // Add sellingRate to constructor
    required this.landingCost, // Add landingCost to constructor
    required this.totalPiecesPerBox,
    required this.ratePerTab
  });
}
