import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Wildan Fachri Dzulfikar 2311102107 IF-11-05
void main() {
  runApp(const DomainApp());
}

class DomainApp extends StatelessWidget {
  const DomainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Domain Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0A192F), // Navy
        scaffoldBackgroundColor: const Color(0xFF0A192F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A192F),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF64FFDA)), // Cyan
          titleTextStyle: TextStyle(
            color: Color(0xFF64FFDA),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF64FFDA),
          secondary: Color(0xFF64FFDA),
          surface: Color(0xFF112240),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const DomainListScreen(),
    );
  }
}

class DomainModel {
  final int id;
  final String name;

  DomainModel({required this.id, required this.name});

  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://api.qemail.web.id/v1/email/domains';

  static Future<List<DomainModel>> fetchDomains() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        // Parse response body (list of JSON objects)
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => DomainModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data (Status Code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }
}

class DomainListScreen extends StatefulWidget {
  const DomainListScreen({super.key});

  @override
  State<DomainListScreen> createState() => _DomainListScreenState();
}

class _DomainListScreenState extends State<DomainListScreen> {
  late Future<List<DomainModel>> futureDomains;

  @override
  void initState() {
    super.initState();
    futureDomains = ApiService.fetchDomains();
  }

  void _refreshData() {
    setState(() {
      futureDomains = ApiService.fetchDomains();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOMAIN LIST'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          )
        ],
      ),
      body: FutureBuilder<List<DomainModel>>(
        future: futureDomains,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64FFDA)),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64FFDA),
                        foregroundColor: const Color(0xFF0A192F),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data domain.'));
          }

          final domains = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: domains.length,
            itemBuilder: (context, index) {
              final domain = domains[index];
              return Hero(
                tag: 'domain_card_${domain.id}',
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: const Color(0xFF112240),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DomainDetailScreen(domain: domain),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF233554),
                          child: Icon(
                            Icons.language,
                            color: Color(0xFF64FFDA),
                          ),
                        ),
                        title: Text(
                          domain.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          'ID: ${domain.id}',
                          style: const TextStyle(
                            color: Color(0xFF8892B0),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF64FFDA),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DomainDetailScreen extends StatelessWidget {
  final DomainModel domain;

  const DomainDetailScreen({super.key, required this.domain});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOMAIN DETAIL'),
      ),
      body: Center(
        child: Hero(
          tag: 'domain_card_${domain.id}',
          child: Card(
            margin: const EdgeInsets.all(24),
            color: const Color(0xFF112240),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF233554),
                    child: Icon(
                      Icons.domain,
                      size: 40,
                      color: Color(0xFF64FFDA),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    domain.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A192F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF64FFDA).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Domain ID: ${domain.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64FFDA),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Kembali ke Daftar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64FFDA),
                        foregroundColor: const Color(0xFF0A192F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
