import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data buku dari provider
    final bookProvider = context.watch<BookProvider>();
    final totalBuku = bookProvider.books.length;
    
    // Anggap saja kita hitung buku dipinjam dari status buku
    // (Jika kamu punya field isBorrowed di model Book)
    final bukuDipinjam = bookProvider.books.where((b) => b.source == 'Dipinjam').length; 

    return Scaffold(
      appBar: AppBar(title: const Text("Laporan Operasional")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildReportCard("Total Koleksi", "$totalBuku", Icons.book, Colors.blue),
            _buildReportCard("Buku Dipinjam", "$bukuDipinjam", Icons.bookmark, Colors.orange),
            _buildReportCard("Total Member", "5", Icons.people, Colors.green), // Ini contoh statis dulu
            _buildReportCard("Kategori", "4", Icons.category, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}