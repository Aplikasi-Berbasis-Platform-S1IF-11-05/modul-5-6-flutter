/// Willyan Hyuga Pratama
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Domain Search & Favorite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D12), // Dark Background
        primaryColor: const Color(0xFF00FF41), // Neon Green
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF15161E),
          elevation: 0,
        ),
        cardColor: const Color(0xFF1A1B23),
        useMaterial3: true,
      ),
      home: const DomainDashboard(),
    );
  }
}

class DomainDashboard extends StatefulWidget {
  const DomainDashboard({super.key});

  @override
  State<DomainDashboard> createState() => _DomainDashboardState();
}

class _DomainDashboardState extends State<DomainDashboard> {
  // State variables
  List<dynamic> _allDomains = [];
  List<dynamic> _filteredDomains = [];
  final Set<String> _favoriteIds = {};
  
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDomains();
    // Add listener for realtime search filtering
    _searchController.addListener(_filterDomains);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method to fetch data from API
  Future<void> _fetchDomains() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('https://api.qemail.web.id/v1/email/domains'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Adjust based on the actual API JSON structure
          if (data is List) {
            _allDomains = data;
          } else if (data['data'] != null) {
            _allDomains = data['data'];
          }
          _filteredDomains = _allDomains;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi.\nPastikan Anda terhubung ke internet.';
        _isLoading = false;
      });
    }
  }

  // Method to filter domains realtime
  void _filterDomains() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDomains = _allDomains.where((domain) {
        final name = (domain['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  // Method to toggle favorite status locally
  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SERVER DOMAINS',
          style: TextStyle(
            color: Color(0xFF00FF41),
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00FF41)),
            onPressed: _fetchDomains,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search domains...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00FF41)),
                filled: true,
                fillColor: const Color(0xFF1A1B23),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(color: Color(0xFF00FF41), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ),
          
          // Stats Row Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBadge('TOTAL', _allDomains.length.toString()),
                _buildStatBadge('FAVORITES', _favoriteIds.length.toString()),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Content Section (List / Loading / Error)
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00FF41),
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FF41),
                                foregroundColor: Colors.black,
                              ),
                              onPressed: _fetchDomains,
                              child: const Text('RETRY'),
                            ),
                          ],
                        ),
                      )
                    : _filteredDomains.isEmpty
                        ? const Center(
                            child: Text(
                              'No domains found',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            itemCount: _filteredDomains.length,
                            itemBuilder: (context, index) {
                              final domain = _filteredDomains[index];
                              final id = domain['id']?.toString() ?? '';
                              final name = domain['name']?.toString() ?? 'Unknown';
                              final isFav = _favoriteIds.contains(id);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1B23),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: isFav ? const Color(0xFF00FF41).withOpacity(0.5) : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    if (isFav)
                                      BoxShadow(
                                        color: const Color(0xFF00FF41).withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D0D12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.language,
                                      color: Color(0xFF00FF41),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'ID: $id',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? const Color(0xFF00FF41) : Colors.white54,
                                    ),
                                    onPressed: () => _toggleFavorite(id),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // Helper widget for stats badge
  Widget _buildStatBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF00FF41),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
