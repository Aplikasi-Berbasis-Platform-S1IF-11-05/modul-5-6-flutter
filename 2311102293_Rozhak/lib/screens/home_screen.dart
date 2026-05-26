import 'package:flutter/material.dart';

import '../models/domain_model.dart';
import '../services/api_service.dart';
import '../widgets/domain_list_tile.dart';

/// Layar utama yang menampilkan daftar domain email.
///
/// Layar ini mengambil data dari API lalu menyajikannya
/// dalam kartu-kartu sederhana dengan gaya yang tetap bersih.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  /// Membuat state yang mengelola layar utama.
  ///
  /// Method ini menghubungkan widget statis dengan logika
  /// state yang memuat data domain.
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State untuk [HomeScreen].
///
/// State ini memuat data saat layar dibuka dan menangani
/// kondisi muat, gagal, serta data yang sudah siap tampil.
class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<DomainModel>> _futureDomains;

  /// Menginisialisasi pengambilan data domain.
  ///
  /// Permintaan API dijalankan sekali saat state dibuat
  /// agar proses tampilannya tetap ringan.
  @override
  void initState() {
    super.initState();
    _futureDomains = _apiService.fetchDomains();
  }

  /// Membangun tampilan utama layar beranda.
  ///
  /// Method ini mengatur alur muat, error, kondisi kosong,
  /// dan daftar domain ketika data sudah tersedia.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'QEmail Domains',
          style: TextStyle(
            color: Color(0xFF37352F),
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE9E9E7),
            height: 1.0,
          ),
        ),
      ),
      body: FutureBuilder<List<DomainModel>>(
        future: _futureDomains,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF37352F),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF787774)),
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada data domain yang tersedia.',
                style: TextStyle(color: Color(0xFF787774)),
              ),
            );
          }

          final domains = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: domains.length,
            itemBuilder: (context, index) {
              return DomainListTile(domain: domains[index]);
            },
          );
        },
      ),
    );
  }
}