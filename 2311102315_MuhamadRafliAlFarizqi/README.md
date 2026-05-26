<div align="center">
    <br />
    <h1>LAPORAN PRAKTIKUM <br> APLIKASI BERBASIS PLATFORM </h1>
    <br />
    <h3>MODUL 5 & 6 <br> ANTARMUKA PENGGUNA & INTERAKSI PENGGUNA </h3>
    <br />
    <img width="512" height="512" alt="telyu" src="https://github.com/user-attachments/assets/724a3291-bcf9-448d-a395-3886a8659d79" />
    <br />
    <br />
    <br />
    <h3>Disusun Oleh :</h3>
    <p>
        <strong>Muhamad Rafli Al Farizqi</strong>
        <br>
        <strong>2311102315</strong>
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

Dalam pengembangan aplikasi Flutter, penataan tata letak (_layout_) menggunakan widget `Row` dan `Column` merupakan hal yang mendasar. `Row` digunakan untuk menyusun widget secara horizontal, sementara `Column` menyusunnya secara vertikal. Penggunaan `Expanded` di dalam `Row` atau `Column` berfungsi untuk mendistribusikan sisa ruang kosong secara dinamis, sehingga tampilan tidak mengalami _overflow_.

Selain itu, Flutter mendukung integrasi dengan REST API menggunakan _package_ `http`. Data dari API di-_fetch_ secara asinkron menggunakan `Future` dan ditampilkan dengan `FutureBuilder` yang mengelola tiga kondisi utama: _loading_, _error_, dan _success_. Interaksi pengguna ditangani melalui widget seperti `TextField`, `InkWell`, `IconButton`, serta `ModalBottomSheet` untuk pengalaman pengguna yang lebih interaktif.

## Tugas Modul 5 & 6 - Domain Finder

### 1. Source Code

```dart
// 2311102315 - Muhamad Rafli Al Farizqi
class DomainModel {
  final int id;
  final String name;

  const DomainModel({
    required this.id,
    required this.name,
  });

  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  String get extension => name.contains('.') ? name.split('.').last : name;
}
```

**Kode Lengkap:** [lib/models/domain_model.dart](lib/models/domain_model.dart)

```dart
// 2311102315 - Muhamad Rafli Al Farizqi
class ApiService {
  static const String _baseUrl = 'https://api.qemail.web.id/v1/email/domains';

  Future<List<DomainModel>> fetchDomains({
    SortMode sortMode = SortMode.byId,
  }) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final domains = data.map((json) => DomainModel.fromJson(json)).toList();
        // sorting berdasarkan mode yang dipilih
        ...
        return domains;
      } else {
        throw Exception('Gagal memuat data: Status ${response.statusCode}');
      }
    } catch (e) {
      ...
    }
  }
}
```

**Kode Lengkap:** [lib/services/api_service.dart](lib/services/api_service.dart)

```dart
// 2311102315 - Muhamad Rafli Al Farizqi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<DomainModel>> _futureDomains;

  SortMode _sortMode = SortMode.byId;
  bool _isGridView = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDomains();
  }

  @override
  Widget build(BuildContext context) {
    ...
  }
}
```

**Kode Lengkap:** [lib/screens/home_screen.dart](lib/screens/home_screen.dart)

```dart
// 2311102315 - Muhamad Rafli Al Farizqi
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Domain Finder',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488), // Teal
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
```

**Kode Lengkap:** [lib/main.dart](lib/main.dart)

**Widget Kartu Domain (Row & Column Implementation):**

```dart
// 2311102315 - Muhamad Rafli Al Farizqi
class DomainCard extends StatelessWidget {
  final DomainModel domain;

  const DomainCard({super.key, required this.domain});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context),
      onLongPress: () => _copyDomain(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row( // IMPLEMENTASI ROW
          children: [
            _buildIdBadge(colorScheme),    // Gradient badge ID
            const SizedBox(width: 14),
            Expanded(                       // IMPLEMENTASI EXPANDED
              child: Column(                // IMPLEMENTASI COLUMN
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(domain.name, ...),
                  Row(children: [           // Nested Row untuk chip info
                    Text('ID: ${domain.id}'),
                    Container(child: Text('.${domain.extension}')),
                  ]),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
```

**Kode Lengkap:** [lib/widgets/domain_card.dart](lib/widgets/domain_card.dart)

**Kode Lengkap Grid Tile:** [lib/widgets/domain_grid_tile.dart](lib/widgets/domain_grid_tile.dart)

### 2. Penjelasan

Aplikasi **Domain Finder** mengimplementasikan pengambilan data dari REST API QEmail (`/v1/email/domains`) menggunakan _package_ `http`. Respons JSON di-_parsing_ dan dipetakan ke objek `DomainModel` yang memiliki properti `id`, `name`, dan getter `extension`.

Pada sisi antarmuka, halaman utama (`HomeScreen`) menggunakan `FutureBuilder` untuk menangani status asinkron dari pemanggilan API, menampilkan indikator _loading_, pesan _error_, atau data domain. Fitur yang diimplementasikan meliputi:

- **Search Bar** — `TextField` untuk memfilter domain secara real-time berdasarkan nama.
- **Toggle Sort** — Mengurutkan data berdasarkan ID atau Nama domain.
- **Toggle View** — Beralih antara tampilan `ListView` dan `GridView`.
- **Bottom Sheet** — Menampilkan detail domain saat kartu di-tap, dengan tombol salin ke clipboard.
- **Long Press** — Menyalin nama domain langsung ke clipboard.

Setiap item menggunakan `Row` untuk menyusun badge ID, informasi domain, dan ikon secara horizontal. Widget `Expanded` digunakan pada teks nama domain agar mengisi sisa ruang tanpa menyebabkan _overflow_.

### 3. Output

![Domain Finder App](assets/screenshot.png)

## Kesimpulan

Praktikum ini menunjukkan bahwa `Row`, `Column`, dan `Expanded` merupakan fondasi penting dalam menyusun tata letak Flutter yang responsif. Integrasi dengan REST API menggunakan _package_ `http` dan `FutureBuilder` memungkinkan data dari server ditampilkan secara dinamis. Penambahan fitur pencarian, pengurutan, dan toggle tampilan memperkaya interaksi pengguna dalam aplikasi.
