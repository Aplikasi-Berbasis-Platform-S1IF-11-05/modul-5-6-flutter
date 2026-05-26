// 2311102318 - Grashela Ayudia Prameswari
import 'package:flutter/material.dart';
import '../models/domain_model.dart';
import '../services/api_service.dart';
import '../widgets/domain_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<DomainModel>> _futureDomains;

  final Set<int> _favoriteIds = {};
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDomains();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDomains() {
    setState(() {
      _futureDomains = _apiService.fetchDomains();
    });
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  List<DomainModel> _applyFilters(List<DomainModel> domains) {
    var result = domains;

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_showFavoritesOnly) {
      result = result.where((d) => _favoriteIds.contains(d.id)).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme),
            _buildSearchBar(colorScheme),
            _buildFilterChips(colorScheme),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.mail_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Domain Explorer',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Jelajahi domain email sementara',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadDomains,
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primaryContainer,
            ),
            icon: Icon(
              Icons.refresh_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Cari domain...',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Semua'),
            selected: !_showFavoritesOnly,
            onSelected: (_) => setState(() => _showFavoritesOnly = false),
            selectedColor: colorScheme.primaryContainer,
            checkmarkColor: colorScheme.onPrimaryContainer,
            labelStyle: TextStyle(
              color: !_showFavoritesOnly
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: Icon(
              Icons.favorite_rounded,
              size: 16,
              color: _showFavoritesOnly
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            label: Text('Favorit (${_favoriteIds.length})'),
            selected: _showFavoritesOnly,
            onSelected: (_) => setState(() => _showFavoritesOnly = true),
            selectedColor: colorScheme.primaryContainer,
            checkmarkColor: colorScheme.onPrimaryContainer,
            labelStyle: TextStyle(
              color: _showFavoritesOnly
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          FutureBuilder<List<DomainModel>>(
            future: _futureDomains,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final count = _applyFilters(snapshot.data!).length;
              return Text(
                '$count domain',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<DomainModel>>(
      future: _futureDomains,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 3),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final filtered = _applyFilters(snapshot.data!);

        if (filtered.isEmpty) {
          return _buildNoResultState();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadDomains(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final domain = filtered[index];
              return DomainCard(
                domain: domain,
                isFavorite: _favoriteIds.contains(domain.id),
                onFavoriteToggle: () => _toggleFavorite(domain.id),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadDomains,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Tidak ada domain tersedia',
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            _showFavoritesOnly
                ? 'Belum ada domain favorit'
                : 'Domain "$_searchQuery" tidak ditemukan',
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
