//kartika pringgo hutomo
//2311102196
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const EmailApp());
}

class EmailApp extends StatelessWidget {
  const EmailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email REST API',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32), 
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF81C784), 
        ),
        useMaterial3: true,
      ),
      home: const EmailListScreen(),
    );
  }
}

class EmailListScreen extends StatefulWidget {
  const EmailListScreen({super.key});

  @override
  State<EmailListScreen> createState() => _EmailListScreenState();
}

class _EmailListScreenState extends State<EmailListScreen> {
  List<dynamic> _emails = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  // Fungsi untuk mengambil data dari API
  Future<void> _fetchEmails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.qemail.web.id/v1/email/inbox/2311102196'),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        
        setState(() {
          // Menyesuaikan jika response berupa objek yang memiliki properti data
          if (decodedData is Map && decodedData.containsKey('data')) {
            _emails = decodedData['data'];
          } else if (decodedData is List) {
            _emails = decodedData;
          } else {
            _emails = [decodedData];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data (Error ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pesan Masuk',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEmails,
        color: Theme.of(context).primaryColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // 1. Tampilkan Loading Indicator
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 2. Tampilkan Error Message jika ada error
    if (_errorMessage.isNotEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchEmails,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 3. Tampilkan pesan kosong jika tidak ada data
    if (_emails.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: const Center(
              child: Text(
                'Tidak ada pesan.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }

    // 4. Tampilkan daftar email
    return ListView.separated(
      itemCount: _emails.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final email = _emails[index];
        
        // Mengekstrak field umum dari response JSON
        final subject = email['subject'] ?? email['title'] ?? 'Tidak ada subjek';
        final sender = email['sender'] ?? email['from'] ?? email['email'] ?? 'Pengirim tidak diketahui';
        final body = email['body'] ?? email['snippet'] ?? email['message'] ?? '';
        
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text(
              sender.isNotEmpty ? sender[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            subject,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                sender,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ]
            ],
          ),
          onTap: () {
            // Aksi saat item ditekan
          },
        );
      },
    );
  }
}
