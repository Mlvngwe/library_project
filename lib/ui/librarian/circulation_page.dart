import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/loan_provider.dart';
import '../../../providers/book_provider.dart';

class CirculationPage extends StatelessWidget {
  const CirculationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<LoanProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Sirkulasi")),
      body: loanProvider.activeLoans.isEmpty 
        ? const Center(child: Text("Tidak ada peminjaman aktif"))
        : ListView.builder(
            itemCount: loanProvider.activeLoans.length,
            itemBuilder: (context, index) {
              // Sekarang datanya langsung Book, bukan ID lagi
              final book = loanProvider.activeLoans[index];

              return ListTile(
                leading: const Icon(Icons.book, color: Colors.orange),
                title: Text(book.title),
                subtitle: Text("Peminjam: Member Aktif"), // Nanti bisa kita buat dinamis
                trailing: ElevatedButton(
                  onPressed: () {
                    // 1. Hapus dari daftar pinjam
                    context.read<LoanProvider>().kembalikanBuku(book.id);
                    // 2. Set status buku jadi TERSEDIA lagi
                    context.read<BookProvider>().toggleBookAvailability(book.id, true);
                  },
                  child: const Text("Kembalikan"),
                ),
              );
            },
          ),
    );
  }
}