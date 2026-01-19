import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../ui/librarian/add_book_page.dart';
import '../ui/librarian/circulation_page.dart';
import '../ui/member/member_catalog_page.dart';
import '../ui/manager/manager_dashboard_page.dart';
import '../ui/manager/staff_management_page.dart';
import '../ui/member/member_history_page.dart';
import '../ui/manager/report_page.dart';


class AppRouter {
  static final router = GoRouter(
      initialLocation: '/login',
      // INI PANCINGANNYA: 
      // Setiap kali AuthProvider berubah (notifyListeners), GoRouter akan cek ulang Redirect
      refreshListenable: null, // Kita akan isi ini di main.dart nanti supaya lebih aman
      
      redirect: (context, state) {
        // Pakai context.read karena kita di dalam fungsi statis
        final auth = context.read<AuthProvider>();
        final loggingIn = state.matchedLocation == '/login';

        if (!auth.isAuthenticated && !loggingIn) return '/login';
        
        // Jika sudah login tapi masih di halaman login, lempar ke dashboard sesuai role
        if (auth.isAuthenticated && loggingIn) {
          if (auth.userRole == 'manager') return '/manager';
          if (auth.userRole == 'librarian') return '/librarian';
          return '/member';
        }
        return null;
      },
      routes: [
      // 1. ROUTE LOGIN
      GoRoute(
        path: '/login', 
        builder: (context, state) => const LoginPage()
      ),

      // 2. ROUTE MEMBER (Induk)
      GoRoute(
        path: '/member',
        builder: (context, state) => const MemberCatalogPage(),
        routes: [
          // Sub-route: /member/history
          GoRoute(
            path: 'history', 
            builder: (context, state) => const MemberHistoryPage()
          ),
        ],
      ),

      // 3. ROUTE LIBRARIAN (Induk)
      GoRoute(
        path: '/librarian',
        builder: (context, state) => const LibrarianDashboard(),
        routes: [
          // Sub-route: /librarian/add-book
          GoRoute(
            path: 'add-book', 
            builder: (context, state) => const AddBookPage()
          ),
          // Sub-route: /librarian/circulation
          GoRoute(
            path: 'circulation', 
            builder: (context, state) => const CirculationPage()
          ),
        ],
      ),

      // 4. ROUTE MANAGER (Induk)
      GoRoute(
        path: '/manager',
        builder: (context, state) => const ManagerDashboardPage(),
        routes: [ // Ini artinya sub-halaman dari manager
          // TAMBAHKAN INI:
          GoRoute(
            path: 'staff', // Nanti aksesnya jadi /manager/staff
            builder: (context, state) => const StaffManagementPage(),
          ),
          // TAMBAHKAN INI JUGA:
          GoRoute(
            path: 'report', // Nanti aksesnya jadi /manager/report
            builder: (context, state) => const ReportPage(),
          ),
        ],
      ),
    ],
  );
}

// --- WIDGET PENDUKUNG (LOGIN & DASHBOARD LIBRARIAN) ---

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Perpustakaan")),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 80, color: Colors.green),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // BAGIAN TOMBOL
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else ...[  // Pakai spread operator biar bisa naruh banyak widget
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, 
                          foregroundColor: Colors.white
                        ),
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          try {
                            await context.read<AuthProvider>().login(
                              _emailController.text.trim(), 
                              _passwordController.text.trim()
                            );
                            if (!context.mounted) return;
                            final role = context.read<AuthProvider>().userRole;
                            if (role == 'librarian') { context.go('/librarian'); }
                            else if (role == 'manager') { context.go('/manager'); }
                            else { context.go('/member'); }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gagal Login: $e")),
                            );
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                        child: const Text("LOGIN"),
                      ),
                    ),
                    const SizedBox(height: 15), // Jarak antar tombol
                    TextButton(
                      onPressed: () => _showRegisterDialog(context, 'member'),
                      child: const Text("Belum punya akun? Daftar Member"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LibrarianDashboard extends StatelessWidget {
  const LibrarianDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kita pakai body saja tanpa AppBar standar biar tampilannya modern
      body: Column(
        children: [
          // HEADER GRADIENT
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.admin_panel_settings, size: 45, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Librarian Dashboard",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Sistem Manajemen Perpustakaan",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          // MENU GRID
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildMenuCard(
                    context,
                    title: "Tambah Buku",
                    subtitle: "Koleksi Baru",
                    icon: Icons.add_box_rounded,
                    color: Colors.blue,
                    onTap: () => context.push('/librarian/add-book'),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Sirkulasi",
                    subtitle: "Pinjam & Kembali",
                    icon: Icons.sync_alt_rounded,
                    color: Colors.orange,
                    onTap: () => context.push('/librarian/circulation'),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Katalog",
                    subtitle: "Lihat Semua",
                    icon: Icons.library_books_rounded,
                    color: Colors.purple,
                    onTap: () => context.push('/member'),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Logout",
                    subtitle: "Keluar Sesi",
                    icon: Icons.power_settings_new_rounded,
                    color: Colors.red,
                    onTap: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pendukung untuk Card Menu
  Widget _buildMenuCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// PASTIKAN ADA (BuildContext context, String role) DI DALAM KURUNG INI
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
              // Panggil fungsi register di provider
              await context.read<AuthProvider>().registerUser(
                emailController.text.trim(),
                passwordController.text.trim(),
                role,
              );
              if (!context.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Berhasil Terdaftar!")),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
          child: const Text("Simpan"),
        ),
      ],
    ),
  );
}
