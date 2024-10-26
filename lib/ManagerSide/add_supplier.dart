import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/supplierprovider.dart';

class AddSupplierPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supplierProvider = Provider.of<SupplierProvider>(context);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        leading: IconButton(onPressed: (){
          Navigator.pushNamed(context, ('/total_suppliers'));
        }, icon: Icon(Icons.arrow_back)),
        title: const Text('Add Suppliers'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: supplierProvider.nameController,
              decoration: const InputDecoration(
                  labelText: 'Supplier Name',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: supplierProvider.addressController,
              decoration: const InputDecoration(labelText: 'Address',border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: supplierProvider.contactController,
              decoration: const InputDecoration(labelText: 'Contact Number',border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: supplierProvider.emailController,
              decoration: const InputDecoration(labelText: 'Email',border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: supplierProvider.gstController,
              decoration: const InputDecoration(labelText: 'GST Number',border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: (){
                supplierProvider.addSupplier(context);
              },
              child: const Text('Add Item',style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
//
