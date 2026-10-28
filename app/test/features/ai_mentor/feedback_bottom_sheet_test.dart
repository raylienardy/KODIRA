import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/ai_repository.dart';
import 'package:kodira/data/sources/remote/ai_source.dart';
import 'package:kodira/features/ai_mentor/providers/ai_provider.dart';
import 'package:kodira/features/ai_mentor/widgets/feedback_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late _FeedbackRepository repository;

  setUp(() {
    repository = _FeedbackRepository();
  });

  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: Scaffold(
            body: FeedbackBottomSheet(
              levelId: 1,
              topic: 'Variabel',
              userCode: '',
              expectedAnswer: 'integer',
              isCorrect: false,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('menampilkan loading saat feedback diminta', (tester) async {
    repository.response = Completer<String>();
    await pumpSheet(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('menampilkan feedback setelah request sukses', (tester) async {
    await pumpSheet(tester);
    await tester.pumpAndSettle();

    final semantics = tester.ensureSemantics();
    expect(
      find.text('Periksa kembali tipe data yang digunakan.'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Feedback AI: Periksa kembali tipe data yang digunakan.',
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('error menampilkan pesan fallback yang aman', (tester) async {
    repository.failure = AiException(502, 'upstream gagal');
    await pumpSheet(tester);
    await tester.pumpAndSettle();

    expect(find.text('Feedback AI tidak tersedia saat ini'), findsOneWidget);
  });

  testWidgets('tombol Tutup menutup sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: Scaffold(body: Text('Layar'))),
      ),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          body: FeedbackBottomSheet(
            levelId: 1,
            topic: 'Variabel',
            userCode: '',
            expectedAnswer: 'integer',
            isCorrect: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Tutup feedback AI'), findsOneWidget);
    semantics.dispose();
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    expect(find.byType(FeedbackBottomSheet), findsNothing);
    expect(find.text('Layar'), findsOneWidget);
  });

  testWidgets('feedback dan kontrol tutup dapat diakses', (tester) async {
    await pumpSheet(tester);
    await tester.pumpAndSettle();

    final semantics = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel(
        'Feedback AI: Periksa kembali tipe data yang digunakan.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Tutup feedback AI'), findsOneWidget);
    semantics.dispose();
  });
}

class _FeedbackRepository extends AiRepository {
  _FeedbackRepository() : super(_UnusedAiSource());

  Object? failure;
  Completer<String>? response;

  @override
  Future<String> getFeedback({
    required int levelId,
    required String topic,
    required String userCode,
    required String expectedAnswer,
    required bool isCorrect,
  }) async {
    if (failure != null) throw failure!;
    final pending = response;
    if (pending != null && !pending.isCompleted) return pending.future;
    return 'Periksa kembali tipe data yang digunakan.';
  }
}

class _UnusedAiSource extends AiSource {
  _UnusedAiSource() : super(SupabaseClient('https://example.com', 'test-key'));
}
