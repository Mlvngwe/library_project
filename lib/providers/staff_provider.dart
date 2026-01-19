import 'package:flutter/material.dart';
import '../models/staff_model.dart';

class StaffProvider with ChangeNotifier {
  final List<Staff> _staffs = [
    Staff(id: '1', name: 'Budi Librarian', email: 'budi@perpus.com'),
  ];

  List<Staff> get staffs => _staffs;

  void addStaff(String name, String email) {
    _staffs.add(Staff(id: DateTime.now().toString(), name: name, email: email));
    notifyListeners();
  }

  void removeStaff(String id) {
    _staffs.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}