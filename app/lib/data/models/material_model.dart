import 'package:freezed_annotation/freezed_annotation.dart';

part 'material_model.freezed.dart';
part 'material_model.g.dart';

@freezed
class MaterialModel with _$MaterialModel {
  const MaterialModel._();

  const factory MaterialModel({
    required int id,
    required int levelId,
    required int slideOrder,
    String? title,
    String? content,
    String? codeSnippet,
    required DateTime createdAt,
  }) = _MaterialModel;

  factory MaterialModel.fromJson(Map<String, dynamic> json) =>
      _$MaterialModelFromJson(json);

  factory MaterialModel.fromSupabase(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] as int,
      levelId: map['level_id'] as int,
      slideOrder: map['slide_order'] as int,
      title: map['title'] as String?,
      content: map['content'] as String?,
      codeSnippet: map['code_snippet'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
