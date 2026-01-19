import 'package:flutter/material.dart';
import '../models/book_model.dart';

class LoanProvider with ChangeNotifier {
  // Kita simpan daftar buku yang sedang dipinjam
  final List<Book> _myLoans = [];

  List<Book> get myLoans => _myLoans;

  // Librarian butuh ini untuk melihat siapa saja yang pinjam
  // Untuk sementara kita pakai list yang sama
  List<Book> get activeLoans => _myLoans; 

  void pinjamBuku(Book book) {
    _myLoans.add(book);
    notifyListeners();
  }

  void kembalikanBuku(String bookId) {
    _myLoans.removeWhere((b) => b.id == bookId);
    notifyListeners();
  }
}