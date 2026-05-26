// 2311102318 - Grashela Ayudia Prameswari
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/domain_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.qemail.web.id/v1/email/domains';

  Future<List<DomainModel>> fetchDomains() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DomainModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data: Status ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
    }
  }
}
