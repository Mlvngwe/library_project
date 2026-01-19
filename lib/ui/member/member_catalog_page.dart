import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/book_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/loan_provider.dart';

class MemberCatalogPage extends StatefulWidget {
  const MemberCatalogPage({super.key});

  @override
  State<MemberCatalogPage> createState() => _MemberCatalogPageState();
}

class _MemberCatalogPageState extends State<MemberCatalogPage> {
  String _searchQuery = ''; // Variabel untuk menyimpan input pencarian

  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    // Gunakan addPostFrameCallback agar dijalankan tepat setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookProvider>().fetchBooks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Katalog Buku"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu), // Ikon riwayat
            onPressed: () => context.push('/member/history'),
          ),
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
          ),
        ],
      ),
      body: Column(
        children: [
          // BAR PENCARIAN
          SizedBox(
            height: 50,
            child: Consumer<BookProvider>(
              builder: (context, bookProv, child) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: bookProv.allCategories.length,
                  itemBuilder: (context, index) {
                    final category = bookProv.allCategories[index];
                    final isSelected = _selectedCategory == category;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                        selectedColor: Colors.green[700],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari judul buku atau penulis...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // LIST BUKU DENGAN FILTER SEARCH
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                // Filter buku berdasarkan input search
                final filteredBooks = bookProvider.books.where((book) {
                final matchesSearch = book.title.toLowerCase().contains(_searchQuery) ||
                                      book.author.toLowerCase().contains(_searchQuery);
                final matchesCategory = _selectedCategory == 'Semua' || book.category == _selectedCategory;
                
                return matchesSearch && matchesCategory;
              }).toList();

                if (filteredBooks.isEmpty) {
                  return const Center(
                    child: Text("Buku tidak ditemukan."),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4), // Biar pojokannya agak bulat dikit
                          child: Container(
                            width: 50,
                            height: 75,
                            color: Colors.green[50], // Warna background kalau gambar lagi loading
                            child: book.imageUrl.isNotEmpty
                                ? Image.network(
                                    book.imageUrl,
                                    fit: BoxFit.cover,
                                    // Handler kalau gambar gagal dimuat (misal internet lemot)
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, color: Colors.grey);
                                    },
                                  )
                                : const Icon(Icons.book, color: Colors.green), // Default kalau emang gak ada cover
                          ),
                        ),
                        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${book.author} | ${book.source}"),
                        // Ganti trailing di ListTile menjadi tombol pinjam
                        trailing: ElevatedButton(
                          onPressed: book.isAvailable ? () {
                            // 1. Kirim objek 'book' secara utuh (bukan String id-nya saja)
                            context.read<LoanProvider>().pinjamBuku(book); 
                            
                            // 2. Update status ketersediaan di BookProvider
                            context.read<BookProvider>().toggleBookAvailability(book.id, false);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Berhasil meminjam ${book.title}"))
                            );
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: book.isAvailable ? Colors.green : Colors.grey,
                          ),
                          child: Text(book.isAvailable ? "Pinjam" : "Dipinjam", style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}