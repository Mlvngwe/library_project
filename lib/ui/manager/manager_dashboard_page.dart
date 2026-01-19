import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/book_provider.dart';
import '../../../providers/auth_provider.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager Dashboard"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // 1. Jalankan logout dari provider
              await context.read<AuthProvider>().logout();
              
              // 2. Cek mounted untuk keamanan context
              if (!context.mounted) return;
              
              // 3. Paksa pindah halaman ke login
              context.go('/login');
            },
          )
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          final books = bookProvider.books;
          
          // Logika Hitung Statistik Detail
          int totalBuku = books.length;
          int jmlSumbangan = books.where((b) => b.source == 'Sumbangan').length;
          int jmlBeli = books.where((b) => b.source == 'Beli').length;
          int jmlHibah = books.where((b) => b.source == 'Hibah').length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Statistik Koleksi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Card Utama Total
                _buildSummaryCard("Total Koleksi", "$totalBuku", Icons.book, Colors.indigo),
                
                const SizedBox(height: 12),

                // Row Statistik Detail (Sumbangan, Beli, Hibah)
                Row(
                  children: [
                    _buildSmallStat("Sumbangan", "$jmlSumbangan", Colors.orange),
                    const SizedBox(width: 8),
                    _buildSmallStat("Pembelian", "$jmlBeli", Colors.blue),
                    const SizedBox(width: 8),
                    _buildSmallStat("Hibah", "$jmlHibah", Colors.purple),
                  ],
                ),

                const SizedBox(height: 32),
                const Text(
                  "Menu Manajemen",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Tombol Kelola Staff
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.people, color: Colors.indigo),
                    title: const Text("Kelola Staff Librarian"),
                    subtitle: const Text("Tambah atau hapus akun petugas"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go('/manager/staff'),
                  ),
                ),
                
                const SizedBox(height: 10),

                // Tombol Laporan
               Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.green),
                  title: const Text("Laporan Operasional"),
                  subtitle: const Text("Data aktivitas bulanan"),
                  onTap: () {
                    // HAPUS SNACKBAR LAMA, GANTI DENGAN INI:
                    context.go('/manager/report'); 
                  },
                ),
              ),
              ],
            ),
          );
        },
      ),
    );
  }

  // HELPER WIDGETS (Diletakkan di dalam Class tapi di luar Build)
  
  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(icon, color: Colors.white24, size: 40),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}