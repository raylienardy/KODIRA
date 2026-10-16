import 'package:freezed_annotation/freezed_annotation.dart';

part 'level_model.freezed.dart';
part 'level_model.g.dart';

@freezed
class LevelModel with _$LevelModel {
  const LevelModel._();

  const factory LevelModel({
    required int id,
    required int levelNumber,
    required String title,
    String? description,
    String? topic,
    String? language,
    int? difficulty,
    required DateTime createdAt,
  }) = _LevelModel;

  factory LevelModel.fromJson(Map<String, dynamic> json) =>
      _$LevelModelFromJson(json);

  factory LevelModel.fromSupabase(Map<String, dynamic> map) {
    return LevelModel(
      id: map['id'] as int,
      levelNumber: map['level_number'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      topic: map['topic'] as String?,
      language: map['language'] as String?,
      difficulty: map['difficulty'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
