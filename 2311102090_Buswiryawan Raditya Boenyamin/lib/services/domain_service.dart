// 2311102090-Buswiryawan Raditya Boenyamin
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/domain_model.dart';

class DomainService {
  static const String _baseUrl = 'https://api.qemail.web.id/v1/email/domains';

  /// Fetches the list of domains from the API.
  Future<List<DomainModel>> fetchDomains() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DomainModel.fromJson(json)).toList();
      } else {
        throw 'Gagal mengambil data: Kode ${response.statusCode}';
      }
    } catch (e) {
      throw 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    }
  }
}
