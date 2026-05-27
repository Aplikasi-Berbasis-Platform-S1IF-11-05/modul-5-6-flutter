//Geranada Saputra Priambudi 2311102008
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // Base URL endpoint sesuai ketentuan praktikum
  static const String _apiUrl = 'https://api.qemail.web.id/v1/email/random';

  /// Mengambil email acak dari API.
  /// Method: GET
  Future<String> fetchRandomEmail() async {
    final url = Uri.parse(_apiUrl);

    try {
      // Melakukan request GET ke API
      final response = await http.get(url);

      // Jika server mengembalikan response sukses (HTTP 200)
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Cek beberapa kemungkinan struktur JSON agar kode tidak mudah crash
        if (data.containsKey('email')) {
          return data['email'] as String;
        } else if (data.containsKey('data')) {
          final nestedData = data['data'];
          if (nestedData is Map && nestedData.containsKey('email')) {
            return nestedData['email'] as String;
          } else if (nestedData is String) {
            return nestedData;
          }
        }
        
        throw Exception('Format data JSON dari API tidak sesuai standar');
      } else {
        // Jika server mengembalikan response error (misal 404, 500, dll)
        try {
          final errorData = json.decode(response.body);
          final message = errorData['message'] ?? 'Gagal memproses data';
          throw Exception('$message (${response.statusCode})');
        } catch (_) {
          throw Exception('Server mengembalikan Error (${response.statusCode})');
        }
      }
    } catch (e) {
      // Menangkap error jaringan atau parsing
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Kesalahan Koneksi: Pastikan internet aktif ($e)');
    }
  }

  /// Menghasilkan email simulasi ketika API offline/404 untuk demonstrasi antarmuka
  Future<String> fetchMockEmail() async {
    // Memberikan delay buatan selama 1.2 detik untuk mensimulasikan latensi jaringan
    await Future.delayed(const Duration(milliseconds: 1200));
    
    final List<String> mockNames = [
      'gery.pratama',
      'praktikum.abp',
      'telkom.student',
      'mahasiswa.active',
      'flutter.developer',
      'api.tester',
      'dark.theme.fan',
      'future.builder.expert'
    ];
    final List<String> mockDomains = [
      'qemail.web.id',
      'student.telkom-pwt.ac.id',
      'gmail.com',
      'outlook.com'
    ];
    
    mockNames.shuffle();
    mockDomains.shuffle();
    
    // Menambahkan timestamp milidetik agar email selalu unik
    final timestamp = DateTime.now().millisecond;
    
    return '${mockNames.first}$timestamp@${mockDomains.first}';
  }
}
