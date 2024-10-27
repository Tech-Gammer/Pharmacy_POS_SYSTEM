
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_pos_system/Providers/purchaseprovider.dart';
import 'package:provider/provider.dart';

class PurchasePage extends StatelessWidget {
  const PurchasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PurchaseProvider>(context);

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
            // Supplier Dropdown, Invoice Date, and Invoice Number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Supplier'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text('Select Supplier'),
                            value: provider.selectedSupplier,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              provider.selectedSupplier = newValue;
                              provider.generatePurchaseNumber();
                            },
                            items: provider.suppliers.map<DropdownMenuItem<String>>((String supplier) {
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
                        controller: provider.expiryDateController,
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
                                provider.expiryDateController.text =
                                    DateFormat('dd/MM/yyyy').format(pickedDate);
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
                          hintText: provider.purchaseNumber ?? '001',
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Product Search and Selection
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
                        controller: provider.searchController,
                        onChanged: provider.searchItems,
                        decoration: const InputDecoration(
                          hintText: 'Search Product',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (provider.searchController.text.isNotEmpty &&
                          provider.displayedItems.isNotEmpty)
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListView.builder(
                            itemCount: provider.displayedItems.length,
                            itemBuilder: (context, index) {
                              final item = provider.displayedItems[index];
                              return ListTile(
                                title: Text(item.name),
                                onTap: () {
                                  provider.updateSelectedItem(item);
                                  provider.searchController.clear();
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Data Table for Selected Items
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
                  rows: provider.selectedItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    SelectedItem selectedItem = entry.value;

                    return DataRow(
                      cells: [
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => provider.removeSelectedItem(index),
                          ),
                        ),
                        DataCell(Text(selectedItem.name)),
                        DataCell(
                          TextFormField(
                            initialValue: selectedItem.qty.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (newValue) {
                              provider.updateSelectedItemField(index, 'qty', newValue);
                            },
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Checkbox(
                                value: selectedItem.discountType == 'percentage',
                                onChanged: (value) {
                                  selectedItem.discountType = value! ? 'percentage' : 'amount';
                                  provider.notifyListeners(); // Call notify to update UI
                                  provider.calculateTotal(); // Recalculate totals
                                },
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: selectedItem.discount,
                                  onChanged: (newValue) {
                                    provider.updateSelectedItemField(index, 'discount', newValue);
                                    provider.calculateTotal();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(selectedItem.discountAmount.toStringAsFixed(2))),
                        DataCell(
                          Row(
                            children: [
                              Checkbox(
                                value: selectedItem.taxType == 'percentage',
                                onChanged: (value) {
                                  selectedItem.taxType = value! ? 'percentage' : 'amount';
                                  provider.notifyListeners(); // Call notify to update UI
                                  provider.calculateTotal(); // Recalculate totals
                                },
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: selectedItem.tax.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (newValue) {
                                    provider.updateSelectedItemField(index, 'tax', newValue);
                                    // provider.calculateTotal();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(selectedItem.taxAmount.toStringAsFixed(2))),
                        DataCell(
                          TextFormField(
                            initialValue: selectedItem.sellingRate.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (newValue) {
                              provider.updateSelectedItemField(index, 'sellingRate', newValue);
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            initialValue: selectedItem.landingCost.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (newValue) {
                              provider.updateSelectedItemField(index, 'landingCost', newValue);
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Discount %'),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: '0.00%',
                        ),
                        onChanged: (value) {
                          // Assuming you have a method to update discount
                          provider.updateDiscount(value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cash Paid'),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: '0.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          // Update cash paid amount
                          provider.updateCashPaid(value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Total Amount: \Pkr${provider.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                await provider.savePurchase();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchase saved successfully.')),
                );
              },
              child: const Text('Save Purchase',style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous page
                  },
                  child: const Text('Back', style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Here you can define what 'forward' means in your app context.
                    Navigator.pushNamed(context, '/nextPage'); // Replace with actual route
                  },
                  child: const Text('Next', style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement your edit functionality if necessary
                    provider.isEditing = true; // For example, toggle an editing mode
                    provider.notifyListeners(); // Notify listeners for UI updates
                  },
                  child: const Text('Edit', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
