// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:flutter/material.dart';
import 'screens/domain_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QEmail Domain Explorer',
      theme: _buildThemeData(),
      home: const DomainListScreen(),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A237E),
        ),
      ),
    );
  }
}
