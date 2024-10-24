import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/unitprovider.dart';

class Addunit extends StatefulWidget {
  const Addunit({Key? key}) : super(key: key);

  @override
  State<Addunit> createState() => _AddunitState();
}

class _AddunitState extends State<Addunit> {
  final unitController = TextEditingController();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, ('/total_units'));
        }, icon: Icon(Icons.arrow_back)),
        title: const Text('Add New Units'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: unitController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                filled: true,
                labelText: "Add Unit",
                labelStyle: TextStyle(fontSize: 15),
                hintText: "Enter Unit Name",
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

                String name = unitController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please Enter The Fields")),
                  );
                  setState(() {
                    isSaving = false;
                  });
                } else {
                  try {
                    await Provider.of<UnitProvider>(context, listen: false)
                        .addUnit(name);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data Saved Successfully")),
                    );
                    unitController.clear();
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
                    isSaving ? "Saving..." : "Save Unit",
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
