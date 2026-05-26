import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

/// Titik masuk utama aplikasi.
///
/// Fungsi ini menjalankan widget root agar seluruh antarmuka
/// dimulai dari satu titik yang konsisten dan mudah dilacak.
void main() {
  runApp(const QEmailApp());
}

/// Widget root untuk aplikasi QEmail Domains.
///
/// Widget ini menyiapkan tema dasar aplikasi, menonaktifkan banner debug,
/// dan mengarahkan pengguna ke [HomeScreen] sebagai layar awal.
class QEmailApp extends StatelessWidget {
  const QEmailApp({super.key});

  /// Membangun pohon widget utama aplikasi.
  ///
  /// `MaterialApp` dipasang sebagai kerangka utama agar tema
  /// dan layar awal tetap terpusat di satu tempat.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QEmail Domains',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}