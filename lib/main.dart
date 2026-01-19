import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/loan_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      // --- TAMBAHKAN BUILDER INI ---
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.grey[200], // Warna luar aplikasi
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500), // Lebar maksimal HP
              child: Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10)
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}