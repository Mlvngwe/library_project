import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Staff Librarian")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showRegisterDialog(context, 'librarian'),
              icon: const Icon(Icons.add),
              label: const Text("Tambah Librarian Baru"),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI DIALOG UNTUK INPUT EMAIL & PASS ---
  void _showRegisterDialog(BuildContext context, String role) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Daftar sebagai $role"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AuthProvider>().registerUser(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                  role,
                );
                if (!context.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil Terdaftar!")));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}