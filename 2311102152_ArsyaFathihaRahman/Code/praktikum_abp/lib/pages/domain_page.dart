import 'package:flutter/material.dart';
import '../entities/domain_entity.dart';
import '../providers/domain_provider.dart';

class DomainPage extends StatefulWidget {
  const DomainPage({super.key});

  @override
  State<DomainPage> createState() =>
      _DomainPageState();
}

class _DomainPageState
    extends State<DomainPage> {
  final DomainProvider provider =
      DomainProvider();

  late Future<List<DomainEntity>>
  futureDomains;

  @override
  void initState() {
    super.initState();

    futureDomains =
        provider.getDomains();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QEmail Domains',
        ),
      ),
      body: FutureBuilder<
        List<DomainEntity>
      >(
        future: futureDomains,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final domains =
              snapshot.data!;

          return ListView.builder(
            itemCount: domains.length,
            itemBuilder: (context, index) {
              final domain =
                  domains[index];

              return Card(
                margin:
                    const EdgeInsets.all(
                      8,
                    ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                        12,
                      ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          domain.id
                              .toString(),
                        ),
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      Expanded(
                        child: Text(
                          domain.name,
                          style:
                              const TextStyle(
                                fontSize:
                                    16,
                              ),
                        ),
                      ),

                      const Icon(
                        Icons.email,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}