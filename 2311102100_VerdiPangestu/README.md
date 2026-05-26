<div align="center">
  <br />
  <h1>LAPORAN PRAKTIKUM <br> APLIKASI BERBASIS PLATFORM </h1>
  <br />
  <h3>MODUL 5 & 6 <br> Flutter </h3>
  <br />
  <img width="512" height="512" alt="telyu" src="https://github.com/user-attachments/assets/724a3291-bcf9-448d-a395-3886a8659d79" />
  <br />
  <br />
  <br />
  <h3>Disusun Oleh :</h3>
  <p>
    <strong>Verdi Pangestu</strong>
    <br>
    <strong>2311102100</strong>
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


# Dasar Teori

<p align="justify">
Flutter merupakan framework open-source yang dikembangkan oleh Google Flutter untuk membangun aplikasi mobile menggunakan bahasa pemrograman Dart. Flutter menyediakan berbagai widget seperti Column dan Row untuk menyusun tampilan antarmuka aplikasi secara fleksibel. Dalam pengembangan aplikasi modern, API (Application Programming Interface) digunakan sebagai media pertukaran data antara aplikasi dan server melalui internet. Pada praktikum ini proses pengambilan data dilakukan menggunakan metode HTTP GET dengan bantuan library http package Flutter untuk melakukan fetch API dari QEmail API Documentation menggunakan endpoint Domains Endpoint. Data yang diterima dari server berupa format JSON berisi id dan name kemudian diubah menjadi object model pada Flutter agar dapat ditampilkan pada aplikasi secara dinamis dan real-time.
</p>

## Source Code 
```dart
<!-- 2311102100-Verdi Pangestu -->
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
```


# Screenshots Output
![alt text](<Cuplikan layar 2026-05-26 232524.png>)
# Penjelasan
<p align="justify">
Program Flutter tersebut digunakan untuk menampilkan daftar domain email dari API QEmail API menggunakan library http package Flutter. Data diambil dengan metode HTTP GET kemudian diubah dari format JSON menjadi object DomainModel yang berisi id dan name. Setelah data berhasil diambil, aplikasi menampilkan daftar domain menggunakan ListView.builder dengan desain card modern, sedangkan jika proses masih berjalan akan muncul CircularProgressIndicator dan jika terjadi kesalahan akan menampilkan pesan error pada layar.
</p>