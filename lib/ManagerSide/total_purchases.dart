import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pharmacy_pos_system/Providers/purchaseprovider.dart';

class TotalPurchases extends StatefulWidget {
  const TotalPurchases({Key? key}) : super(key: key);

  @override
  State<TotalPurchases> createState() => _TotalPurchasesState();
}

class _TotalPurchasesState extends State<TotalPurchases> {
  @override
  void initState() {
    super.initState();
    // Fetch purchases when the page is initialized
    Provider.of<PurchaseProvider>(context, listen: false).fetchInvoices();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PurchaseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Purchases'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: provider.invoices.isEmpty
            ? const Center(child: Text('No purchases found.'))
            : ListView.builder(
          itemCount: provider.invoices.length,
          itemBuilder: (context, index) {
            final purchase = provider.invoices[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text('Invoice No: ${purchase['purchaseNumber']}'),
                subtitle: Text(
                  'Supplier: ${purchase['supplier'] ?? "N/A"} \nDate: ${purchase['date'] ?? "N/A"} \nTotal Amount: Pkr ${(purchase['totalAmount'] ?? 0).toStringAsFixed(2)}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'update') {
                      // Navigate to AddItem page with the selected item for updating
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddItem(item: item), // Pass the item to AddItem page
                        ),
                      );
                    } else if (value == 'delete') {
                      // Show confirmation dialog before deleting
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text("Are you sure you want to delete this item?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                              ),
                              TextButton(
                                child: const Text("Delete"),
                                onPressed: () async {
                                  // Call the delete function in the provider after confirmation
                                  final itemProvider = Provider.of<ItemProvider>(context, listen: false);
                                  await itemProvider.deleteItem(item.id); // Pass the item's ID

                                  Navigator.of(context).pop(); // Close the dialog after delete
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Item deleted successfully!")),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'update',
                      child: Text('Update'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),

              ),

            );
          },
        ),
      ),
    );
  }
}
