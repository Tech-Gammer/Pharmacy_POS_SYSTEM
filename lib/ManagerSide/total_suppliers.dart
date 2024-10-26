import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/supplierprovider.dart';

class ViewSuppliersPage extends StatefulWidget {
  @override
  _ViewSuppliersPageState createState() => _ViewSuppliersPageState();
}

class _ViewSuppliersPageState extends State<ViewSuppliersPage> {
  @override
  Widget build(BuildContext context) {
    final supplierProvider = Provider.of<SupplierProvider>(context);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, ('/managerpage'));
        }, icon: Icon(Icons.arrow_back)),
        title: const Text('Add New Medicine'),
        backgroundColor: Colors.teal,
      ),
      body: supplierProvider.suppliers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: supplierProvider.suppliers.length,
        itemBuilder: (context, index) {
          final supplier = supplierProvider.suppliers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(supplier['name'] ?? 'No Name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Address: ${supplier['address'] ?? 'No Address'}'),
                  Text('Contact: ${supplier['contact'] ?? 'No Contact'}'),
                  Text('Email: ${supplier['email'] ?? 'No Email'}'),
                  Text('GST: ${supplier['gst'] ?? 'No GST'}'),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSupplierDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddSupplierDialog() {
    Navigator.pushNamed(context, '/add_suppliers');
  }
}
