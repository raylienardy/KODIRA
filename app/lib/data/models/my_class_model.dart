class MyClass {
  final String id;
  final String name;
  final String code;
  final String? description;
  final bool isPrimary;
  final DateTime enrolledAt;

  const MyClass({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isPrimary,
    required this.enrolledAt,
  });

  factory MyClass.fromMap(Map<String, dynamic> map) {
    return MyClass(
      id: map['class_id'] as String,
      name: map['class_name'] as String,
      code: map['class_code'] as String,
      description: map['class_description'] as String?,
      isPrimary: map['is_primary'] as bool? ?? false,
      enrolledAt: DateTime.parse(map['enrolled_at'] as String),
    );
  }
}
