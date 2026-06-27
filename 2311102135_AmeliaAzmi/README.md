<div align="center">
    <br />
    <h1>LAPORAN PRAKTIKUM <br> APLIKASI BERBASIS PLATFORM </h1>
    <br />
    <h3>MODUL 7 <br> Integrasi Flutter Firebase/Supabase </h3>
    <br />
    <img width="512" height="512" alt="telyu" src="https://github.com/user-attachments/assets/724a3291-bcf9-448d-a395-3886a8659d79" />
    <br />
    <br />
    <br />
    <h3>Disusun Oleh :</h3>
    <p>
        <strong>Amelia Azmi</strong> 
        <br>
        <strong>2311102135</strong>
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
## 📚 Dasar Teori

### 1. Fondasi Widget di Flutter

Flutter merupakan toolkit antarmuka buatan Google yang memungkinkan pengembangan aplikasi untuk berbagai platform dari satu basis kode. Bahasa yang dipakai adalah Dart, dan seluruh elemen visual direpresentasikan sebagai *widget*. Berbeda dengan framework lain yang memanfaatkan komponen native OS, Flutter menggambar sendiri setiap piksel menggunakan rendering engine internal (Skia/Impeller), yang berdampak pada konsistensi tampilan di semua perangkat.

Widget di Flutter membentuk struktur pohon (widget tree) yang bersifat *immutable* — artinya widget tidak dimodifikasi, melainkan diganti saat ada perubahan data. Terdapat dua kategori widget utama:

- **`StatelessWidget`** → tampilannya konstan, hanya bergantung pada data yang diteruskan lewat konstruktor. Cocok untuk elemen statis seperti label, ikon, atau header.
- **`StatefulWidget`** → memiliki objek `State` terpisah yang mampu menyimpan data yang bisa berubah. Saat `setState()` dipanggil, Flutter melakukan kalkulasi ulang (rebuild) pada bagian widget tree yang terpengaruh.

---

### 2. Menyusun Tata Letak: Row, Column, dan Expanded

Pengaturan posisi elemen dalam Flutter tidak dilakukan dengan CSS maupun XML layout, melainkan menggunakan widget tata letak deklaratif. Dua widget paling mendasar:

- **`Column`** — menumpuk children secara vertikal (sumbu Y).
- **`Row`** — menyusun children secara horizontal (sumbu X).

Keduanya memiliki dua properti penyelarasan:
- `mainAxisAlignment` → distribusi di sepanjang sumbu utama (e.g., `center`, `spaceBetween`).
- `crossAxisAlignment` → posisi di sumbu tegak lurus (e.g., `stretch`, `end`).

Ketika total lebar/tinggi children melampaui ruang yang tersedia, Flutter memunculkan *overflow indicator* bergaris hitam-kuning sebagai peringatan. Solusinya adalah membungkus salah satu child dengan **`Expanded`**, yang merupakan bentuk ringkas dari `Flexible(fit: FlexFit.tight)`. Widget ini memerintahkan child-nya untuk mengambil seluruh sisa ruang kosong yang belum diklaim child lain, secara otomatis mencegah overflow.

---

### 3. Menampilkan Daftar: ListView.builder

Untuk koleksi data berukuran besar atau yang berasal dari sumber eksternal, `ListView` menjadi solusi utama. Constructor `ListView.builder` secara khusus menerapkan teknik *virtualisasi* — setiap item widget baru dibangun tepat saat akan memasuki area tampilan layar (viewport), dan dihancurkan kembali saat keluar. Pendekatan ini jauh lebih hemat memori dibanding membangun seluruh daftar sekaligus.

Parameter esensialnya:
- `itemCount` → total jumlah entri dalam daftar.
- `itemBuilder` → fungsi bertipe `(BuildContext, int) → Widget` yang dipanggil per item.

---

### 4. Elemen Interaktif: Button dan GestureDetector

Flutter menyediakan serangkaian widget tombol sesuai spesifikasi Material Design:

- **`ElevatedButton`** → tombol dengan latar berwarna dan bayangan, dipakai untuk tindakan utama.
- **`TextButton`** → tombol minimalis berbasis teks, untuk tindakan sekunder.
- **`IconButton`** → tombol ikon tanpa label, umum dipakai di AppBar atau toolbar.

