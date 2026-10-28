import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/ai_repository.dart';
import '../../../data/sources/remote/ai_source.dart';

final aiSourceProvider = Provider<AiSource>((ref) {
  return AiSource(Supabase.instance.client);
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(aiSourceProvider));
});

/// Jumlah hint yang berhasil diminta per level, dengan batas maksimum tiga.
final hintAttemptsProvider = StateProvider<Map<int, int>>(
  (ref) => <int, int>{},
);

final hintProvider =
    StateNotifierProvider.family<HintNotifier, AsyncValue<String?>, int>((
      ref,
      levelId,
    ) {
      return HintNotifier(ref.watch(aiRepositoryProvider), levelId);
    });

final feedbackProvider =
    StateNotifierProvider.family<
      FeedbackNotifier,
      AsyncValue<String?>,
      FeedbackRequest
    >((ref, request) {
      return FeedbackNotifier(ref.watch(aiRepositoryProvider), request);
    });

class FeedbackRequest {
  final int levelId;
  final String topic;
  final String userCode;
  final String expectedAnswer;
  final bool isCorrect;

  const FeedbackRequest({
    required this.levelId,
    required this.topic,
    required this.userCode,
    required this.expectedAnswer,
    required this.isCorrect,
  });

  @override
  bool operator ==(Object other) =>
      other is FeedbackRequest &&
      other.levelId == levelId &&
      other.topic == topic &&
      other.userCode == userCode &&
      other.expectedAnswer == expectedAnswer &&
      other.isCorrect == isCorrect;

  @override
  int get hashCode =>
      Object.hash(levelId, topic, userCode, expectedAnswer, isCorrect);
}

class HintNotifier extends StateNotifier<AsyncValue<String?>> {
  final AiRepository _repo;
  final int levelId;

  HintNotifier(this._repo, this.levelId) : super(const AsyncValue.data(null));

  Future<void> requestHint({
    required String topic,
    required String userCode,
    required int hintLevel,
  }) async {
    state = const AsyncValue.loading();
    try {
      final hint = await _repo.getHint(
        levelId: levelId,
        topic: topic,
        userCode: userCode,
        hintLevel: hintLevel,
      );
      state = AsyncValue.data(hint);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class FeedbackNotifier extends StateNotifier<AsyncValue<String?>> {
  final AiRepository _repo;
  final FeedbackRequest request;

  FeedbackNotifier(this._repo, this.request)
    : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final feedback = await _repo.getFeedback(
        levelId: request.levelId,
        topic: request.topic,
        userCode: request.userCode,
        expectedAnswer: request.expectedAnswer,
        isCorrect: request.isCorrect,
      );
      state = AsyncValue.data(feedback);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
