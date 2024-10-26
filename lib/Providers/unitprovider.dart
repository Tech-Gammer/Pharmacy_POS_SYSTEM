// providers/unit_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class Unit {
  String id;
  String name;

  Unit({required this.id, required this.name});
}


class UnitProvider with ChangeNotifier {
  final DatabaseReference dref = FirebaseDatabase.instance.ref().child("unit");
  List<Unit> _units = [];

  List<Unit> get units => _units;

  Future<void> addUnit(String name) async {
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
      throw Exception("Unit already exists");
    }
  }
  Future<void> fetchUnits() async {
    try {
      final unitRef = FirebaseDatabase.instance.ref("unit");
      final snapshot = await unitRef.once();

      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        _units = data.entries
            .map((entry) => Unit(id: entry.key, name: entry.value['name'].toString()))
            .toList();
      } else {
        _units = [];
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching units: $e');
    }
  }

  Future<void> deleteUnit(String unitId) async {
    try {
      final unitRef = FirebaseDatabase.instance.ref("unit").child(unitId);
      await unitRef.remove();

      // Remove unit locally
      _units.removeWhere((unit) => unit.id == unitId);
      notifyListeners();
    } catch (e) {
      print('Error deleting unit: $e');
    }
  }
}
