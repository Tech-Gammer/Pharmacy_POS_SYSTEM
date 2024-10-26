import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class PurchasePage extends StatefulWidget {
  @override
  _PurchasePageState createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final TextEditingController _expiryDateController = TextEditingController();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref(); // Reference to the database
  List<String> _suppliers = []; // List to store supplier names
  String? _selectedSupplier; // Variable to hold selected supplier
  String? _purchaseNumber; // Variable to hold generated purchase number
  TextEditingController _searchController = TextEditingController(); // Controller for search input
  List<Item> _items = []; // List to store Item objects
  List<Item> _filteredItems = []; // List to store items filtered by selected supplier
  List<Item> _displayedItems = []; // List to display items in the dropdown
  Item? _selectedItem; // Variable to hold selected item
  String? _itemDiscount; // Variable to hold item discount
  double _itemSellingRate = 0.0; // Variable to hold selling rate
  double _itemLandingCost = 0.0; // Variable to hold landing cost
  int _itemQty = 1; // Variable to hold quantity
  double _totalAmount = 0.0; // Variable to hold total amount
  List<SelectedItem> _selectedItems = []; // New list to hold selected items

  @override
  void initState() {
    super.initState();
    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _expiryDateController.text = formattedDate;
    _fetchSuppliers();
    _fetchItems();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('suppliers').once();
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> suppliersMap = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _suppliers = suppliersMap.values.map((supplier) {
            return supplier['name'] != null ? supplier['name'] as String : 'Unnamed Supplier';
          }).toList();
        });
      } else {
        print('No suppliers found');
      }
    } catch (e) {
      print('Error fetching suppliers: $e');
    }
  }

  Future<void> _fetchItems() async {
    try {
      final DatabaseEvent event = await _databaseRef.child('items').once();
      final DataSnapshot snapshot = event.snapshot; // Get the DataSnapshot
      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> itemsMap = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _items = itemsMap.values.map((item) {
            return Item(
              name: item['item_name'] != null ? item['item_name'] as String : 'Unnamed Item',
              genericName: item['generic_name'] != null ? item['generic_name'] as String : 'Unnamed Generic',
              barcode: item['barcode'] != null ? item['barcode'] as String : '000000',
              sellingRate: item['net_price'] != null ? double.parse(item['net_price'].toString()) : 0.0,
              landingCost: item['purchase_price'] != null ? double.parse(item['purchase_price'].toString()) : 0.0,
            );
          }).toList();
          _filteredItems = List.from(_items); // Initialize filtered items with all items
          _displayedItems = List.from(_items); // Initialize displayed items with all items
        });
      } else {
        print('No items found');
      }
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  void _generatePurchaseNumber() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _purchaseNumber = timestamp; // Update purchase number state
    });
  }

  void _searchItems(String query) {
    // Filter displayed items based on search query
    setState(() {
      _displayedItems = _filteredItems.where((item) {
        return item.name.toLowerCase().contains(query.toLowerCase()) ||
            item.genericName.toLowerCase().contains(query.toLowerCase()) ||
            item.barcode.contains(query); // Search by barcode as well
      }).toList();
    });
  }

  void _updateSelectedItem(Item? item) {
    if (item != null) {
      bool itemExists = _selectedItems.any((selectedItem) => selectedItem.name == item.name);

      if (itemExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} is already added to the list!')),
        );
      } else {
        setState(() {
          _selectedItems.add(SelectedItem(
            name: item.name,
            discount: '0', // Initialize with a default discount as a clean number string.
            discountType: 'percentage', // Default discount type.
            taxType: 'percentage', // Default tax type.
            tax: 0.0, // Default tax value.
            taxAmount: 0.0,
            sellingRate: item.sellingRate,
            landingCost: item.landingCost,
            qty: _itemQty,
            totalExcludingTax: 0.0,
            totalIncludingTax: 0.0,
          ));
          _calculateTotal(); // Recalculate total amount.
        });
      }
      _searchController.clear();
    }
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var selectedItem in _selectedItems) {
      double discount = selectedItem.discountType == 'percentage'
          ? selectedItem.landingCost * (_parseDiscount(selectedItem.discount) / 100)
          : _parseDiscount(selectedItem.discount);

      double discountedPrice = selectedItem.landingCost - discount;
      double taxAmount = discountedPrice * (selectedItem.tax / 100);

      selectedItem.taxAmount = taxAmount;
      selectedItem.totalExcludingTax = discountedPrice * selectedItem.qty;
      selectedItem.totalIncludingTax = (discountedPrice + taxAmount) * selectedItem.qty;

      total += selectedItem.totalIncludingTax;
    }
    setState(() {
      _totalAmount = total;
    });
  }

  void _updateSelectedItemField(int index, String field, String newValue) {
    setState(() {
      var selectedItem = _selectedItems[index];
      switch (field) {
        case 'qty':
          selectedItem.qty = int.tryParse(newValue) ?? 0; // Convert to int safely
          break;
        case 'discount':
          selectedItem.discount = newValue;
          break;
        case 'tax':
          selectedItem.tax = double.tryParse(newValue) ?? 0.0; // Keep this as double
          break;
        case 'sellingRate':
          selectedItem.sellingRate = double.tryParse(newValue) ?? 0.0; // Keep this as double
          break;
        case 'landingCost':
          selectedItem.landingCost = double.tryParse(newValue) ?? 0.0; // Keep this as double
          break;
      }
      // Optionally recalculate totals after each change
      _calculateTotal();
    });
  }

  double _parseDiscount(String discount) {
    // Remove any non-numeric characters except the decimal point.
    final cleanedDiscount = discount.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleanedDiscount) ?? 0.0;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/managerpage');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Purchase Items'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Top Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Supplier'),
                      const SizedBox(height: 8), // Add some spacing
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text('Select Supplier'),
                            value: _selectedSupplier,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSupplier = newValue; // Update the selected supplier
                                _generatePurchaseNumber();
                              });
                            },
                            items: _suppliers.map<DropdownMenuItem<String>>((String supplier) {
                              return DropdownMenuItem<String>(
                                value: supplier,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    supplier,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice Date'),
                      TextFormField(
                        controller: _expiryDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                String formattedDate =
                                DateFormat('dd/MM/yyyy').format(pickedDate);
                                setState(() {
                                  _expiryDateController.text = formattedDate;
                                });
                              }
                            },
                            icon: const Icon(Icons.date_range),
                          ),
                          hintText: "Select Expiry Date",
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice No'),
                      TextField(
                        decoration: InputDecoration(
                          hintText: _purchaseNumber ?? '001', // Show generated purchase number or default
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        readOnly: true, // Make it read-only
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Product'),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: _searchItems,
                        decoration: const InputDecoration(
                          hintText: 'Search Product',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_searchController.text.isNotEmpty && _displayedItems.isNotEmpty)
                      // Display the filtered items below the search field
                        Container(
                          height: 150, // Adjust height as needed
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: _displayedItems.isNotEmpty
                              ? ListView.builder(
                            itemCount: _displayedItems.length,
                            itemBuilder: (context, index) {
                              final item = _displayedItems[index];
                              return ListTile(
                                title: Text(item.name),
                                onTap: () {
                                  _updateSelectedItem(item);setState(() {
                                    _searchController.clear(); // Clear the search field
                                  });

                                },
                              );
                            },
                          )
                              : const Center(child: Text('No items found')),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Action')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Discount %/Amt')),
                    DataColumn(label: Text('Discounted Amount')),
                    DataColumn(label: Text('Tax %/Amt')),
                    DataColumn(label: Text('Tax Amt')),
                    DataColumn(label: Text('Selling Rate')),
                    DataColumn(label: Text('Landing Cost')),
                    DataColumn(label: Text('Total (Excl. Tax)')),
                    DataColumn(label: Text('Total (Incl. Tax)')),
                  ],
                  rows: _selectedItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    SelectedItem selectedItem = entry.value;
                    // Calculate the discounted amount
                    double discountAmount = selectedItem.discountType == 'percentage'
                        ? selectedItem.totalIncludingTax * (double.parse(selectedItem.discount) / 100)
                        : double.parse(selectedItem.discount);

                    // Calculate the tax amount
                    double taxAmount = selectedItem.taxType == 'percentage'
                        ? (selectedItem.landingCost - discountAmount) * (selectedItem.tax / 100)
                        : selectedItem.tax;

                    return DataRow(
                      cells: [
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedItems.removeAt(index); // Remove the selected item
                                _calculateTotal(); // Recalculate the total after removing the item
                              });
                            },
                          ),
                        ),
                        DataCell(Text(selectedItem.name)),
                        DataCell(
                          TextFormField(
                            initialValue: selectedItem.qty.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (newValue) {
                              _updateSelectedItemField(index, 'qty', newValue);
                            },
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Checkbox(
                                value: selectedItem.discountType == 'percentage',
                                onChanged: (value) {
                                  setState(() {
                                    selectedItem.discountType = value! ? 'percentage' : 'amount';
                                    _calculateTotal();
                                  });
                                },
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: selectedItem.discount,
                                  onChanged: (newValue) {
                                    // Check if the input is empty
                                    if (newValue.isEmpty) {
                                      // Set to '0' or handle accordingly
                                      _updateSelectedItemField(index, 'discount', '0');
                                    } else {
                                      // Only update with valid newValue
                                      _updateSelectedItemField(index, 'discount', newValue);
                                    }
                                    _calculateTotal();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(discountAmount.toStringAsFixed(2))),
                        DataCell(
                          Row(
                            children: [
                              Checkbox(
                                value: selectedItem.taxType == 'percentage',
                                onChanged: (value) {
                                  setState(() {
                                    selectedItem.taxType = value! ? 'percentage' : 'amount';
                                    _calculateTotal();
                                  });
                                },
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: selectedItem.tax.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (newValue) {
                                    if (newValue.isEmpty) {
                                      _updateSelectedItemField(index, 'tax', '0');
                                    } else {
                                      _updateSelectedItemField(index, 'tax', newValue);
                                    }
                                    _calculateTotal();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(taxAmount.toStringAsFixed(2))),
                        DataCell(
                          TextFormField(
                            initialValue: selectedItem.sellingRate.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (newValue) {
                              _updateSelectedItemField(index, 'sellingRate', newValue);
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            initialValue: selectedItem.landingCost.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (newValue) {
                              _updateSelectedItemField(index, 'landingCost', newValue);
                            },
                          ),
                        ),
                        DataCell(Text(selectedItem.totalExcludingTax.toStringAsFixed(2))),
                        DataCell(Text(selectedItem.totalIncludingTax.toStringAsFixed(2))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
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
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Amount'),
                      Text(_totalAmount.toStringAsFixed(2)), // Show total amount
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final String genericName;
  final String barcode;
  final double sellingRate; // Add sellingRate
  final double landingCost; // Add landingCost

  Item({
    required this.name,
    required this.genericName,
    required this.barcode,
    required this.sellingRate, // Add sellingRate to constructor
    required this.landingCost, // Add landingCost to constructor
  });
}
class SelectedItem {
  final String name;
  String discount; // Make sure this is a string to store user input
  String discountType; // "percentage" or "amount"
  String taxType; // New property for tax type
  double tax; // Tax value
  double taxAmount; // Calculated tax amount
  double sellingRate; // Selling price
  double landingCost; // Cost price
  int qty; // Quantity
  double totalExcludingTax; // Total excluding tax
  double totalIncludingTax; // Total including tax

  SelectedItem({
    required this.name,
    required this.discount,
    required this.discountType,
    required this.taxType, // Include taxType in the constructor
    required this.tax,
    required this.taxAmount,
    required this.sellingRate,
    required this.landingCost,
    required this.qty,
    required this.totalExcludingTax,
    required this.totalIncludingTax,
  });
}
