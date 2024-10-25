class Item {
  final String id;
  final String itemName;
  final String brandName;
  final double purchasePrice;
  final double salePrice;
  final double tax;
  final double netPrice;
  final String barcode;
  final String unit;
  final int quantity;
  final String expiryDate;
  final String managerId;
  final double taxamount;
  final int total_pieces_per_box;
  final double ratePerTab;

  Item({
    required this.id,
    required this.itemName,
    required this.brandName,
    required this.purchasePrice,
    required this.salePrice,
    required this.tax,
    required this.netPrice,
    required this.barcode,
    required this.unit,
    required this.quantity,
    required this.expiryDate,
    required this.managerId,
    required this.taxamount,
    required this.total_pieces_per_box,
    required this.ratePerTab

  });

  // Factory method to create Item from Firebase data
  factory Item.fromFirebase(String id, Map<dynamic, dynamic> data) {
    return Item(
      id: id,
      itemName: data['item_name'] ?? '', // Provide a default empty string if null
      brandName: data['brand_name'] ?? '', // Provide a default empty string if null

      purchasePrice: (data['purchase_price'] as num?)?.toDouble() ?? 0.0, // Handle null for numeric values
      salePrice: (data['sale_price'] as num?)?.toDouble() ?? 0.0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0.0,
      netPrice: (data['net_price'] as num?)?.toDouble() ?? 0.0,
      barcode: data['barcode'] ?? '', // Provide a default empty string if null
      unit: data['unit'] ?? '', // Provide a default empty string if null
      quantity: (data['quantity'] as num?)?.toInt() ?? 0, // Handle null for integer values
      expiryDate: data['expiry_date'] ?? '', // Provide a default empty string if null
      managerId: data['manager_id'] ?? '', // Provide a default empty string if null
      taxamount: (data['tax_amount'] as num?)?.toDouble() ?? 0.0,
      total_pieces_per_box: (data['total_pieces_per_box'] as num?)?.toInt() ?? 0, // Handle null for integer values
      ratePerTab: (data['ratePerTab'] as num?)?.toDouble() ?? 0.0,


    );
  }
}
