import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import ini di atas

class BookProvider with ChangeNotifier {
  List<Book> _books = [];

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Book> get books => _books;

  List<String> get allCategories {
  // Mengambil semua kategori dari buku, lalu hilangkan duplikatnya
  final categories = _books.map((b) => b.category).toSet().toList();
  categories.sort(); // Urutkan sesuai abjad
  return ["Semua", ...categories]; // Tambahkan pilihan "Semua" di awal
  } 

  // Fungsi untuk menambah buku


  // Pastikan hanya ada SATU fungsi addBook ini
  Future<void> addBook(Book book) async {
    try {
      // 1. Simpan ke Firebase Firestore
      await _db.collection('books').add({
        'title': book.title,
        'author': book.author,
        'category': book.category,
        'imageUrl': book.imageUrl,
        'source': book.source,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 2. Update list lokal biar langsung muncul di layar tanpa reload
      _books.add(book);
      notifyListeners();
    } catch (e) {
      debugPrint("Error simpan ke Firestore: $e");
      rethrow;
    }
  }

    Future<void> fetchBooks() async {
      try {
        // Ambil data dari koleksi 'books'
        final snapshot = await _db.collection('books').get();
        
        // Ubah data dari Firebase jadi List Buku
        _books = snapshot.docs.map((doc) {
          final data = doc.data();
          return Book(
            id: doc.id,
            title: data['title'] ?? '',
            author: data['author'] ?? '',
            category: data['category'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            source: data['source'] ?? 'Sumbangan',
          );
        }).toList();

        notifyListeners(); // Kasih tahu UI buat update tampilan
      } catch (e) {
        debugPrint("Gagal narik data buku: $e");
      }
    }

// Tambahkan fungsi ini di dalam class BookProvider
  void toggleBookAvailability(String bookId, bool status) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index].isAvailable = status;
      notifyListeners(); // Ini penting supaya layar Member & Librarian berubah
    }
  }


}