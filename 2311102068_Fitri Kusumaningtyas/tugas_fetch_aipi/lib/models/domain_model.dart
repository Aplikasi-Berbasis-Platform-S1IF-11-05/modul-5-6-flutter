class Domain {
  final String id;
  final String name;

  Domain({required this.id, required this.name});

  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(
      id: json['id'].toString(),
      name: json['name'].toString(),
    );
  }
}