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
    <strong>Ahmad Tegar Kahfi A.</strong>
    <br>
    <strong>2311102083</strong>
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

# 1. Dasar Teori

## Flutter

Flutter merupakan framework yang dikembangkan oleh Google untuk membuat aplikasi mobile, web, dan desktop menggunakan satu source code yang sama. Flutter memudahkan developer dalam membangun aplikasi lintas platform tanpa harus membuat aplikasi secara terpisah untuk Android dan iOS.

Flutter menggunakan konsep widget sebagai komponen utama dalam pembuatan tampilan aplikasi. Dengan widget, developer dapat membuat antarmuka aplikasi yang interaktif dan responsif.

Beberapa keunggulan Flutter antara lain:

- Mendukung cross-platform
- Memiliki fitur hot reload
- Tampilan UI lebih fleksibel
- Performa aplikasi lebih cepat

Pada praktikum ini, Flutter digunakan untuk membuat aplikasi Android yang dapat mengambil data dari REST API dan menampilkan data tersebut pada layar aplikasi.

## Dart

Dart merupakan bahasa pemrograman yang digunakan dalam framework Flutter. Bahasa Dart dikembangkan oleh Google dan dirancang untuk mendukung pengembangan aplikasi modern dengan performa yang baik.

Dart memiliki sintaks yang mudah dipahami karena mirip dengan bahasa pemrograman lain seperti Java dan JavaScript. Selain itu, Dart mendukung konsep Object Oriented Programming (OOP) sehingga kode program menjadi lebih terstruktur dan mudah dikembangkan.

Dart juga mendukung asynchronous programming menggunakan `async` dan `await`. Fitur ini sangat berguna ketika aplikasi melakukan proses pengambilan data dari internet agar aplikasi tetap berjalan dengan lancar tanpa mengalami lag.

## RESTful API

RESTful API merupakan layanan berbasis web yang digunakan untuk komunikasi antara client dan server melalui protokol HTTP. REST API memungkinkan aplikasi untuk mengambil maupun mengirim data melalui endpoint tertentu.

Pada REST API terdapat beberapa method HTTP yang umum digunakan, yaitu:

- GET untuk mengambil data
- POST untuk menambahkan data
- PUT untuk memperbarui data
- DELETE untuk menghapus data

Pada praktikum ini, method yang digunakan adalah GET karena aplikasi hanya mengambil data domain email dari server API.

Endpoint API yang digunakan adalah:

`https://api.qemail.web.id/v1/email/domains`

Data yang diperoleh dari endpoint tersebut kemudian diproses dan ditampilkan pada aplikasi Flutter.

## JSON (JavaScript Object Notation)

JSON atau JavaScript Object Notation merupakan format pertukaran data yang sering digunakan pada REST API. JSON digunakan karena memiliki struktur yang sederhana, ringan, dan mudah dipahami oleh manusia maupun komputer.

Struktur JSON terdiri dari object dan array yang berisi pasangan key dan value. Contoh data JSON adalah sebagai berikut:

```html
[
  {
    "id": 1,
    "name": "gmail.com"
  }
]
```
Pada contoh tersebut:

- `id` dan `name` disebut key
- `1` dan `gmail.com` disebut value

Pada praktikum ini, data JSON dari API diproses menggunakan fungsi jsonDecode() agar dapat digunakan pada aplikasi Flutter.

## HTTP Request pada Flutter

HTTP Request merupakan proses komunikasi antara aplikasi dengan server melalui jaringan internet menggunakan protokol HTTP. Dalam Flutter, HTTP Request digunakan untuk mengambil data dari REST API.

Flutter menyediakan package `http` untuk mempermudah proses komunikasi dengan server. Salah satu method yang digunakan adalah `http.get()` untuk mengambil data dari API.

Contoh penggunaan HTTP Request pada Flutter adalah sebagai berikut:

```html
final response = await http.get(
  Uri.parse(url),
);
```

Hasil response dari server kemudian diproses menjadi data yang dapat ditampilkan pada aplikasi Android.

## Future dan Asynchronous Programming

Asynchronous programming merupakan teknik pemrograman yang memungkinkan proses tertentu berjalan di latar belakang tanpa menghentikan proses utama aplikasi. Teknik ini penting digunakan ketika aplikasi mengambil data dari internet karena proses tersebut membutuhkan waktu.

Dalam Flutter dan Dart, asynchronous programming menggunakan keyword `async` dan `await`. Keyword `async` digunakan untuk menandai fungsi asynchronous, sedangkan `await` digunakan untuk menunggu proses selesai.

Selain itu, Flutter menggunakan tipe data `Future` untuk menangani proses asynchronous. Future digunakan untuk menyimpan hasil proses yang belum selesai dijalankan.

Contoh penggunaan Future adalah sebagai berikut:

```html
Future<List<Domain>> fetchDomains() async {
  // proses API
}
```

Dengan asynchronous programming, aplikasi tetap dapat berjalan dengan lancar ketika mengambil data dari REST API.

#  2. Pembahasan Tugas

## Menambahkan Dependency HTTP

Pada tahap ini, penambahan dependency dilakukan pada file pubspec.yaml pada bagian dependencies seperti pada Gambar 2.1,

![Bukti](assets/Screenshot%202026-05-28%20193908.png)

Gambar 2.1 Penambahan Dependency HTTP

## Membuat Model Data Domain

Model data yang dibuat pada praktikum ini adalah class `Domain` yang digunakan untuk menyimpan data domain email berupa `id` dan `name`.

