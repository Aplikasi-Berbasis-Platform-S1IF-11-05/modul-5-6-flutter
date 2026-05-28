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
    <strong>Fajar Ario Abdillah</strong>
    <br>
    <strong>2311102114</strong>
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
Flutter merupakan framework open-source yang dikembangkan oleh Google untuk membangun aplikasi berbasis mobile, web, dan desktop menggunakan satu basis kode (single code base). Flutter digunakan untuk mempermudah pengembang dalam membuat aplikasi yang dapat berjalan di berbagai platform seperti Android, iOS, Windows, Linux, dan Web tanpa harus membuat kode program yang berbeda untuk setiap platform.

Flutter menggunakan bahasa pemrograman Dart sebagai bahasa utama dalam pengembangan aplikasinya. Dengan adanya Flutter, proses pengembangan aplikasi menjadi lebih cepat dan efisien karena pengembang hanya perlu menulis satu kali kode program untuk beberapa platform sekaligus.

Selain itu, Flutter memiliki berbagai kelebihan yang mendukung proses pengembangan aplikasi modern. Salah satu kelebihan Flutter adalah kemampuan cross-platform, yaitu aplikasi dapat dijalankan di berbagai sistem operasi menggunakan satu project yang sama. Flutter juga memiliki fitur hot reload yang memungkinkan pengembang melihat perubahan kode secara langsung tanpa perlu menjalankan ulang aplikasi secara penuh, sehingga proses pengembangan menjadi lebih cepat.

Flutter juga menyediakan tampilan antarmuka (User Interface/UI) yang fleksibel karena memiliki banyak widget bawaan yang dapat digunakan untuk membuat desain aplikasi yang menarik dan responsif. Dari sisi performa, Flutter mampu memberikan kinerja aplikasi yang cepat karena menggunakan rendering engine sendiri dan langsung dikompilasi ke native code.

Pada praktikum ini, Flutter digunakan untuk membuat aplikasi sederhana yang mengambil data dari REST API menggunakan package HTTP, kemudian menampilkan data berupa id dan name ke dalam tampilan aplikasi Android.

## Dart

Dart merupakan bahasa pemrograman yang dikembangkan oleh Google dan digunakan sebagai bahasa utama dalam framework Flutter. Dart dirancang untuk membangun aplikasi modern dengan performa yang cepat serta mendukung pengembangan aplikasi berbasis mobile, web, dan desktop.

Dalam pengembangan aplikasi Flutter, Dart digunakan untuk membuat logika program, mengatur tampilan antarmuka aplikasi, serta mengelola proses pengolahan data. Seluruh widget, fungsi, dan struktur aplikasi Flutter ditulis menggunakan bahasa Dart.

Dart memiliki beberapa karakteristik yang mendukung proses pengembangan aplikasi modern. Salah satunya adalah Object Oriented Programming (OOP), yaitu konsep pemrograman yang menggunakan objek dan class sehingga kode program menjadi lebih terstruktur dan mudah dikelola. Selain itu, Dart juga mendukung asynchronous programming melalui penggunaan async dan await yang memungkinkan proses pengambilan data dari internet atau API dapat dilakukan tanpa mengganggu jalannya aplikasi.

Karakteristik lain dari Dart adalah strongly typed, yaitu setiap variabel memiliki tipe data yang jelas sehingga dapat mengurangi kesalahan pada saat program dijalankan. Dengan adanya sistem tipe data tersebut, proses pengembangan aplikasi menjadi lebih aman dan mudah dipelajari.

Pada praktikum ini, bahasa Dart digunakan untuk membuat aplikasi Flutter yang melakukan proses HTTP request ke REST API dan menampilkan data hasil response API ke dalam tampilan aplikasi Android.

## API (Application Programming Interface)

API atau Application Programming Interface merupakan sekumpulan aturan dan mekanisme yang digunakan sebagai penghubung antara aplikasi dengan sistem atau layanan lain. API memungkinkan sebuah aplikasi untuk saling bertukar data dan informasi tanpa harus mengetahui proses internal dari sistem yang digunakan.

Dalam pengembangan aplikasi, API berfungsi sebagai media komunikasi antara client dan server. Client merupakan aplikasi yang digunakan pengguna, sedangkan server adalah sistem yang menyediakan data atau layanan. Dengan menggunakan API, aplikasi dapat mengambil data, mengirim data, maupun memproses data secara otomatis melalui jaringan internet.

Cara kerja API dimulai ketika aplikasi client mengirimkan request atau permintaan ke server melalui endpoint tertentu. Setelah server menerima request tersebut, server akan memproses permintaan dan mengirimkan response berupa data kepada aplikasi client. Data yang dikirim biasanya menggunakan format JSON karena lebih ringan dan mudah diproses oleh aplikasi.

Secara sederhana, alur kerja API dapat digambarkan sebagai berikut:

`Flutter App → Request API → Server → Response JSON`

Pada praktikum ini, API digunakan untuk mengambil data domain email dari endpoint berikut:

`https://api.qemail.web.id/v1/email/domains`

Aplikasi Flutter akan mengirimkan request menggunakan method GET ke endpoint tersebut, kemudian server akan memberikan response berupa data JSON yang berisi informasi id dan name dari domain email. Selanjutnya data tersebut akan diproses dan ditampilkan ke dalam aplikasi Android.

