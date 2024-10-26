import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/categoryprovider.dart';
import 'add_category.dart';


class Showcategory extends StatefulWidget {
  const Showcategory({super.key});

  @override
  State<Showcategory> createState() => _ShowcategoryState();
}

class _ShowcategoryState extends State<Showcategory> {
  @override

  void initState() {
    super.initState();
    // Fetch categorys when the widget is initialized
    Provider.of<CategoryProvider>(context, listen: false).fetchcategorys();
  }

  void showDeleteConfirmationDialog(String categoryId, String categoryName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete the category '$categoryName'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Provider.of<CategoryProvider>(context, listen: false).deletecategory(categoryId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("category deleted successfully")),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categorys = categoryProvider.categorys;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, ('/managerpage'));
        }, icon: Icon(Icons.arrow_back)),
        title: const Text('Total categorys'),
        backgroundColor: Colors.teal,
      ),
      body: categorys.isEmpty
          ? Center(
        child: Text(
          'No categorys found.',
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: categorys.length,
        itemBuilder: (context, index) {
          Category category = categorys[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(category.name, ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => showDeleteConfirmationDialog(category.id, category.name),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddcategoryDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor:  Colors.teal,
      ),
    );
  }

  void showAddcategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Addcategory();
      },
    );
  }
}
