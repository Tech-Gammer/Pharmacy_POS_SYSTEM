import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/unitprovider.dart';
import 'add_units.dart';


class ShowUnit extends StatefulWidget {
  const ShowUnit({super.key});

  @override
  State<ShowUnit> createState() => _ShowUnitState();
}

class _ShowUnitState extends State<ShowUnit> {
  @override
  void initState() {
    super.initState();
    // Fetch units when the widget is initialized
    Provider.of<UnitProvider>(context, listen: false).fetchUnits();
  }

  void showDeleteConfirmationDialog(String unitId, String unitName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete the unit '$unitName'?"),
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
                await Provider.of<UnitProvider>(context, listen: false).deleteUnit(unitId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Unit deleted successfully")),
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
    final unitProvider = Provider.of<UnitProvider>(context);
    final units = unitProvider.units;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, ('/managerpage'));
        }, icon: Icon(Icons.arrow_back)),
        title: const Text('Total Units'),
        backgroundColor: Colors.teal,
      ),
      body: units.isEmpty
          ? Center(
        child: Text(
          'No units found.',
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: units.length,
        itemBuilder: (context, index) {
          Unit unit = units[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(unit.name, ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => showDeleteConfirmationDialog(unit.id, unit.name),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddUnitDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor:  Colors.teal,
      ),
    );
  }

  void showAddUnitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Addunit();
      },
    );
  }
}
