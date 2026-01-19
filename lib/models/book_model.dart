class Book {
  final String id;
  final String title;
  final String author;
  final String source; // Sumbangan, Beli, Hibah
  final String category;
  final String imageUrl; // Tambahkan ini
  bool isAvailable;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.source,
    required this.category,
    this.imageUrl = '', // Default kosong
    this.isAvailable = true,
  });

  // Konversi dari/ke Firestore
  factory Book.fromMap(Map<String, dynamic> data, String id) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      source: data['source'] ?? 'Sumbangan',
      category: data['category'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'source': source,
      'category': category,
      'isAvailable': isAvailable,
    };
  }
}