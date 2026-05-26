import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/domain_model.dart';

/// Layanan untuk mengambil dan menyiapkan data domain.
///
/// Kelas ini menangani panggilan API, pemetaan JSON, lalu
/// pengurutan hasil sebelum data masuk ke UI.
class ApiService {
  static const String _baseUrl = 'https://api.qemail.web.id/v1/email/domains';

  /// Mengambil daftar domain dari API jarak jauh.
  ///
  /// Respons dipetakan ke [DomainModel], kemudian diurutkan
  /// berdasarkan ID dari kecil ke besar agar tampilan lebih mudah dipindai.
  Future<List<DomainModel>> fetchDomains() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final domains = jsonResponse.map((data) => DomainModel.fromJson(data)).toList();
        domains.sort((a, b) => a.id.compareTo(b.id));

        return domains;
      } else {
        throw Exception('Gagal memuat data dari server. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }
}