// 2311102315 - Muhamad Rafli Al Farizqi
import 'package:flutter/material.dart';
import '../models/domain_model.dart';
import '../services/api_service.dart';
import '../widgets/domain_card.dart';
import '../widgets/domain_grid_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<DomainModel>> _futureDomains;

  SortMode _sortMode = SortMode.byId;
  bool _isGridView = false;
  String _searchQuery = '';
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
      _futureDomains = _apiService.fetchDomains(sortMode: _sortMode);
    });
  }

  void _toggleSort() {
    setState(() {
      _sortMode =
          _sortMode == SortMode.byId ? SortMode.byName : SortMode.byId;
    });
    _loadDomains();
  }

  List<DomainModel> _filterDomains(List<DomainModel> domains) {
    if (_searchQuery.isEmpty) return domains;
    return domains
        .where(
          (d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
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
            _buildToolbar(colorScheme),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
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
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.dns_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Domain Finder',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Temukan domain email sementara',
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
            icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
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
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _toggleSort,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded, size: 16,
                      color: colorScheme.onSecondaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    _sortMode == SortMode.byId ? 'Urut: ID' : 'Urut: Nama',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _isGridView = false),
            icon: Icon(
              Icons.view_list_rounded,
              color: !_isGridView
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Tampilan list',
          ),
          IconButton(
            onPressed: () => setState(() => _isGridView = true),
            icon: Icon(
              Icons.grid_view_rounded,
              color: _isGridView
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Tampilan grid',
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

        final filtered = _filterDomains(snapshot.data!);

        if (filtered.isEmpty) {
          return _buildNoResultState();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadDomains(),
          child: _isGridView
              ? _buildGridView(filtered)
              : _buildListView(filtered),
        );
      },
    );
  }

  Widget _buildListView(List<DomainModel> domains) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: domains.length,
      itemBuilder: (context, index) => DomainCard(domain: domains[index]),
    );
  }

  Widget _buildGridView(List<DomainModel> domains) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: domains.length,
      itemBuilder: (context, index) => DomainGridTile(domain: domains[index]),
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
            Icon(Icons.cloud_off_rounded, size: 64,
                color: colorScheme.error),
            const SizedBox(height: 16),
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
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
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
          Icon(Icons.inbox_rounded, size: 64,
              color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Tidak ada domain tersedia',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
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
          Icon(Icons.search_off_rounded, size: 64,
              color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Domain "$_searchQuery" tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
