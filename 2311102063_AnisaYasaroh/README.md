<div align="center">
  <br />
  <h1>LAPORAN PRAKTIKUM <br> APLIKASI BERBASIS PLATFORM </h1>
  <br />
  <h3>MODUL 5-6 <br> FLUTTER </h3>
  <br />
  <img width="512" height="512" alt="telyu" src="https://github.com/user-attachments/assets/724a3291-bcf9-448d-a395-3886a8659d79" />
  <br />
  <br />
  <br />
  <h3>Disusun Oleh :</h3>
  <p>
    <strong>Anisa Yasaroh</strong>
    <br>
    <strong>2311102063</strong>
    <br>
    <strong>S1 IF-11-REG05</strong>
  </p>
  <br />
  <h3>Dosen Pengampu :</h3>
  <p>
    <strong>Dedi Agung Prabowo, S.Kom., M.Kom</strong>
  </p>
  <br />
  <br />
  <h4>Asisten Praktikum :</h4>
  <strong>Apri Pandu Wicaksono </strong>
  <br>
  <strong>Hamka Zaenul Ardi</strong>
  <br />
  <h3>LABORATORIUM HIGH PERFORMANCE <br>FAKULTAS INFORMATIKA <br>UNIVERSITAS TELKOM PURWOKERTO <br>2026 </h3>
</div>

<hr>

## Dasar Teori

Flutter merupakan framework open-source yang dikembangkan oleh Google untuk membangun aplikasi lintas platform menggunakan satu basis kode sehingga dapat dijalankan pada sistem operasi Android, iOS, web, maupun desktop. Flutter menggunakan bahasa pemrograman Dart dan menerapkan konsep widget sebagai komponen utama penyusun antarmuka aplikasi. Setiap elemen tampilan seperti teks, ikon, gambar, maupun layout direpresentasikan dalam bentuk widget sehingga proses pengembangan antarmuka menjadi lebih fleksibel dan terstruktur.

Dalam pengembangan aplikasi, data tidak selalu disimpan secara lokal, tetapi dapat diperoleh dari server melalui API (Application Programming Interface). API berfungsi sebagai penghubung antara aplikasi dengan sumber data eksternal sehingga aplikasi dapat melakukan pertukaran informasi. Pada Flutter, proses pengambilan data dari API umumnya menggunakan package `http`, sedangkan data berformat JSON diubah menjadi objek Dart menggunakan fungsi `jsonDecode()` agar dapat diproses dan ditampilkan pada aplikasi.

Flutter mendukung pemrograman asinkron untuk menangani proses yang memerlukan waktu, seperti pengambilan data dari internet. Konsep asinkron pada Flutter dapat diterapkan menggunakan `Future` untuk merepresentasikan proses yang berjalan di latar belakang dan `FutureBuilder` untuk menampilkan hasil proses tersebut pada antarmuka aplikasi. Selain itu, `StatefulWidget` digunakan ketika tampilan perlu diperbarui sesuai perubahan data, sehingga informasi yang diperoleh dari API dapat ditampilkan secara dinamis pada halaman aplikasi.

##  Tugas Modul 5-6 Flutter
### Source code

```
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
      title: 'Domain List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF2F4F8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5AFE)),
        useMaterial3: true,
      ),
      home: const DomainsPage(),
    );
  }
}

class Domain {
  final int id;
  final String name;
  const Domain({required this.id, required this.name});

  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(id: json['id'] as int, name: json['name'] as String);
  }
}

class DomainService {
  Future<List<Domain>> fetchDomains() async {
    final res =
        await http.get(Uri.parse('https://api.qemail.web.id/v1/email/domains'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Domain.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat data');
  }
}

class DomainsPage extends StatefulWidget {
  const DomainsPage({super.key});
  @override
  State<DomainsPage> createState() => _DomainsPageState();
}

class _DomainsPageState extends State<DomainsPage> {
  final _service = DomainService();
  late Future<List<Domain>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchDomains();
  }

  void _reload() => setState(() => _future = _service.fetchDomains());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF3D5AFE),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'QEmail Domains',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    GestureDetector(
                      onTap: _reload,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Daftar domain yang tersedia',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SafeArea(
              top: false,
              child: FutureBuilder<List<Domain>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF3D5AFE)),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 52, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('Gagal memuat data',
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          TextButton(
                              onPressed: _reload,
                              child: const Text('Coba lagi')),
                        ],
                      ),
                    );
                  }

                  final domains = snapshot.data ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '${domains.length} domain tersedia',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: domains.length,
                          itemBuilder: (context, i) {
                            final d = domains[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF1FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.language_rounded,
                                      color: Color(0xFF3D5AFE),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      d.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F4F8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '#${d.id}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


```
### Screenshot Output
<img src="Screenshot 2026-05-25 221007.jpg" alt="Keterangan Foto" width="100%">

### Penjelasan Code

Kode program di atas digunakan untuk membuat aplikasi Flutter yang menampilkan daftar domain email dari API eksternal. Program diawali dengan fungsi `main()` yang menjalankan widget `MyApp` menggunakan `runApp()`. Class `MyApp` merupakan turunan dari `StatelessWidget` yang berfungsi sebagai struktur utama aplikasi dengan `MaterialApp` sebagai pengatur tema, warna, serta halaman awal aplikasi. Data domain direpresentasikan melalui class `Domain` yang memiliki atribut `id` dan `name`, sedangkan class `DomainService` digunakan untuk mengambil data dari API menggunakan package `http`. Data yang diterima dalam format JSON kemudian diubah menjadi objek Dart menggunakan `jsonDecode()` dan `factory constructor` agar dapat diproses pada aplikasi.

Pada tampilan utama digunakan `StatefulWidget` yaitu `DomainsPage` karena data yang ditampilkan dapat berubah setelah proses pengambilan data dari API atau saat tombol refresh ditekan. Widget `FutureBuilder` digunakan untuk menangani proses asynchronous sehingga aplikasi dapat menampilkan indikator loading, data berhasil dimuat, maupun pesan error ketika pengambilan data gagal. Selanjutnya, daftar domain ditampilkan menggunakan `ListView.builder` dalam bentuk card dengan informasi nama domain dan ID domain. Selain itu, widget seperti `Container`, `Row`, `Column`, `Text`, `Icon`, dan `SafeArea` digunakan untuk mengatur tata letak antarmuka agar tampilan aplikasi lebih rapi dan responsif.