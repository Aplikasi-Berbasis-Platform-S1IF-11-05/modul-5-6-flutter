import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Domain {
  final int id;
  final String name;

  Domain({required this.id, required this.name});

  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(id: json['id'], name: json['name']);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<List<Domain>> fetchDomains() async {
    final response = await http.get(
      Uri.parse('https://api.qemail.web.id/v1/email/domains'),
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);

      return jsonData.map((item) {
        return Domain.fromJson(item);
      }).toList();
    } else {
      throw Exception('Gagal mengambil data API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QEmail Domains',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Data Email Domains'),
          backgroundColor: Colors.blue,
        ),
        body: FutureBuilder<List<Domain>>(
          future: fetchDomains(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Terjadi error: ${snapshot.error}'));
            }

            final domains = snapshot.data ?? [];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: domains.length,
                itemBuilder: (context, index) {
                  final domain = domains[index];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text(domain.id.toString())),
                      title: Text(domain.name),
                      subtitle: Text('ID: ${domain.id}'),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
