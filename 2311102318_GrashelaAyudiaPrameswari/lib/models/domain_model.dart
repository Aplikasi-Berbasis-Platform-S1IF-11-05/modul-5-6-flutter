// 2311102318 - Grashela Ayudia Prameswari

class DomainModel {
  final int id;
  final String name;

  const DomainModel({
    required this.id,
    required this.name,
  });

  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  String get extension => name.contains('.') ? name.split('.').last : name;
}
