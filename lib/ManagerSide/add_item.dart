import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/itemmodel.dart';
import '../Providers/authProvieder.dart';
import '../Providers/categoryprovider.dart';
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
  final TextEditingController _genericController = TextEditingController();
  final TextEditingController _total_piecesController = TextEditingController();
  final TextEditingController _manufacController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();


  double _netPrice = 0.0;
  String? _selectedUnit = 'Box'; // Variable to hold the selected unit
  List<String> _unitNames = []; // List to hold unit names
  String? _managerId;
  bool _isUpdate = false; // To track if it's update mode
  String? _selectedCategory; // Variable to hold the selected unit
  List<String> _categoryNames = []; // List to hold unit names

  @override
  void initState() {
    super.initState();

    _fetchUnits(); // Fetch units when the widget initializes
    _fetchCategory();
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
      _quantityController.text = widget.item!.minimum_quantity.toString();
      _expiryDateController.text = widget.item!.expiryDate;
      _selectedUnit = widget.item!.unit;
      _genericController.text = widget.item!.genericName;
      _total_piecesController.text = widget.item!.total_pieces_per_box.toString();
    }
  }

  Future<void> _fetchUnits() async {
    final unitProvider = Provider.of<UnitProvider>(context, listen: false);
    await unitProvider.fetchUnits(); // Await the fetchUnits method
    _unitNames = unitProvider.units.map((unit) => unit.name).toList();
    print("Fetched units: $_unitNames"); // Debugging line
    setState(() {}); // Trigger a rebuild
  }

  Future<void> _fetchCategory() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.fetchcategorys(); // Await the fetchCategory method
    _categoryNames = categoryProvider.categorys.map((category) => category.name).toList();
    print("Fetched categories: $_categoryNames"); // Debugging line
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
      _netPrice = (salePrice * (1 + tax / 100) * 100).round() / 100; // Limit to 2 decimal places and convert to int
    });
  }

  Future<void> _saveOrUpdateItem() async {
    if (!_formKey.currentState!.validate()) return;

    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final double salePrice  = double.tryParse(_salePriceController.text) ?? 0.0 ;
    final double taxRate =double.tryParse(_taxController.text) ?? 0.0 ;
    final double taxAmount = (salePrice * taxRate) / 100;

// Calculate rate_per_tab
    final int totalPieces = int.tryParse(_total_piecesController.text) ?? 0;
    final double ratePerTab = totalPieces > 0 ? _netPrice / totalPieces : 0.0;


    // Check for duplicate items
    bool isDuplicate = await itemProvider.isDuplicateItem(
      itemName: _itemNameController.text.trim(),
      barcode: _barcodeController.text.trim(),
      itemId: _isUpdate ? widget.item!.id : null,
    );

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Duplicate item name or barcode found! Please use unique values.")),
      );
      return;
    }

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
        minimum_quantity: int.tryParse(_quantityController.text) ?? 0,
        expiryDate: _expiryDateController.text,
        managerId: _managerId!, // Use the manager ID
        genericName:  _genericController.text,
        location:  _locationController.text,
        taxamount: taxAmount,
        total_pieces_per_box: int.tryParse(_total_piecesController.text) ?? 0,
        ratePerTab: ratePerTab, // Include the calculated rate per tab
        category: _selectedCategory!,
        manufacturer: _manufacController.text,

      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item updated successfully!")),
      );
    } else {
      // Add new item
      await itemProvider.addItem(
        itemName: _itemNameController.text.trim(),
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0.0,
        salePrice: double.tryParse(_salePriceController.text) ?? 0.0,
        tax: double.tryParse(_taxController.text) ?? 0.0,
        netPrice: _netPrice,
        barcode: _barcodeController.text,
        unit: _selectedUnit!,
        minimum_quantity: int.tryParse(_quantityController.text) ?? 0,
        expiryDate: _expiryDateController.text,
        managerId: _managerId!,
        genericName: _genericController.text.trim(),
        taxamount: taxAmount, // Use the manager ID
        total_pieces_per_box: int.tryParse(_total_piecesController.text) ?? 0,
        ratePerTab: ratePerTab, // Include the calculated rate per tab
        category: _selectedCategory!,
        location: _locationController.text,
        manufacturer: _manufacController.text,
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
    _total_piecesController.clear();
    _locationController.clear();
    _manufacController.clear();

    setState(() {
      _netPrice = 0.0;
      _selectedUnit = null;
      _selectedCategory = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, ('/total_items'));
        }, icon: const Icon(Icons.arrow_back)),
        title: const Text('Add New Medicine'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Barcode
              const SizedBox(height: 10),
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
              // Item Name
              const SizedBox(height: 10),
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
              //Pieces in Packing
              const SizedBox(height: 10),
              TextFormField(
                controller: _total_piecesController,
                decoration: const InputDecoration(
                  labelText: "Pieces in Packing",
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
              //purchase price
              const SizedBox(height: 10),
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
              //sale price
              const SizedBox(height: 10),
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
              //manufacturer
              const SizedBox(height: 10),
              TextFormField(
                controller: _manufacController,
                decoration: const InputDecoration(
                  labelText: "Manufacturer",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Manufacturer name';
                  }
                  return null;
                },
              ),
              // Tax
              const SizedBox(height: 10),
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
              // Net Price (calculated)
               const SizedBox(height: 10),
              ListTile(
                title: const Text("Net Price (Including Tax):"),
                subtitle: Text(
                  _netPrice.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              // Category Dropdown
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                value: _selectedCategory,
                items: _categoryNames.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value; // Update the selected unit
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a unit';
                  }
                  return null;
                },
              ),
              // Unit Dropdown
              const SizedBox(height: 10),
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
              // minimum Quantity
              const SizedBox(height: 10),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: "Minimum Quantity",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter minimum quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              //generic name
              const SizedBox(height: 10),
              TextFormField(
                controller: _genericController,
                decoration: const InputDecoration(
                  labelText: "Generic Name",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Generic name';
                  }
                  return null;
                },
              ),
              // Expiry Date
              const SizedBox(height: 10),
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
              //location
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _saveOrUpdateItem,
                child: const Text('Add Item',style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