Seluruh tombol menerima parameter `onPressed` berupa fungsi callback. Untuk penanganan gestur yang lebih luas (swipe, long press, double tap), `GestureDetector` berperan sebagai lapisan tak kasat mata yang mengubah widget mana pun menjadi responsif terhadap sentuhan.

---

### 5. Komunikasi Jaringan: Package http & Provider Pattern

Karena Dart murni tidak menyertakan klien HTTP bawaan, diperlukan package eksternal `http` dari pub.dev. Package ini mengekspos fungsi-fungsi level tinggi seperti `http.get()`, `http.post()`, dsb., yang masing-masing menghasilkan `Future<Response>`. Respons memuat `statusCode`, `headers`, dan `body` yang dapat diproses lebih lanjut.

Untuk pengelolaan state, pola **Provider** memanfaatkan mekanisme `InheritedWidget` secara tidak langsung. Kelas yang mewarisi `ChangeNotifier` bertugas menyimpan data dan logika bisnis. Setiap kali data berubah, `notifyListeners()` dipanggil, dan semua widget yang "berlangganan" melalui `Consumer` atau `context.watch()` akan dirender ulang secara otomatis.

---

## 💻 Tugas Modul 5 & 6 — Aplikasi QEmail Domains

### 1. Source Code

#### a. `lib/models/domain_entity.dart`

Kelas ini merepresentasikan satu entri domain sebagaimana dikembalikan oleh API. Seluruh atributnya dideklarasikan `final` agar objek bersifat tidak dapat diubah setelah dibuat (*immutable*). Factory constructor `fromJson()` menangani konversi dari struktur `Map` JSON ke objek Dart dengan type casting eksplisit.

```dart
class DomainEntity {
  final int id;
  final String name;

  const DomainEntity({
    required this.id,
    required this.name,
  });

  factory DomainEntity.fromJson(Map<String, dynamic> json) {
    return DomainEntity(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => 'DomainEntity(id: $id, name: $name)';
}
```

---

#### b. `lib/providers/domain_provider.dart`

`DomainProvider` mewarisi `ChangeNotifier` dan bertindak sebagai *single source of truth* untuk seluruh state yang berhubungan dengan data domain. Tiga variabel privat dikelola: status sedang-memuat (`_isLoading`), daftar hasil (`_domains`), dan pesan kegagalan (`_errorMessage`). Blok `try-catch-finally` menjamin `_isLoading` selalu kembali ke `false` meski terjadi error, dan `notifyListeners()` dipanggil dua kali — di awal untuk memicu tampilan loading, di akhir untuk memperbarui UI dengan hasil.

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/domain_entity.dart';

class DomainProvider extends ChangeNotifier {
  static const String _baseUrl =
      'https://api.qemail.web.id/v1/email/domains';

