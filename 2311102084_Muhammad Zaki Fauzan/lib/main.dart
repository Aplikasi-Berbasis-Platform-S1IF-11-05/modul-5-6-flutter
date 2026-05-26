import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const BurnerMailApp());
}

const Color _darkBg = Color(0xFF0F172A);
const Color _darkCard = Color(0xFF1E293B);
const Color _accent = Color(0xFF10B981);
const Color _textMain = Color(0xFFF8FAFC);
const Color _textMuted = Color(0xFF94A3B8);

class BurnerMailApp extends StatelessWidget {
  const BurnerMailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Burner Mail',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _darkBg,
        colorScheme: const ColorScheme.dark(
          primary: _accent,
          surface: _darkCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _darkBg,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: _darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accent, width: 1.5),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _api = ApiService();
  int _currentIndex = 0;

  List<DomainData> _domains = [];
  List<MailMessage> _messages = [];
  DomainData? _selectedDomain;
  ActiveEmail? _activeEmail;

  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _fwdCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDomainsInit();
  }

  Future<void> _fetchDomainsInit() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.getDomains();
      setState(() {
        _domains = res;
        if (_domains.isNotEmpty) _selectedDomain = _domains.first;
      });
    } catch (e) {
      _showToast(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAction() async {
    if (_selectedDomain == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final res = await _api.createEmail(
        domainId: _selectedDomain!.id,
        username: _userCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        forwardTo: _fwdCtrl.text.trim(),
      );
      setState(() {
        _activeEmail = res;
        _messages = [];
        _currentIndex = 1;
      });
      _fetchInboxAction();
      _showToast('Email berhasil dibuat!');
    } catch (e) {
      _showToast(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchInboxAction() async {
    if (_activeEmail == null) return;
    setState(() => _isLoading = true);
    try {
      final res = await _api.getInbox(_activeEmail!.sessionToken);
      setState(() => _messages = res);
    } catch (e) {
      _showToast(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _darkCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Qemail' : 'Inbox',
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _fetchInboxAction,
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
        index: _currentIndex,
        children: [
          _buildGeneratorTab(),
          _buildInboxTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _darkCard,
        selectedItemColor: _accent,
        unselectedItemColor: _textMuted,
        currentIndex: _currentIndex,
        onTap: (val) => setState(() => _currentIndex = val),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Generator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_rounded),
            label: 'Inbox',
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_domains.isEmpty)
            const Text('Gagal memuat domain, coba restart aplikasi.',
                style: TextStyle(color: Colors.redAccent))
          else
            DropdownButtonFormField<DomainData>(
              value: _selectedDomain,
              items: _domains.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedDomain = val),
              decoration: const InputDecoration(
                labelText: 'Pilih Domain',
                prefixIcon: Icon(Icons.language),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _userCtrl,
            decoration: const InputDecoration(
              labelText: 'Username (Opsional)',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password (Opsional)',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fwdCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Forward Ke (Opsional)',
              prefixIcon: Icon(Icons.forward_to_inbox),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _generateAction,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'GENERATE EMAIL',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInboxTab() {
    if (_activeEmail == null) {
      return const Center(
        child: Text(
          'Belum ada email aktif.\nBuat dulu di tab Generator.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textMuted, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.mark_email_read, color: _accent, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email Aktif Saat Ini:',
                        style: TextStyle(fontSize: 12, color: _textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      _activeEmail!.email,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textMain),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: _accent),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _activeEmail!.email));
                  _showToast('Email disalin ke clipboard');
                },
              )
            ],
          ),
        ),
        Expanded(
          child: _messages.isEmpty
              ? const Center(
              child: Text('Kotak masuk kosong',
                  style: TextStyle(color: _textMuted)))
              : ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _accent.withOpacity(0.2),
                    child: const Icon(Icons.mail, color: _accent),
                  ),
                  title: Text(msg.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(msg.sender,
                          style: const TextStyle(
                              color: _accent, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(msg.preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _textMuted)),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ApiService {
  final String _base = 'https://api.qemail.web.id/v1/email';

  Future<List<DomainData>> getDomains() async {
    final res = await http.get(Uri.parse('$_base/domains'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data as List).map((e) => DomainData.fromJson(e)).toList();
    }
    throw Exception('Gagal ambil domain');
  }

  Future<ActiveEmail> createEmail({
    required int domainId,
    String? username,
    String? password,
    String? forwardTo,
  }) async {
    final Map<String, dynamic> body = {'domain_id': domainId};
    if (username != null && username.isNotEmpty) body['username'] = username;
    if (password != null && password.isNotEmpty) body['password'] = password;
    if (forwardTo != null && forwardTo.isNotEmpty) body['forward_to'] = forwardTo;

    final res = await http.post(
      Uri.parse('$_base/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return ActiveEmail.fromJson(jsonDecode(res.body));
    }
    throw Exception('Gagal generate email');
  }

  Future<List<MailMessage>> getInbox(String token) async {
    final res = await http.get(Uri.parse('$_base/inbox/$token?page=1&limit=20'));
    if (res.statusCode == 200) {
      final parsed = jsonDecode(res.body);
      final list = parsed['data'] ?? parsed;
      if (list is List) {
        return list.map((e) => MailMessage.fromJson(e)).toList();
      }
    }
    throw Exception('Gagal ambil inbox');
  }
}

class DomainData {
  final int id;
  final String name;

  DomainData({required this.id, required this.name});

  factory DomainData.fromJson(Map<String, dynamic> json) {
    return DomainData(id: json['id'], name: json['name'].toString());
  }
}

class ActiveEmail {
  final String email;
  final String sessionToken;

  ActiveEmail({required this.email, required this.sessionToken});

  factory ActiveEmail.fromJson(Map<String, dynamic> json) {
    return ActiveEmail(
      email: json['email'].toString(),
      sessionToken: json['session_token'].toString(),
    );
  }
}

class MailMessage {
  final String subject;
  final String sender;
  final String preview;

  MailMessage({
    required this.subject,
    required this.sender,
    required this.preview,
  });

  factory MailMessage.fromJson(Map<String, dynamic> json) {
    final s = json['from'] ?? json['sender'];
    String senderName = 'Unknown';
    if (s is Map) {
      senderName = s['address'] ?? s['email'] ?? s.toString();
    } else if (s != null) {
      senderName = s.toString();
    }

    return MailMessage(
      subject: json['subject']?.toString() ?? 'No Subject',
      sender: senderName,
      preview: json['text']?.toString() ?? json['preview']?.toString() ?? '',
    );
  }
}