// Ben Waiz Pintus W. 2311102169 
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
    return MaterialApp(
      title: 'Domain Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A), // Dark blue
          background: const Color(0xFFF3F4F6), // Light gray background
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        useMaterial3: true,
      ),
      home: const DomainTableView(),
    );
  }
}

class Domain {
  final int id;
  final String name;

  Domain({required this.id, required this.name});

  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(
      id: json['id'],
      name: json['name'],
    );
  }
}

class DomainTableView extends StatefulWidget {
  const DomainTableView({super.key});

  @override
  State<DomainTableView> createState() => _DomainTableViewState();
}

class _DomainTableViewState extends State<DomainTableView> {
  List<Domain> _domains = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Sorting variables
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDomains();
  }

  Future<void> _fetchDomains() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(Uri.parse('https://api.qemail.web.id/v1/email/domains'));

      if (response.statusCode == 200) {
        final List<dynamic> domainsJson = json.decode(response.body);
        
        setState(() {
          _domains = domainsJson.map((json) => Domain.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Gagal mengambil data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Terjadi kesalahan koneksi: $e';
        _isLoading = false;
      });
    }
  }

  void _sort<T>(Comparable<T> Function(Domain d) getField, int columnIndex, bool ascending) {
    _domains.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Domain Management', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A), // Dark blue
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Domain List Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage and monitor available system domains from the centralized academic database.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1E3A8A),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDomains,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_domains.isEmpty) {
      return const Center(child: Text('Tidak ada data domain.'));
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48), // Padding adjusted
          child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            headingRowColor: MaterialStateProperty.resolveWith(
              (states) => const Color(0xFFF3F4F6),
            ),
            dataRowColor: MaterialStateProperty.resolveWith(
              (states) => Colors.white,
            ),
            border: const TableBorder(
              horizontalInside: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            columns: [
              DataColumn(
                label: const Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                onSort: (columnIndex, ascending) {
                  _sort<num>((d) => d.id, columnIndex, ascending);
                },
              ),
              DataColumn(
                label: const Text('Domain Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                onSort: (columnIndex, ascending) {
                  _sort<String>((d) => d.name, columnIndex, ascending);
                },
              ),
            ],
            rows: _domains.map((domain) {
              return DataRow(
                cells: [
                  DataCell(Text(domain.id.toString(), style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(domain.name, style: const TextStyle(color: Color(0xFF374151)))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
