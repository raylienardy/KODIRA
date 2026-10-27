import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/exercise_model.dart';
import 'package:kodira/features/exercise/providers/exercise_provider.dart';
import 'package:kodira/features/exercise/screens/drag_drop_screen.dart';

void main() {
  const levelId = 4;
  final exercise = ExerciseModel(
    id: 401,
    levelId: levelId,
    type: 'drag_drop',
    prompt: 'Susun deklarasi variabel',
    payload: <String, dynamic>{
      'tokens': <Map<String, String>>[
        <String, String>{'id': 't1', 'text': 'int score'},
        <String, String>{'id': 't2', 'text': '='},
        <String, String>{'id': 't3', 'text': '10;'},
      ],
      'answer': <String>['t1', 't2', 't3'],
      'language': 'cpp',
    },
    difficulty: 1,
    createdAt: DateTime(2026, 1, 1),
  );

  Future<void> pumpDragDrop(
    WidgetTester tester,
    Future<List<ExerciseModel>> Function() loader,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          dragDropExercisesProvider(levelId).overrideWith((ref) => loader()),
        ],
        child: const MaterialApp(home: DragDropScreen(levelId: levelId)),
      ),
    );
  }

  testWidgets('menampilkan loading saat exercise dimuat', (tester) async {
    final completer = Completer<List<ExerciseModel>>();
    await pumpDragDrop(tester, () => completer.future);
    await tester.pump();

    expect(find.bySemanticsLabel('Memuat latihan'), findsOneWidget);
    completer.complete(<ExerciseModel>[exercise]);
    await tester.pumpAndSettle();
  });

  testWidgets('menampilkan pesan error saat provider exercise gagal', (
    tester,
  ) async {
    await pumpDragDrop(
      tester,
      () => Future<List<ExerciseModel>>.error(Exception('network failed')),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('network failed'), findsOneWidget);
  });

  testWidgets('menampilkan prompt dan token saat exercise tersedia', (
    tester,
  ) async {
    await pumpDragDrop(tester, () async => <ExerciseModel>[exercise]);
    await tester.pumpAndSettle();

    expect(find.text('Susun deklarasi variabel'), findsOneWidget);
    expect(find.text('int score'), findsOneWidget);
    expect(find.text('='), findsWidgets);
    expect(find.text('10;'), findsOneWidget);
  });
}
