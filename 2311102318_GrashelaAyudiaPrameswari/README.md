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
        <strong>Grashela Ayudia Prameswari</strong>
        <br>
        <strong>2311102318</strong>
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

Pada pengembangan antarmuka pengguna menggunakan Flutter, penataan tata letak yang baik sangat penting untuk memberikan pengalaman pengguna yang optimal. Widget `Row` digunakan untuk menyusun elemen secara horizontal, sedangkan `Column` untuk susunan vertikal. Widget `Expanded` berfungsi mendistribusikan sisa ruang kosong secara dinamis agar tampilan tidak mengalami _overflow_.

Flutter juga mendukung integrasi dengan REST API melalui _package_ `http`. Proses _fetch_ data dilakukan secara asinkron menggunakan `Future` dan `async/await`, kemudian ditampilkan pada antarmuka menggunakan `FutureBuilder`. Interaksi pengguna dapat ditingkatkan melalui berbagai widget interaktif seperti `FilterChip`, `IconButton`, `TextField`, dan `ModalBottomSheet`.

## Tugas Modul 5 & 6 - Domain Explorer

### 1. Source Code

```dart
// 2311102318 - Grashela Ayudia Prameswari
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
// 2311102318 - Grashela Ayudia Prameswari
class ApiService {
  static const String _baseUrl = 'https://api.qemail.web.id/v1/email/domains';

  Future<List<DomainModel>> fetchDomains() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DomainModel.fromJson(json)).toList();
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
// 2311102318 - Grashela Ayudia Prameswari
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<DomainModel>> _futureDomains;

  final Set<int> _favoriteIds = {};
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

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
// 2311102318 - Grashela Ayudia Prameswari
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Domain Explorer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63), // Pink
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
// 2311102318 - Grashela Ayudia Prameswari
class DomainCard extends StatelessWidget {
  final DomainModel domain;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context),
      onLongPress: () => _copyDomain(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row( // IMPLEMENTASI ROW
          children: [
            _buildAvatar(colorScheme),      // Gradient circle avatar
            const SizedBox(width: 14),
            Expanded(                        // IMPLEMENTASI EXPANDED
              child: Column(                 // IMPLEMENTASI COLUMN
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(domain.name, ...),
                  Row(children: [            // Nested Row untuk chip
                    _buildChip('ID: ${domain.id}', ...),
                    _buildChip('.${domain.extension}', ...),
                  ]),
                ],
              ),
            ),
            IconButton(                      // Tombol favorit
              icon: Icon(isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded),
              onPressed: onFavoriteToggle,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Kode Lengkap:** [lib/widgets/domain_card.dart](lib/widgets/domain_card.dart)

### 2. Penjelasan

Aplikasi **Domain Explorer** mengimplementasikan pengambilan data dari REST API QEmail (`/v1/email/domains`) menggunakan _package_ `http`. Respons JSON di-_parsing_ dan dipetakan ke dalam objek `DomainModel` yang memiliki properti `id`, `name`, serta getter `extension`.

Pada halaman utama (`HomeScreen`), `FutureBuilder` digunakan untuk menangani status asinkron pemanggilan API. Aplikasi menampilkan indikator _loading_, pesan _error_ dengan tombol retry, atau daftar domain yang berhasil dimuat. Fitur utama yang diimplementasikan meliputi:

- **Search Bar** — `TextField` untuk memfilter domain berdasarkan nama secara real-time.
- **Favorit** — Setiap domain memiliki tombol _love_ yang bisa di-tap untuk menandainya sebagai favorit.
- **Filter Chip** — `FilterChip` untuk beralih antara tampilan semua domain dan hanya domain favorit, disertai counter jumlah domain.
- **Bottom Sheet** — Menampilkan detail domain saat kartu di-tap, dengan tombol salin ke clipboard.
- **Long Press** — Menyalin nama domain langsung ke clipboard.

Setiap kartu domain menggunakan `Row` untuk menyusun avatar, informasi domain, dan tombol favorit secara horizontal. Widget `Expanded` membungkus `Column` informasi domain agar teks mengisi sisa ruang tanpa menyebabkan _overflow_.

### 3. Output

![Domain Explorer App](assets/screenshot.png)

## Kesimpulan

Praktikum ini menunjukkan bahwa widget `Row`, `Column`, dan `Expanded` merupakan komponen penting dalam menyusun tata letak Flutter yang responsif dan tidak mengalami _overflow_. Integrasi dengan REST API menggunakan _package_ `http` dan `FutureBuilder` memungkinkan data dari server ditampilkan secara dinamis pada antarmuka. Penambahan fitur pencarian dan favorit memperkaya interaksi pengguna dalam aplikasi.
