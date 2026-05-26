// 2311102315 - Muhamad Rafli Al Farizqi
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/domain_model.dart';

enum SortMode { byId, byName }

class ApiService {
  static const String _baseUrl = 'https://api.qemail.web.id/v1/email/domains';

  Future<List<DomainModel>> fetchDomains({
    SortMode sortMode = SortMode.byId,
  }) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final domains =
            data.map((json) => DomainModel.fromJson(json)).toList();

        switch (sortMode) {
          case SortMode.byId:
            domains.sort((a, b) => a.id.compareTo(b.id));
          case SortMode.byName:
            domains.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
        }

        return domains;
      } else {
        throw Exception('Gagal memuat data: Status ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi Anda.');
    }
  }
}
