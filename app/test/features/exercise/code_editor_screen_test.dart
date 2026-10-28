import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/code_runner_repository.dart';
import 'package:kodira/data/sources/remote/code_runner_source.dart';
import 'package:kodira/features/exercise/providers/code_runner_provider.dart';
import 'package:kodira/features/exercise/screens/code_editor_screen.dart';
import 'package:kodira/shared/widgets/loading_widget.dart';

void main() {
  const levelId = 1;
  const levelTitle = 'Pengenalan C++';

  Future<void> pumpCodeEditor(
    WidgetTester tester,
    CodeRunnerRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [codeRunnerRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(
          home: CodeEditorScreen(levelId: levelId, levelTitle: levelTitle),
        ),
      ),
    );
  }

  group('CodeEditorScreen Widget Test', () {
    late _FakeCodeRunnerRepository repository;

    setUp(() {
      repository = _FakeCodeRunnerRepository();
    });

    testWidgets('menampilkan starter code C++ secara default', (tester) async {
      await pumpCodeEditor(tester, repository);
      await tester.pumpAndSettle();

      expect(find.textContaining('#include <iostream>'), findsOneWidget);
      expect(find.text('main.cpp'), findsOneWidget);
    });

    testWidgets('berganti ke starter code Java saat bahasa diubah', (
      tester,
    ) async {
      await pumpCodeEditor(tester, repository);
      await tester.pumpAndSettle();

      // Tap Java in SegmentedButton
      await tester.tap(find.text('Java'));
      await tester.pumpAndSettle();

      expect(find.textContaining('public class Main'), findsOneWidget);
      expect(find.text('Main.java'), findsOneWidget);
    });

    testWidgets('menjalankan kode dan menampilkan output saat sukses', (
      tester,
    ) async {
      repository.result = const CodeRunResult(
        stdout: 'Halo KODIRA\n',
        stderr: '',
        compileOutput: '',
        message: '',
        status: 'Accepted',
        time: '0.05',
      );

      await pumpCodeEditor(tester, repository);
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Tombol jalankan kode'));
      // loading state
      await tester.pump();
      expect(find.byType(KodiraLoadingWidget), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Halo KODIRA\n'), findsOneWidget);
      expect(find.text('0.05s'), findsOneWidget);
    });

    testWidgets('menampilkan error saat eksekusi gagal', (tester) async {
      repository.error = Exception('Network Error');

      await pumpCodeEditor(tester, repository);
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Tombol jalankan kode'));
      await tester.pumpAndSettle();

      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.textContaining('Network Error'), findsOneWidget);
    });

    testWidgets('tombol Reset mengembalikan kode ke starter', (tester) async {
      await pumpCodeEditor(tester, repository);
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'int x = 10;');
      expect(find.text('int x = 10;'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(find.textContaining('#include <iostream>'), findsOneWidget);
    });
  });
}

class _FakeCodeRunnerRepository implements CodeRunnerRepository {
  CodeRunResult? result;
  Object? error;

  @override
  Future<CodeRunResult> runCode({
    required String sourceCode,
    required String language,
    String? stdin,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (error != null) throw error!;
    return result!;
  }
}