## REST API

REST API atau Representational State Transfer Application Programming Interface merupakan salah satu arsitektur API yang digunakan untuk komunikasi antara client dan server melalui protokol HTTP. REST API banyak digunakan dalam pengembangan aplikasi modern karena memiliki struktur yang sederhana, ringan, dan mudah diimplementasikan.

Pada REST API, setiap data atau resource diakses menggunakan URL atau endpoint tertentu. Client dapat melakukan request kepada server menggunakan method HTTP untuk melakukan berbagai operasi terhadap data yang tersedia pada server.

Beberapa method HTTP yang umum digunakan pada REST API antara lain sebagai berikut:

1. GET (Mengambil atau membaca data dari server)
2. POST (Mengirim atau menambahkan data baru ke server)
3. PUT (Memperbarui data yang sudah ada pada server)
4. DELETE (Menghapus data dari server)

Pada praktikum ini, method HTTP yang digunakan adalah method GET karena aplikasi hanya mengambil data domain email dari server tanpa melakukan perubahan data. Endpoint REST API yang digunakan yaitu:

`https://api.qemail.web.id/v1/email/domains`

Ketika aplikasi Flutter mengirimkan request GET ke endpoint tersebut, server akan memberikan response berupa data JSON yang berisi daftar domain email. Data tersebut kemudian diproses oleh aplikasi dan ditampilkan ke dalam tampilan Android menggunakan widget Flutter.

## JSON (JavaScript Object Notation)

JSON atau JavaScript Object Notation merupakan format pertukaran data yang digunakan untuk menyimpan dan mengirim data antara client dan server. JSON banyak digunakan dalam pengembangan aplikasi modern karena memiliki struktur yang ringan, mudah dibaca manusia, dan mudah diproses oleh berbagai bahasa pemrograman, termasuk Dart pada Flutter.

Dalam proses komunikasi API, data yang dikirim oleh server umumnya menggunakan format JSON. Ketika aplikasi melakukan request ke server melalui REST API, server akan memberikan response berupa data JSON yang kemudian diproses oleh aplikasi untuk ditampilkan kepada pengguna.

Struktur data pada JSON terdiri dari beberapa bagian, yaitu sebagai berikut:

1. Object
2. Array
3. Key-Value

Contoh struktur data JSON adalah sebagai berikut:

```html
[
  {
    "id": 1,
    "name": "gmail.com"
  }
]
```

Pada contoh tersebut:

- `id` dan `name` merupakan key
- `1` dan `gmail.com` merupakan value
- Data berada di dalam array karena menggunakan tanda `[]`
- Data di dalam array berbentuk object karena menggunakan tanda `{}`

Pada praktikum ini, data JSON diperoleh dari endpoint REST API:

`https://api.qemail.web.id/v1/email/domains`

Data JSON tersebut kemudian diproses menggunakan fungsi `jsonDecode()` pada bahasa Dart agar dapat ditampilkan ke dalam aplikasi Flutter.

## HTTP Request pada Flutter

HTTP Request merupakan proses komunikasi antara aplikasi client dengan server melalui protokol HTTP untuk mengambil maupun mengirim data. Dalam pengembangan aplikasi Flutter, HTTP Request digunakan untuk mengakses REST API sehingga aplikasi dapat memperoleh data dari server secara online.

Flutter menyediakan package bernama `http` yang digunakan untuk melakukan proses request HTTP. Package tersebut memungkinkan aplikasi melakukan berbagai method HTTP seperti GET, POST, PUT, dan DELETE dengan lebih mudah.

Pada praktikum ini, package `http` digunakan untuk mengambil data domain email dari REST API menggunakan method GET. Method GET berfungsi untuk meminta atau mengambil data dari server tanpa melakukan perubahan terhadap data tersebut.

Contoh penggunaan method GET pada Flutter adalah sebagai berikut:

`final response = await http.get(Uri.parse(url));`

Pada kode tersebut:

- `http.get()` digunakan untuk mengirim request GET ke server
- `Uri.parse(url)` digunakan untuk mengubah string URL menjadi objek URI
- `response` digunakan untuk menyimpan hasil response dari server

Dalam proses HTTP Request, Flutter menggunakan konsep asynchronous programming agar aplikasi tetap berjalan dengan lancar ketika mengambil data dari internet. Konsep asynchronous programming pada Dart menggunakan keyword `async` dan `await`.

Keyword `async` digunakan untuk menandai bahwa sebuah fungsi berjalan secara asynchronous, sedangkan `await` digunakan untuk menunggu proses request selesai sebelum melanjutkan eksekusi program berikutnya.

Selain itu, Flutter juga menggunakan tipe data `Future` untuk menangani proses asynchronous. `Future` merupakan tipe data yang digunakan untuk menyimpan hasil proses yang membutuhkan waktu tertentu, seperti pengambilan data dari API.

Contoh penggunaan `Future` pada Flutter adalah sebagai berikut:

```html
Future<List<Domain>> fetchDomains() async {
  // proses request API
}
```

Pada praktikum ini, HTTP Request digunakan untuk mengambil data dari endpoint berikut:

`https://api.qemail.web.id/v1/email/domains`

Data yang diperoleh dari server kemudian diproses menggunakan Flutter dan ditampilkan ke dalam tampilan aplikasi Android.

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