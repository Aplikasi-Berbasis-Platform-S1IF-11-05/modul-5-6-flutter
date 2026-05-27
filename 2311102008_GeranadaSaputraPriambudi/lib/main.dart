//Geranada Saputra Priambudi - 2311102008
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'email_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Email Generator',
      debugShowCheckedModeBanner: false,
      // Konfigurasi Tema Dark Mode Modern Premium
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0C12), // Hitam Kebiruan Sangat Gelap
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8B5CF6), // Ungu Violet Neon
          secondary: Color(0xFF6366F1), // Indigo Accent
          surface: Color(0xFF181824), // Slate Abu Gelap untuk Card
        ),
        useMaterial3: true,
      ),
      home: const EmailGeneratorScreen(),
    );
  }
}

class EmailGeneratorScreen extends StatefulWidget {
  const EmailGeneratorScreen({super.key});

  @override
  State<EmailGeneratorScreen> createState() => _EmailGeneratorScreenState();
}

class _EmailGeneratorScreenState extends State<EmailGeneratorScreen> {
  final EmailService _emailService = EmailService();
  Future<String>? _emailFuture;
  bool _isSimulationMode = false;

  @override
  void initState() {
    super.initState();
    _refreshEmail();
  }

  // Fungsi untuk memicu pengambilan email baru
  void _refreshEmail() {
    setState(() {
      _emailFuture = _isSimulationMode
          ? _emailService.fetchMockEmail()
          : _emailService.fetchRandomEmail();
    });
  }

  // Fungsi menyalin email ke Clipboard dengan pengecekan async safety
  void _copyToClipboard(String email) {
    Clipboard.setData(ClipboardData(text: email)).then((_) {
      if (!mounted) return; // Memastikan widget masih aktif dalam widget tree
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text(
                'Email berhasil disalin ke clipboard!',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E1B4B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6)),
            SizedBox(width: 8),
            Text(
              'Q-Email Generator',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // Latar belakang dengan aksen cahaya ungu radial lembut (menggunakan .withAlpha untuk kompatibilitas Flutter modern)
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              const Color(0xFF8B5CF6).withAlpha(20), // Transparansi ~8%
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bagian Header Status
              _buildHeaderSection(),
              const Spacer(),

              // FutureBuilder untuk menangani State pengambilan email
              FutureBuilder<String>(
                future: _emailFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCard();
                  } else if (snapshot.hasError) {
                    return _buildErrorCard(snapshot.error.toString());
                  } else if (snapshot.hasData) {
                    return _buildEmailCard(snapshot.data!);
                  }
                  return const SizedBox.shrink();
                },
              ),

              const Spacer(),

              // Control Panel (Switch Mode & Tombol Generate)
              _buildControlPanel(),
            ],
          ),
        ),
      ),
    );
  }

  // Header yang menampilkan detail praktikum dan mode saat ini
  Widget _buildHeaderSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withAlpha(30), // Transparansi ~12%
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withAlpha(76), // Transparansi ~30%
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isSimulationMode ? Colors.orangeAccent : Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isSimulationMode ? 'MODE SIMULASI (OFFLINE)' : 'MODE REAL API (GET)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Praktikum REST API - HTTP',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Card Modern saat data email sukses didapatkan
  Widget _buildEmailCard(String email) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181824),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withAlpha(51), // Transparansi ~20%
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withAlpha(38), // Transparansi ~15%
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container Lingkaran untuk Icon Email
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withAlpha(30), // Transparansi ~12%
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alternate_email_rounded,
              color: Color(0xFF8B5CF6),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          
          const Text(
            'EMAIL TERGENERATE',
            style: TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          // Tampilan teks email yang dapat diseleksi
          SelectableText(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Salin ke Clipboard
          OutlinedButton.icon(
            onPressed: () => _copyToClipboard(email),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Salin Email'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.withAlpha(76)), // Transparansi ~30%
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan Card saat proses fetch / loading
  Widget _buildLoadingCard() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF181824).withAlpha(128), // Transparansi ~50%
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withAlpha(13), // Transparansi ~5%
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            ),
            SizedBox(height: 16),
            Text(
              'Menghubungi server API...',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card Modern ketika terjadi Error pada Fetch API
  Widget _buildErrorCard(String error) {
    // Membersihkan teks Exception agar lebih ramah dibaca
    final cleanError = error.replaceAll('Exception: ', '');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B1F), // Nuansa merah gelap/burgundy hangat
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.redAccent.withAlpha(76), // Transparansi ~30%
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withAlpha(13), // Transparansi ~5%
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withAlpha(30), // Transparansi ~12%
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'API ERROR DETECTED',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cleanError,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Tombol pintas untuk mengaktifkan simulasi langsung dari box error
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isSimulationMode = true;
              });
              _refreshEmail();
            },
            icon: const Icon(Icons.bolt, color: Colors.orangeAccent),
            label: const Text(
              'Aktifkan Mode Simulasi',
              style: TextStyle(color: Colors.orangeAccent),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.orangeAccent.withAlpha(25), // Transparansi ~10%
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Panel kontrol berisi switch mode dan tombol refresh generator
  Widget _buildControlPanel() {
    return Column(
      children: [
        // Switch Toggle Mode Simulasi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF181824),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withAlpha(13), // Transparansi ~5%
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.bolt_rounded, color: Colors.orangeAccent),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Simulasi Offline',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Gunakan jika API 404 / Offline',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: _isSimulationMode,
                onChanged: (value) {
                  setState(() {
                    _isSimulationMode = value;
                  });
                  _refreshEmail();
                },
                activeThumbColor: Colors.orangeAccent,
                activeTrackColor: Colors.orangeAccent.withAlpha(100),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tombol Generator dengan Background Gradien Ungu-Indigo Premium
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8B5CF6), // Violet
                Color(0xFF6366F1), // Indigo
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withAlpha(76), // Transparansi ~30%
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _refreshEmail,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text(
              'Generate Email Baru',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
