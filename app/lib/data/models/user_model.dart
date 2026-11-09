import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String nim,
    required String name,
    String? email,
    String? avatarUrl,
    String? primaryClassId,
    required DateTime createdAt,
    DateTime? lastLogin,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromSupabase(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      nim: map['nim'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      primaryClassId: map['primary_class_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'] as String)
          : null,
    );
  }
}
