// 2311102090-Buswiryawan Raditya Boenyamin
import 'package:flutter/material.dart';
import '../models/domain_model.dart';
import '../services/domain_service.dart';
import '../widgets/domain_card.dart';

class DomainListScreen extends StatefulWidget {
  const DomainListScreen({super.key});

  @override
  State<DomainListScreen> createState() => _DomainListScreenState();
}

class _DomainListScreenState extends State<DomainListScreen> {
  final DomainService _domainService = DomainService();
  late Future<List<DomainModel>> _futureDomains;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureDomains = _domainService.fetchDomains();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Domain Explorer'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A237E),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<DomainModel>>(
      future: _futureDomains,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 3));
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada domain tersedia'));
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => DomainCard(domain: snapshot.data![index]),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}
