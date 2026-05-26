import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Fetch API Domain',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DomainListScreen(),
    );
  }
}

class DomainListScreen extends StatefulWidget {
  const DomainListScreen({super.key});

  @override
  State<DomainListScreen> createState() => _DomainListScreenState();
}

class _DomainListScreenState extends State<DomainListScreen> {
  // List untuk menampung data dari API
  List<dynamic> _domains = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDomains();
  }

  // Fungsi untuk mengambil data dari API
  Future<void> _fetchDomains() async {
    final url = Uri.parse('https://api.qemail.web.id/v1/email/domains');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Berdasarkan dokumentasi umum, sesuaikan struktur response jika dibungkus objek
        // Di sini kita asumsikan response langsung berupa List atau mengandung key 'data'
        setState(() {
          if (data is List) {
            _domains = data;
          } else if (data is Map && data.containsKey('data')) {
            _domains = data['data'];
          } else {
            _domains = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Domain QEmail'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _domains.isEmpty
                  ? const Center(child: Text('Tidak ada data domain.'))
                  : ListView.builder(
                      itemCount: _domains.length,
                      itemBuilder: (context, index) {
                        final domain = _domains[index];
                        final id = domain['id']?.toString() ?? '-';
                        final name = domain['name']?.toString() ?? '-';

                        // IMPLEMENTASI ROW/COLUMN:
                        // Menggunakan Card dan Padding, di dalamnya terdapat Column 
                        // untuk menyusun teks ID dan Name secara vertikal.
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.fingerprint, color: Colors.blue, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ID: $id',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.domain, color: Colors.green, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Domain: $name',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}