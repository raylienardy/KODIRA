import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_model.freezed.dart';
part 'exercise_model.g.dart';

@freezed
class ExerciseModel with _$ExerciseModel {
  const ExerciseModel._();

  const factory ExerciseModel({
    required int id,
    required int levelId,
    required String type,
    required String prompt,
    Map<String, dynamic>? payload,
    int? difficulty,
    required DateTime createdAt,
  }) = _ExerciseModel;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  factory ExerciseModel.fromSupabase(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as int,
      levelId: map['level_id'] as int,
      type: map['type'] as String,
      prompt: map['prompt'] as String,
      payload: map['payload'] as Map<String, dynamic>?,
      difficulty: map['difficulty'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
