import 'dart:convert';
import 'package:http/http.dart' as http;
import '../entities/domain_entity.dart';

class DomainProvider {
  final String apiUrl =
    'https://corsproxy.io/?https://api.qemail.web.id/v1/email/domains';
  Future<List<DomainEntity>> getDomains() async {
    final response = await http.get(
      Uri.parse(apiUrl),
    );

    if (response.statusCode == 200) {
      final List data =
          jsonDecode(response.body);

      return data
          .map(
            (item) =>
                DomainEntity.fromJson(item),
          )
          .toList();
    } else {
      throw Exception(
        'Gagal mengambil data',
      );
    }
  }
}