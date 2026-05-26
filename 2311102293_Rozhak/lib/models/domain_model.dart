/// Representasi data domain email dari API.
///
/// Menyimpan ID dan nama domain dalam struktur
/// sederhana agar mudah dipakai UI maupun layanan data.
class DomainModel {
  final int id;
  final String name;

  /// Membuat instance domain baru.
  ///
  /// Dipakai saat nilai model sudah siap
  /// dan tidak membutuhkan pemetaan tambahan.
  const DomainModel({
    required this.id,
    required this.name,
  });

  /// Membentuk model domain dari JSON API.
  ///
  /// Mengambil field yang diperlukan
  /// lalu mengubahnya menjadi objek siap pakai.
  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}