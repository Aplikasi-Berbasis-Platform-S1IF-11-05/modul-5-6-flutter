import 'package:flutter/material.dart';

import '../models/domain_model.dart';

/// Kartu ringkas untuk satu domain email.
///
/// Widget ini menjaga lebar label ID tetap stabil sehingga
/// nama domain dan ikon tidak ikut bergeser.
class DomainListTile extends StatelessWidget {
  final DomainModel domain;

  const DomainListTile({super.key, required this.domain});

  /// Membangun satu baris kartu domain.
  ///
  /// Susunan elemen dibuat seimbang agar label ID,
  /// nama domain, dan ikon tetap enak dibaca di layar.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E6E1), width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F2EF),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                'ID: ${domain.id}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF787774),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                domain.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF37352F),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Icon(
            Icons.language,
            size: 17.0,
            color: Color(0xFFD3D1CB),
          ),
        ],
      ),
    );
  }
}