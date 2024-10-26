import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';



class SupplierProvider extends ChangeNotifier {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('suppliers');

  final List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> get suppliers => _suppliers;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  SupplierProvider() {
    fetchSuppliers();
  }




  Future<void> addSupplier(BuildContext context) async {
    String name = nameController.text.trim();
    String address = addressController.text.trim();
    String contact = contactController.text.trim();
    String email = emailController.text.trim();
    String gst = gstController.text.trim();



    if (name.isNotEmpty &&
        address.isNotEmpty &&
        contact.isNotEmpty &&
        email.isNotEmpty &&
        gst.isNotEmpty) {
      try {
        String key = _databaseRef.push().key!;
        await _databaseRef.child(key).set({
          'supplierID':key,
          'name': name,
          'address': address,
          'contact': contact,
          'email': email,
          'gst': gst,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Supplier Added Successfully')),
        );
        clearControllers();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding supplier: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields')),
      );
    }
  }

  Future<void> fetchSuppliers() async {
    _databaseRef.onValue.listen((event) {
      _suppliers.clear();
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          _suppliers.add({
            'supplierID': key,
            'name': value['name'],
            'address': value['address'],
            'contact': value['contact'],
            'email': value['email'],
            'gst': value['gst'],
          });
        });
      }
      notifyListeners();
    });
  }

  void clearControllers() {
    nameController.clear();
    addressController.clear();
    contactController.clear();
    emailController.clear();
    gstController.clear();
    notifyListeners();
  }




  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    contactController.dispose();
    emailController.dispose();
    gstController.dispose();
    super.dispose();
  }
}