  List<DomainEntity> _domains = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DomainEntity> get domains => _domains;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDomains() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final domains =
            jsonResponse.map((data) => DomainEntity.fromJson(data)).toList();
        domains.sort((a, b) => a.id.compareTo(b.id));
        _domains = domains;
      } else {
        _errorMessage =
            'Gagal memuat data. Status: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

#### c. `lib/pages/domain_page.dart`

`DomainPage` adalah `StatefulWidget` yang memanfaatkan `initState()` untuk memicu pengambilan data pertama kali. Penggunaan `addPostFrameCallback()` penting agar `fetchDomains()` dipanggil setelah frame pertama selesai dirender — memanggil provider di dalam `initState()` secara langsung dapat menyebabkan error *setState during build*. `Consumer<DomainProvider>` mendengarkan perubahan state dan merender tampilan yang sesuai: indikator putar saat loading, pesan error dengan tombol coba ulang saat gagal, atau daftar domain saat berhasil.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/domain_provider.dart';

class DomainPage extends StatefulWidget {
  const DomainPage({super.key});

  @override
  State<DomainPage> createState() => _DomainPageState();
}

class _DomainPageState extends State<DomainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DomainProvider>().fetchDomains();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QEmail Domains'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DomainProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchDomains(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.domains.isEmpty) {
            return const Center(child: Text('Tidak ada data domain.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.domains.length,
            itemBuilder: (context, index) {
              final domain = provider.domains[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${domain.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          domain.name,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.email_outlined, color: Colors.blue),
                    ],
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
```

---

#### d. `lib/main.dart`

Titik masuk aplikasi. `MultiProvider` ditempatkan paling atas hierarki widget agar `DomainProvider` dapat diakses dari seluruh bagian pohon widget tanpa perlu diteruskan secara manual antar layer. `MaterialApp` dikonfigurasi dengan Material Design 3 dan tema warna berbasis biru.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/domain_provider.dart';
import 'pages/domain_page.dart';

void main() {
  runApp(const QEmailApp());
}

class QEmailApp extends StatelessWidget {
  const QEmailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DomainProvider()),
      ],
      child: MaterialApp(
        title: 'QEmail Domains',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const DomainPage(),
      ),
    );
  }
}
```

---

### 2. Penjelasan

Aplikasi QEmail Domains dibangun di atas tiga lapisan yang saling terpisah sesuai prinsip *separation of concerns*:

**Lapisan Model** (`DomainEntity`) hanya bertanggung jawab mendefinisikan bentuk data dan cara mengonversinya dari format JSON. Ia tidak tahu dari mana data berasal maupun bagaimana data akan ditampilkan.

**Lapisan Logika** (`DomainProvider`) menangani seluruh komunikasi dengan API menggunakan `http.get()`. Endpoint yang dituju adalah `https://api.qemail.web.id/v1/email/domains`. Setelah respons bertipe `200 OK` diterima, body JSON di-decode, dipetakan ke objek `DomainEntity`, lalu diurutkan berdasarkan ID secara menaik. Tiga kondisi dikelola secara eksplisit: proses berjalan, berhasil, dan gagal. Setiap transisi kondisi memicu `notifyListeners()` agar UI bereaksi.

**Lapisan Tampilan** (`DomainPage`) sepenuhnya reaktif — tidak memiliki logika bisnis sendiri. `Consumer<DomainProvider>` berlangganan ke provider dan merender satu dari tiga kemungkinan tampilan bergantung pada state aktif. Saat data berhasil dimuat, `ListView.builder` mengonstruksi setiap kartu domain secara *lazy*. Di dalam setiap kartu, `Row` menyusun badge ID, nama domain (dalam `Expanded`), dan ikon email secara horizontal. `Expanded` di sini krusial: ia memastikan kolom nama mengambil semua ruang tersisa sehingga teks panjang terpotong elipsis (`...`) alih-alih meluap keluar batas layar.

---

### 3. Output

| Tampilan Daftar Domain | Hasil Running App |
|:---:|:---:|
| ![HasilRun-Android](HasilRun-Android.png) | ![RunHasil](RunHasil.png) |

---

## ✅ Kesimpulan

Praktikum Modul 5 dan 6 berhasil menunjukkan bagaimana Flutter memisahkan tanggung jawab antara penyusunan tampilan, pengelolaan data, dan respons terhadap interaksi pengguna dalam satu kesatuan yang koheren.

Beberapa hal yang dipetik dari praktikum ini:

- `Row` + `Expanded` adalah kombinasi fundamental yang wajib dikuasai — tanpa `Expanded`, konten dinamis seperti nama domain berpotensi menyebabkan overflow yang merusak tampilan.
- `ListView.builder` lebih unggul dari `ListView` biasa untuk data dari API karena hanya membangun widget yang sedang terlihat, bukan seluruh daftar sekaligus.
- Provider Pattern memungkinkan UI menjadi "bodoh secara sengaja" — page tidak perlu mengetahui cara kerja API, cukup bereaksi terhadap state yang disediakan provider.
- Penanganan tiga kondisi (loading / success / error) bukan pilihan, melainkan keharusan dalam aplikasi yang berinteraksi dengan jaringan — jaringan bersifat tidak dapat diandalkan sepenuhnya.
- `addPostFrameCallback()` adalah pola penting yang mencegah error klasik *setState during build* saat memanggil provider dari `initState()`.

---

<div align="center">
<sub>Amelia Azmi · 2311102135 · S1 IF-11-REG05 · Universitas Telkom Purwokerto · 2026</sub>
</div>
