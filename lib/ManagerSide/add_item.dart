import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/itemmodel.dart';
import '../Providers/authProvieder.dart';
import '../Providers/itemprovider.dart';
import '../Providers/unitprovider.dart';

class AddItem extends StatefulWidget {
  // const AddItem({super.key});
  final Item? item; // Accept an optional item for updating
  const AddItem({super.key, this.item});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  double _netPrice = 0.0;
  String? _selectedUnit; // Variable to hold the selected unit
  List<String> _unitNames = []; // List to hold unit names
  String? _managerId;
  bool _isUpdate = false; // To track if it's update mode

  @override
  void initState() {
    super.initState();
    _fetchUnits(); // Fetch units when the widget initializes
    _getCurrentUserId(); // Get the current user's ID
    // If an item is passed, populate the form with its data
    if (widget.item != null) {
      _isUpdate = true; // Set update mode
      _itemNameController.text = widget.item!.itemName;
      _purchasePriceController.text = widget.item!.purchasePrice.toString();
      _salePriceController.text = widget.item!.salePrice.toString();
      _taxController.text = widget.item!.tax.toString();
      _netPrice = widget.item!.netPrice;
      _barcodeController.text = widget.item!.barcode;
      _quantityController.text = widget.item!.quantity.toString();
      _expiryDateController.text = widget.item!.expiryDate;
      _selectedUnit = widget.item!.unit;
    }
  }

  Future<void> _fetchUnits() async {
    final unitProvider = Provider.of<UnitProvider>(context, listen: false);
    await unitProvider.fetchUnits(); // Await the fetchUnits method
    _unitNames = unitProvider.units.map((unit) => unit.name).toList();
    print("Fetched units: $_unitNames"); // Debugging line
    setState(() {}); // Trigger a rebuild
  }
  Future<void> _getCurrentUserId() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _managerId = authProvider.currentUserId; // Assuming you have this method
    print("Current Manager ID: $_managerId"); // Debugging line
  }
  // Method to calculate net price
  void _calculateNetPrice() {
    double salePrice = double.tryParse(_salePriceController.text) ?? 0.0;
    double tax = double.tryParse(_taxController.text) ?? 0.0;
    setState(() {
      _netPrice = salePrice * (1 + tax / 100); // Net price calculation with tax
    });
  }

  Future<void> _saveOrUpdateItem() async {
    if (!_formKey.currentState!.validate()) return;

    final itemProvider = Provider.of<ItemProvider>(context, listen: false);

    if (_isUpdate) {
      // Update existing item
      await itemProvider.updateItem(
        itemId: widget.item!.id, // Pass the existing item ID
        itemName: _itemNameController.text,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0.0,
        salePrice: double.tryParse(_salePriceController.text) ?? 0.0,
        tax: double.tryParse(_taxController.text) ?? 0.0,
        netPrice: _netPrice,
        barcode: _barcodeController.text,
        unit: _selectedUnit!,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        expiryDate: _expiryDateController.text,
        managerId: _managerId!, // Use the manager ID
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item updated successfully!")),
      );
    } else {
      // Add new item
      await itemProvider.addItem(
        itemName: _itemNameController.text,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0.0,
        salePrice: double.tryParse(_salePriceController.text) ?? 0.0,
        tax: double.tryParse(_taxController.text) ?? 0.0,
        netPrice: _netPrice,
        barcode: _barcodeController.text,
        unit: _selectedUnit!,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        expiryDate: _expiryDateController.text,
        managerId: _managerId!, // Use the manager ID
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item added successfully!")),
      );
    }

    // Clear form and reset
    _formKey.currentState!.reset();
    _itemNameController.clear();
    _purchasePriceController.clear();
    _salePriceController.clear();
    _taxController.clear();
    _barcodeController.clear();
    _quantityController.clear();
    _expiryDateController.clear();
    setState(() {
      _netPrice = 0.0;
      _selectedUnit = null;
    });
      Navigator.pushNamed(context, ('/total_items'));
  }
  // Method to save data to Firebase Realtime Database using ItemProvider
  // Future<void> _saveItem() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   final itemProvider = Provider.of<ItemProvider>(context, listen: false);
  //   await itemProvider.addItem(
  //     itemName: _itemNameController.text,
  //     purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0.0,
  //     salePrice: double.tryParse(_salePriceController.text) ?? 0.0,
  //     tax: double.tryParse(_taxController.text) ?? 0.0,
  //     netPrice: _netPrice,
  //     barcode: _barcodeController.text,
  //     unit: _selectedUnit!,
  //     quantity: int.tryParse(_quantityController.text) ?? 0,
  //     expiryDate: _expiryDateController.text,
  //     managerId: _managerId!, // Use the manager ID
  //   );
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Item added successfully!")),
  //   );
  //   // Clear form
  //   _formKey.currentState!.reset();
  //   // Clear TextEditingControllers
  //   _itemNameController.clear();
  //   _purchasePriceController.clear();
  //   _salePriceController.clear();
  //   _taxController.clear();
  //   _barcodeController.clear();
  //   _quantityController.clear();
  //   _expiryDateController.clear();
  //   setState(() {
  //     _netPrice = 0.0;
  //     _selectedUnit = null; // Reset the selected unit
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, ('/total_items'));
        }, icon: Icon(Icons.arrow_back)),
        title: const Text('Add New Medicine'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Item Name
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: "Item Name",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Purchase Price
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(
                  labelText: "Purchase Price",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter purchase price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Sale Price
              TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(
                  labelText: "Sale Price",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateNetPrice(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sale price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Tax
              TextFormField(
                controller: _taxController,
                decoration: const InputDecoration(
                  labelText: "Tax (%)",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateNetPrice(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tax';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Net Price (calculated)
              ListTile(
                title: const Text("Net Price (Including Tax):"),
                subtitle: Text(
                  _netPrice.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),

              // Barcode
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: "Barcode",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter barcode';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Unit Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Unit",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                value: _selectedUnit,
                items: _unitNames.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value; // Update the selected unit
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Expiry Date
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
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                        setState(() {
                          _expiryDateController.text = formattedDate;
                        });
                      }
                    },
                    icon: const Icon(Icons.date_range),
                  ),
                  hintText: "Select Expiry Date",
                  labelText: "Expiry Date",
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _saveOrUpdateItem,
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
