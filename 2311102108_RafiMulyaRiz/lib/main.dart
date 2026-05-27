import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

/// ==========================================
/// 1. MODEL DATA
/// ==========================================
/// Model data untuk memetakan JSON dari API ke objek Dart.
class Domain {
  final int id;
  final String name;

  Domain({
    required this.id,
    required this.name,
  });

  // Factory constructor untuk membuat objek Domain dari data Map (JSON)
  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

/// ==========================================
/// 2. MAIN APPLICATION WIDGET
/// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Domain List API',
      debugShowCheckedModeBanner: false,
      // Desain Tema: Clean Minimalist (Dominasi Putih dan Biru Muda)
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F8FA), // Warna latar belakang putih kebiruan yang sangat lembut
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF), // Biru premium
          primary: const Color(0xFF007AFF),
          secondary: const Color(0xFFE3F2FD), // Biru muda pastel
          surface: const Color(0xFFF4F8FA),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B), // Warna teks abu-abu gelap/hitam elegan
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF007AFF)),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded Card sesuai Design Notes
            side: const BorderSide(
              color: Color(0xFFE2E8F0), // Border tipis abu-abu lembut
              width: 1.0,
            ),
          ),
        ),
      ),
      home: const DomainListScreen(),
    );
  }
}

/// ==========================================
/// 3. SCREEN / UI IMPLEMENTATION
/// ==========================================
class DomainListScreen extends StatefulWidget {
  const DomainListScreen({super.key});

  @override
  State<DomainListScreen> createState() => _DomainListScreenState();
}

class _DomainListScreenState extends State<DomainListScreen> {
  // Variabel untuk menyimpan future hasil pemanggilan API
  late Future<List<Domain>> _domainListFuture;

  @override
  void initState() {
    super.initState();
    // Memanggil API pertama kali saat widget diinisialisasi
    _domainListFuture = _fetchDomains();
  }

  /// ==========================================
  /// 4. FETCH API FUNCTION (GET METHOD)
  /// ==========================================
  Future<List<Domain>> _fetchDomains() async {
    final url = Uri.parse('https://api.qemail.web.id/v1/email/domains');

    try {
      // Mengirim request GET ke API
      final response = await http.get(url);

      // Cek apakah status code 200 (Success)
      if (response.statusCode == 200) {
        // Mendecode data JSON menjadi List
        final List<dynamic> jsonList = json.decode(response.body);

        // Memetakan setiap objek Map di dalam List ke model Domain
        return jsonList.map((data) => Domain.fromJson(data)).toList();
      } else {
        // Error handling jika API mengembalikan kode error (misal 404 atau 500)
        throw Exception('Gagal mengambil data. Server merespon dengan kode: ${response.statusCode}');
      }
    } catch (error) {
      // Error handling jika terjadi masalah jaringan atau parsing data
      throw Exception('Tidak dapat terhubung ke server. Pastikan koneksi internet Anda aktif.');
    }
  }

  // Fungsi untuk memicu reload/refresh data API
  void _refreshData() {
    setState(() {
      _domainListFuture = _fetchDomains();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Email Domains',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<Domain>>(
        future: _domainListFuture,
        builder: (context, snapshot) {
          // 1. STATE LOADING: Tampilkan Loading Indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mengambil data domain...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // 2. STATE ERROR: Tampilkan Pesan Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFEBEE), // Latar belakang merah muda pastel
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_off_rounded,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshData,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. STATE SUCCESS: Tampilkan Data Domain dalam ListView
          if (snapshot.hasData) {
            final List<Domain> domains = snapshot.data!;

            if (domains.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.folder_open_rounded,
                      color: Colors.grey,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada domain ditemukan',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Ringkasan Info (Design Note: Spacing Rapi)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DAFTAR DOMAIN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.blue.shade700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD), // Biru muda pastel
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${domains.length} Domain',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ListView untuk list Domain
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: domains.length,
                    itemBuilder: (context, index) {
                      final domain = domains[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              // Efek interaktif ketukan kartu
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Memilih domain: ${domain.name}'),
                                  backgroundColor: const Color(0xFF007AFF),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              child: ListTile(
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD), // Biru muda pastel (Design Notes)
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.language_rounded,
                                      color: Color(0xFF007AFF), // Ikon Biru
                                      size: 24,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  domain.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                subtitle: Text(
                                  'ID: ${domain.id}',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Fallback Default
          return const Center(child: Text('Tidak ada data'));
        },
      ),
    );
  }
}
