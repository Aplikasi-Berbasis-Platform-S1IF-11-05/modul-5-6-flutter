import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<List<dynamic>> fetchDomains() async {
    final response = await http.get(
      Uri.parse('https://api.qemail.web.id/v1/email/domains'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data dari API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Domain Email'),
          centerTitle: true,
        ),
        body: FutureBuilder<List<dynamic>>(
          future: fetchDomains(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Terjadi error: ${snapshot.error}'),
              );
            }

            final domains = snapshot.data ?? [];

            return SingleChildScrollView(
              child: Column(
                children: domains.map((domain) {
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(domain['id'].toString()),
                      ),
                      title: Text(
                        domain['name'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('ID: ${domain['id']}'),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}