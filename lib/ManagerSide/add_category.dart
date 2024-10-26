import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/categoryprovider.dart';

class Addcategory extends StatefulWidget {
  const Addcategory({Key? key}) : super(key: key);

  @override
  State<Addcategory> createState() => _AddcategoryState();
}

class _AddcategoryState extends State<Addcategory> {
  final categoryController = TextEditingController();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, ('/total_categories'));
        }, icon: Icon(Icons.arrow_back)),
        title: const Text('Add New categorys'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                filled: true,
                labelText: "Add category",
                labelStyle: TextStyle(fontSize: 15),
                hintText: "Enter category Name",
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: InkWell(
              onTap: isSaving
                  ? null
                  : () async {
                setState(() {
                  isSaving = true;
                });

                String name = categoryController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please Enter The Fields")),
                  );
                  setState(() {
                    isSaving = false;
                  });
                } else {
                  try {
                    await Provider.of<CategoryProvider>(context, listen: false)
                        .addcategory(name);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data Saved Successfully")),
                    );
                    categoryController.clear();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  } finally {
                    setState(() {
                      isSaving = false;
                    });
                  }
                }
              },
              child: Container(
                width: 200.0,
                height: 50.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0A45E),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Center(
                  child: Text(
                    isSaving ? "Saving..." : "Save category",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
