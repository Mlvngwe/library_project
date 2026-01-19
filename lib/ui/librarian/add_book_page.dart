import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryController = TextEditingController();
  String _selectedSource = 'Sumbangan';
  bool _isLoading = false; // Untuk search Google
  bool _isSaving = false;  // UNTUK SIMPAN KE FIREBASE
  String _imageUrl = '';

  Future<void> _searchBook() async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isLoading = true);
    final result = await BookService.searchGoogleBooks(_titleController.text);
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _titleController.text = result['title'];
        _authorController.text = result['author'];
        _categoryController.text = result['category'];
        _imageUrl = result['imageUrl'] ?? '';
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Buku")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Judul Buku"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _isLoading 
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.search, color: Colors.blue),
                        onPressed: _searchBook,
                      ),
                ],
              ),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: "Penulis"),
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
              const SizedBox(height: 20),
              // PREVIEW GAMBAR (Biar tahu linknya masuk)
              if (_imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.network(_imageUrl, height: 100, errorBuilder: (c, e, s) => const Icon(Icons.book, size: 50)),
                ),
              DropdownButtonFormField<String>(
                initialValue: _selectedSource,
                items: ['Sumbangan', 'Beli', 'Hibah'].map((s) => 
                  DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedSource = val!),
                decoration: const InputDecoration(labelText: "Sumber Buku"),
              ),
              const SizedBox(height: 30),

              // TOMBOL SIMPAN DENGAN LOGIKA LOADING
              _isSaving 
                ? const CircularProgressIndicator() 
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_titleController.text.isEmpty) return;

                        // 1. Simpan provider ke variabel SEBELUM await
                        final bookProvider = context.read<BookProvider>(); 
                        final scaffoldMessenger = ScaffoldMessenger.of(context); // Simpan ini juga jika perlu
                        final navigator = Navigator.of(context); // Simpan navigatornya

                        setState(() => _isSaving = true);

                        try {
                          final newBook = Book(
                            id: DateTime.now().toString(),
                            title: _titleController.text,
                            author: _authorController.text,
                            category: _categoryController.text,
                            source: _selectedSource,
                            imageUrl: _imageUrl,
                          );

                          // 2. Panggil pakai variabel, bukan pakai context lagi
                          await bookProvider.addBook(newBook);

                          // 3. Cek mounted sebelum pindah halaman
                          if (!mounted) return;
                          navigator.pop(); // Pakai variabel navigator yang sudah disimpan
                          
                        } catch (e) {
                          if (!mounted) return;
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text("Gagal Simpan: $e")),
                          );
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
                      child: const Text("Simpan Buku"),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}