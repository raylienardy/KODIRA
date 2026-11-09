class ClassModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final DateTime createdAt;

  const ClassModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.createdAt,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassModel &&
          other.id == id &&
          other.name == name &&
          other.code == code;

  @override
  int get hashCode => Object.hash(id, name, code);
}
