import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/itemprovider.dart';
import 'add_item.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({Key? key}) : super(key: key);

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    await itemProvider.fetchItems();
  }




  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ItemProvider>(context).items;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, ('/managerpage'));
        }, icon: Icon(Icons.arrow_back)),
        title: const Text('All Items'),
        backgroundColor: Colors.teal,
      ),
      body: items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.itemName,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
            subtitle: Row(
              children: [
                Text('Price: \ ${item.netPrice.toStringAsFixed(2)}rs'),
                SizedBox(width: 30,),
                Text('Qty: ${item.quantity}'),
              ],
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

          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddItemDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor:  Colors.teal,
      ),
    );
  }

  void showAddItemDialog() {
    Navigator.pushNamed(context, '/add_items');
  }


}