Berikut merupakan kode model data `Domain`:

```html
class Domain {
  final int id;
  final String name;

  Domain({
    required this.id,
    required this.name,
  });

  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(
      id: json['id'],
      name: json['name'],
    );
  }
}
```

Pada kode tersebut:

- `id` digunakan untuk menyimpan identitas domain
- `name` digunakan untuk menyimpan nama domain email
- `final` menunjukkan bahwa nilai data tidak dapat diubah setelah objek dibuat
- Constructor `Domain()` digunakan untuk menginisialisasi data ketika objek dibuat

## Mengambil Data dari REST API

Pada tahap ini, aplikasi Flutter mengambil data domain email dari REST API menggunakan method GET. Data diambil dari endpoint berikut:

`https://api.qemail.web.id/v1/email/domains`

Untuk mengambil data dari API, digunakan package `http` dengan fungsi `http.get()`.

Berikut merupakan kode untuk mengambil data dari REST API:

```html
Future<List<Domain>> fetchDomains() async {
    final response = await http.get(
      Uri.parse('https://api.qemail.web.id/v1/email/domains'),
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);

      return jsonData.map((item) {
        return Domain.fromJson(item);
      }).toList();
    } else {
      throw Exception('Gagal mengambil data API');
    }
  }
```

Penjelasan kode:

- `http.get()` digunakan untuk mengirim request ke server API
- `Uri.parse()` digunakan untuk membaca URL endpoint
- `response.body` berisi data JSON dari server
- `jsonDecode()` digunakan untuk mengubah JSON menjadi data Dart
- `Domain.fromJson()` digunakan untuk mengubah JSON menjadi object `Domain`

Bukti Penggunaan seperti pada gambar 2.2,

![Bukti](assets/Screenshot%202026-05-28%20195747.png)

Gambar 2.2 Pengambilan Data dari REST API

## Menampilkan Data ke Dalam Aplikasi

Setelah data berhasil diperoleh dari REST API, langkah berikutnya adalah menampilkan data tersebut ke dalam tampilan aplikasi Android menggunakan widget Flutter.

Pada praktikum ini, data ditampilkan menggunakan `FutureBuilder` dan `ListView.builder`.

`FutureBuilder` digunakan untuk menunggu proses pengambilan data dari API karena proses tersebut berjalan secara asynchronous. Sedangkan `ListView.builder` digunakan untuk menampilkan data dalam bentuk daftar secara otomatis sesuai jumlah data yang diterima dari API.

Berikut merupakan kode untuk menampilkan data ke aplikasi:

```html
body: FutureBuilder<List<Domain>>(
          future: fetchDomains(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Terjadi error: ${snapshot.error}'),
              );
            }

            final domains = snapshot.data ?? [];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: domains.length,
                itemBuilder: (context, index) {
                  final domain = domains[index];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(domain.id.toString()),
                      ),
                      title: Text(domain.name),
                      subtitle: Text('ID: ${domain.id}'),
                    ),
                  );
                },
              ),
            );
          },
        ),
```

Penjelasan kode:

- `FutureBuilder` digunakan untuk memproses data asynchronous dari API
- `CircularProgressIndicator()` digunakan untuk menampilkan loading saat data sedang diambil
- `ListView.builder` digunakan untuk membuat daftar data secara otomatis
- `Card` digunakan untuk membuat tampilan data lebih rapi
- `ListTile` digunakan untuk menampilkan data `id` dan `name`

Alur penampilan data pada aplikasi dapat digambarkan sebagai berikut:

`API → Data JSON → FutureBuilder → ListView → Tampilan Android`

Setelah aplikasi berhasil mengambil data dari REST API, data domain email berupa `id` dan `name` akan ditampilkan dalam bentuk daftar pada layar aplikasi Android.

Bukti Penggunaannya seperti pada Gambar 2.3,

![Bukti](assets/Screenshot%202026-05-28%20202450.png)

Gambar 2.3 Menampilkan Data ke Dalam Aplikasi

## Hasil Running Aplikasi

Setelah seluruh proses pembuatan aplikasi selesai dilakukan, aplikasi berhasil dijalankan pada emulator Android menggunakan Android Studio. Aplikasi dapat mengambil data dari REST API dan menampilkan data domain email ke dalam tampilan Android secara berhasil.

Berikut merupakan hasil running aplikasi Flutter pada Gambar 2.4,

![Bukti](assets/Screenshot%202026-05-28%20203300.png)

Gambar 2.4 Hasil Running Aplikasi

Pada hasil running tersebut, aplikasi menampilkan daftar domain email yang diperoleh dari endpoint REST API berikut:

`https://api.qemail.web.id/v1/email/domains`

Data yang berhasil ditampilkan berupa:

- `id`
- `name`

Setiap data domain ditampilkan menggunakan widget `Card` dan `ListTile` sehingga tampilan aplikasi menjadi lebih rapi dan mudah dibaca oleh pengguna.

Selain itu, aplikasi juga berhasil melakukan proses:

- HTTP Request menggunakan package `http`
- Parsing data JSON menggunakan `jsonDecode()`
- Menampilkan data asynchronous menggunakan `FutureBuilder`

Dengan demikian, aplikasi Flutter yang dibuat pada praktikum ini telah berhasil menjalankan fungsi utama yaitu mengambil data dari REST API dan menampilkan data tersebut ke dalam aplikasi Android.