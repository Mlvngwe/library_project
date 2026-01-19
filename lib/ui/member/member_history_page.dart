import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/loan_provider.dart';

class MemberHistoryPage extends StatelessWidget {
  const MemberHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buku Saya")),
      body: Consumer<LoanProvider>(
        builder: (context, loanProv, child) {
          if (loanProv.myLoans.isEmpty) {
            return const Center(child: Text("Kamu belum meminjam buku apa pun."));
          }

          return ListView.builder(
            itemCount: loanProv.myLoans.length,
            itemBuilder: (context, index) {
              final book = loanProv.myLoans[index];
              return ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.green),
                title: Text(book.title),
                subtitle: Text("Penulis: ${book.author}"),
                trailing: const Text("Sedang Dipinjam", style: TextStyle(color: Colors.orange)),
              );
            },
          );
        },
      ),
    );
  }
}