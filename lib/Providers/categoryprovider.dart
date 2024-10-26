// providers/category_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class Category {
  String id;
  String name;

  Category({required this.id, required this.name});
}


class CategoryProvider with ChangeNotifier {

  final DatabaseReference dref = FirebaseDatabase.instance.ref().child("category");
  List<Category> _categorys = [];

  List<Category> get categorys => _categorys;
  Future<void> addcategory(String name) async {
    // Check for duplicates
    final snapshot = await dref.orderByChild('name').equalTo(name).once();
    if (!snapshot.snapshot.exists) {
      String id = dref.push().key.toString();
      await dref.child(id).set({
        'name': name,
        'id': id,
      });
      notifyListeners();
    } else {
      throw Exception("category already exists");
    }
  }
  Future<void> fetchcategorys() async {
    try {
      final categoryRef = FirebaseDatabase.instance.ref("category");
      final snapshot = await categoryRef.once();

      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        _categorys = data.entries
            .map((entry) => Category(id: entry.key, name: entry.value['name'].toString()))
            .toList();
      } else {
        _categorys = [];
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching categorys: $e');
    }
  }

  Future<void> deletecategory(String categoryId) async {
    try {
      final categoryRef = FirebaseDatabase.instance.ref("category").child(categoryId);
      await categoryRef.remove();

      // Remove category locally
      _categorys.removeWhere((category) => category.id == categoryId);
      notifyListeners();
    } catch (e) {
      print('Error deleting category: $e');
    }
  }
}
