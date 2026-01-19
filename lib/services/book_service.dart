import 'dart:convert';
import 'dart:developer'; // Untuk fungsi log()
import 'package:http/http.dart' as http;

class BookService {
  static Future<Map<String, dynamic>?> searchGoogleBooks(String title) async {
    // Menghindari spasi di URL
    final query = Uri.encodeComponent(title);
    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=1');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0) {
          final bookInfo = data['items'][0]['volumeInfo'];
          // Cari di bagian return dalam BookService, ubah jadi begini:
          return {
            'title': bookInfo['title'] ?? '',
            'author': (bookInfo['authors'] as List?)?.first ?? 'Unknown Author',
            'category': (bookInfo['categories'] as List?)?.first ?? 'General',
            // Ambil link gambar dan pastikan pakai https agar tidak kena blokir sistem
            'imageUrl': bookInfo['imageLinks']?['thumbnail']?.replaceFirst('http://', 'https://') ?? '',
          };
        }
      }
    } catch (e) {
      log("Error fetching books: $e"); // Pakai log() dari dart:developer
    }
    return null;
  }
}