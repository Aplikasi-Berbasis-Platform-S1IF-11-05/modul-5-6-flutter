class DomainEntity {
  final int id;
  final String name;

  DomainEntity({
    required this.id,
    required this.name,
  });

  factory DomainEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return DomainEntity(
      id: json['id'],
      name: json['name'],
    );
  }
}