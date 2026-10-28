import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/ai_repository.dart';
import 'package:kodira/data/sources/remote/ai_source.dart';
import 'package:kodira/features/ai_mentor/providers/ai_provider.dart';
import 'package:kodira/features/ai_mentor/widgets/hint_bottom_sheet.dart';
import 'package:kodira/shared/widgets/error_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late _HintRepository repository;

  setUp(() {
    repository = _HintRepository();
  });

  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: Scaffold(
            body: HintBottomSheet(levelId: 7, topic: 'Variabel', userCode: ''),
          ),
        ),
      ),
    );
  }

  testWidgets('menampilkan tombol hint level 1 saat awal', (tester) async {
    await pumpSheet(tester);

    expect(find.text('Minta Hint Level 1'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Tombol minta hint level 1'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('tap tombol menampilkan loading', (tester) async {
    repository.response = Completer<String>();
    await pumpSheet(tester);

    await tester.tap(find.text('Minta Hint Level 1'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('menampilkan hint dan tombol level berikutnya', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Minta Hint Level 1'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Hint edukatif level 1'), findsOneWidget);
    expect(find.text('Minta Hint Level 2'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Hint level 1: Hint edukatif level 1'),
      findsOneWidget,
    );
  });

  testWidgets('setelah tiga hint tombol berikutnya dinonaktifkan', (
    tester,
  ) async {
    await pumpSheet(tester);

    for (var level = 1; level <= 3; level++) {
      await tester.tap(find.text('Minta Hint Level $level'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Hint maksimal sudah digunakan'), findsOneWidget);
    expect(find.text('Minta Hint Level 4'), findsNothing);
    expect(repository.calls, 3);
  });

  testWidgets('error menampilkan KodiraErrorWidget', (tester) async {
    repository.failure = AiException(500, 'server gagal');
    await pumpSheet(tester);

    await tester.tap(find.text('Minta Hint Level 1'));
    await tester.pumpAndSettle();

    expect(find.byType(KodiraErrorWidget), findsOneWidget);
  });

  testWidgets('tombol tutup memenuhi semantics dan menutup sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [aiRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: Scaffold(body: SizedBox.expand())),
      ),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          body: HintBottomSheet(levelId: 7, topic: 'Variabel', userCode: ''),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Tutup hint'), findsOneWidget);
    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();

    expect(find.byType(HintBottomSheet), findsNothing);
  });
}

class _HintRepository extends AiRepository {
  _HintRepository() : super(_UnusedAiSource());

  Object? failure;
  Completer<String>? response;
  int calls = 0;

  @override
  Future<String> getHint({
    required int levelId,
    required String topic,
    required String userCode,
    required int hintLevel,
  }) async {
    calls++;
    if (failure != null) throw failure!;
    final pending = response;
    if (pending != null && !pending.isCompleted) return pending.future;
    return 'Hint edukatif level $hintLevel';
  }
}

class _UnusedAiSource extends AiSource {
  _UnusedAiSource() : super(SupabaseClient('https://example.com', 'test-key'));
}
