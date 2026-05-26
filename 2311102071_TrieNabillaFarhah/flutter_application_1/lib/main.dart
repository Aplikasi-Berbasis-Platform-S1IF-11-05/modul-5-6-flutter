import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DomainPage(),
    );
  }
}

class DomainPage extends StatefulWidget {
  const DomainPage({super.key});

  @override
  State<DomainPage> createState() => _DomainPageState();
}

class _DomainPageState extends State<DomainPage> {
  List domains = [];

  Future<void> fetchDomains() async {
    final response = await http.get(
      Uri.parse('https://api.qemail.web.id/v1/email/domains'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        domains = data;
      });
    } else {
      throw Exception('Gagal mengambil data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDomains();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QEmail Domains")),

      body: ListView.builder(
        itemCount: domains.length,

        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),

            child: ListTile(
              leading: Text(domains[index]['id'].toString()),

              title: Text(domains[index]['name']),
            ),
          );
        },
      ),
    );
  }
}
