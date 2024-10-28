import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Models/selecteditemmodel.dart';
import '../Providers/saleprovider.dart';

class POSPage extends StatelessWidget {
  const POSPage({Key? key}) : super(key: key);




  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<saleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Row(
          children: [
            Text(
              'POS Page',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Dropdowns and Search Field
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: provider.searchController,
                          onChanged: provider.searchItems,
                          decoration: const InputDecoration(
                            hintText: 'Search Product new',
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
                                    provider.updateSelectedItem(item as Item); // Add item to selectedItems
                                    provider.searchController.clear();
                                  },
                                );
                              },
                            )

                          ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: provider.saleDateController,
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
                                  provider.saleDateController.text =
                                      DateFormat('dd/MM/yyyy').format(pickedDate);
                                }
                              },
                              icon: const Icon(Icons.date_range),
                            ),
                            hintText: "Select Sale Date",
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(child: Center(child: Text('Product List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                    // You can add more headings here if necessary
                  ],
                ),
                const SizedBox(height: 10), // Add some spacing below the heading
                // Data Table
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Action',style: TextStyle(fontSize: 17),)),
                            DataColumn(label: Text('Product',style: TextStyle(fontSize: 17),)),
                            DataColumn(label: Text('Price',style: TextStyle(fontSize: 17),)),
                            DataColumn(label: Text('Quantity',style: TextStyle(fontSize: 17),)),
                            DataColumn(label: Text('Sub Total',style: TextStyle(fontSize: 17),)),
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
                                DataCell(Text('${selectedItem.ratePerTab?.toStringAsFixed(2) ?? '0.00'}')),
                                DataCell(
                                  TextFormField(
                                    initialValue: selectedItem.qty.toString(),
                                    keyboardType: TextInputType.number,
                                    onChanged: (newValue) {
                                      if (newValue.isNotEmpty) {
                                        selectedItem.qty = int.tryParse(newValue) ?? 1;
                                      } else {
                                        selectedItem.qty = 1; // Default to 1 if empty
                                      }
                                      provider.calculateTotal(); // Recalculate total
                                    },
                                  ),
                                ),
                                DataCell(Text((selectedItem.ratePerTab * selectedItem.qty).toStringAsFixed(2))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                              'Sub Total Balance:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                              Text(
                              '${provider.total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                              const Text(
                                'Apply Discount:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                onChanged: (newValue) {
                                  provider.discount = newValue.isNotEmpty ? newValue : '0'; // Handle empty
                                  provider.calculateTotal(); // Recalculate total
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter Discount (%)',
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Cash Received:',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                onChanged: (newValue) {
                                  provider.cashReceived = newValue.isNotEmpty ? double.tryParse(newValue) ?? 0.0 : 0.0;
                                  provider.calculateBalance();
                                  provider.remainingBalance();
                                  // Optionally calculate balance here
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter Cash Received',
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Grand Total Balance:',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
        
                              Text(
                                '${provider.grandTotal.toStringAsFixed(2)}', // Displaying the grand total
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),const Text(
                                'Remaining Balance:',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${provider.remainingbalance.toStringAsFixed(2)}', // Displaying remaining balance
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20), // Add some spacing before the buttons
            // Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Add your save sale logic here
                    provider.saveSale(); // Example method
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), backgroundColor: Colors.blueAccent,
                  ),
                  child: const Text('Save Sale'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add your save and print logic here
                    provider.saveAndPrint(); // Example method
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), backgroundColor: Colors.greenAccent,
                  ),
                  child: const Text('Save and Print'),
                ),
              ],
            ),
            const SizedBox(height: 20), // Add some spacing below the buttons
          ],
        ),
      ),
    );
  }
}
