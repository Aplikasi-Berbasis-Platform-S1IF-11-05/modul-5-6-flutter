import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QEmail Domain Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DomainPage(),
    );
  }
}

class Domain {
  final int id;
  final String name;

  Domain({required this.id, required this.name});

  factory Domain.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    return Domain(id: id, name: json['name']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}


class DomainService {
  static const _base = 'https://api.qemail.web.id/v1/email';

  dynamic _unwrapData(dynamic data) {
    if (data is Map && data.containsKey('data')) {
      return data['data'];
    }
    return data;
  }

  Future<List<Domain>> fetchAll() async {
    final res = await http.get(Uri.parse('$_base/domains'));
    if (res.statusCode == 200) {
      final data = _unwrapData(jsonDecode(res.body));
      if (data is! List) {
        throw Exception('Format respons domain tidak valid');
      }
      return data.map((e) => Domain.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat domain (${res.statusCode})');
  }

  Future<Domain> create(String name) async {
    final res = await http.post(
      Uri.parse('$_base/domains'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = _unwrapData(jsonDecode(res.body));
      return Domain.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Gagal menambah domain (${res.statusCode})');
  }

  Future<Domain> update(int id, String name) async {
    final res = await http.put(
      Uri.parse('$_base/domains/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode == 200) {
      final data = _unwrapData(jsonDecode(res.body));
      return Domain.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Gagal mengupdate domain (${res.statusCode})');
  }

  Future<void> delete(int id) async {
    final res = await http.delete(Uri.parse('$_base/domains/$id'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Gagal menghapus domain (${res.statusCode})');
    }
  }
}

class DomainPage extends StatefulWidget {
  const DomainPage({super.key});

  @override
  State<DomainPage> createState() => _DomainPageState();
}

class _DomainPageState extends State<DomainPage> {
  final _service = DomainService();
  final _searchCtrl = TextEditingController();

  List<Domain> _all = [];
  List<Domain> _filtered = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _service.fetchAll();
      setState(() {
        _all = list;
        _applyFilter(_searchCtrl.text);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_all)
          : _all.where((d) => d.name.toLowerCase().contains(lower)).toList();
    });
  }

  Future<void> _onCreate() async {
    final name = await _showDomainDialog(title: 'Tambah Domain');
    if (name == null || name.trim().isEmpty) return;
    try {
      _showLoading();
      final newDomain = await _service.create(name.trim());
      setState(() {
        _all.add(newDomain);
        _applyFilter(_searchCtrl.text);
      });
      if (mounted) Navigator.pop(context); // tutup loading
      _showSnack('Domain "$name" berhasil ditambahkan', isError: false);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnack(e.toString(), isError: true);
    }
  }

  Future<void> _onEdit(Domain domain) async {
    final name = await _showDomainDialog(
      title: 'Edit Domain',
      initial: domain.name,
    );
    if (name == null || name.trim().isEmpty || name.trim() == domain.name) {
      return;
    }
    try {
      _showLoading();
      final updated = await _service.update(domain.id, name.trim());
      setState(() {
        final idx = _all.indexWhere((d) => d.id == domain.id);
        if (idx != -1) _all[idx] = updated;
        _applyFilter(_searchCtrl.text);
      });
      if (mounted) Navigator.pop(context);
      _showSnack('Domain berhasil diupdate', isError: false);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnack(e.toString(), isError: true);
    }
  }

  Future<void> _onDelete(Domain domain) async {
    final confirmed = await _showConfirmDialog(domain.name);
    if (!confirmed) return;
    try {
      _showLoading();
      await _service.delete(domain.id);
      setState(() {
        _all.removeWhere((d) => d.id == domain.id);
        _applyFilter(_searchCtrl.text);
      });
      if (mounted) Navigator.pop(context);
      _showSnack('Domain "${domain.name}" dihapus', isError: false);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnack(e.toString(), isError: true);
    }
  }

  Future<String?> _showDomainDialog({
    required String title,
    String initial = '',
  }) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama Domain',
            hintText: 'contoh.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.language),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Domain?'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Domain '),
              TextSpan(
                text: name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' akan dihapus permanen.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        title: const Text(
          'QEmail — Domain Manager',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onCreate,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Domain'),
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : Column(
              children: [
                _buildStats(),
                _buildSearch(),
                _buildListHeader(),
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );

  Widget _buildStats() => Container(
    width: double.infinity,
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withAlpha(77),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        _statCard('Total Domain', _all.length, Icons.dns_rounded),
        const SizedBox(width: 12),
        _statCard('Hasil Pencarian', _filtered.length, Icons.search_rounded),
      ],
    ),
  );

  Widget _statCard(String label, int value, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withAlpha(217),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildSearch() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: TextField(
      controller: _searchCtrl,
      onChanged: _applyFilter,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Color(0xFF16A34A)),
        hintText: 'Cari domain...',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
        ),
        suffixIcon: _searchCtrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchCtrl.clear();
                  _applyFilter('');
                },
              )
            : null,
      ),
    ),
  );

  Widget _buildListHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: Row(
      children: [
        Text(
          'Daftar Domain (${_filtered.length})',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF166534),
          ),
        ),
      ],
    ),
  );

  Widget _buildList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              _searchCtrl.text.isNotEmpty
                  ? 'Tidak ada domain yang cocok'
                  : 'Belum ada domain',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final domain = _filtered[index];
        return _DomainCard(
          domain: domain,
          index: index,
          onEdit: () => _onEdit(domain),
          onDelete: () => _onDelete(domain),
        );
      },
    );
  }
}

class _DomainCard extends StatelessWidget {
  final Domain domain;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DomainCard({
    required this.domain,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  // Warna avatar berputar berdasarkan index
  static const _colors = [
    Color(0xFF16A34A),
    Color(0xFF0891B2),
    Color(0xFF7C3AED),
    Color(0xFFD97706),
    Color(0xFFDB2777),
  ];

  @override
  Widget build(BuildContext context) {
    final avatarColor = _colors[index % _colors.length];
    final initial = domain.name.isNotEmpty ? domain.name[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade100),
      ),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: avatarColor,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          domain.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          'ID: ${domain.id}',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: const Color(0xFF0891B2),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red.shade400,
              tooltip: 'Hapus',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
