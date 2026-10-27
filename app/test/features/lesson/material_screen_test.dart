import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/material_model.dart';
import 'package:kodira/features/exercise/providers/exercise_provider.dart';
import 'package:kodira/features/lesson/providers/material_provider.dart';
import 'package:kodira/features/lesson/screens/material_screen.dart';

void main() {
  const levelId = 7;
  final material = MaterialModel(
    id: 70,
    levelId: levelId,
    slideOrder: 1,
    title: 'Pengenalan variabel',
    content: 'Variabel menyimpan sebuah nilai.',
    codeSnippet: 'int score = 10;',
    createdAt: DateTime(2026, 1, 1),
  );

  Future<void> pumpMaterial(
    WidgetTester tester,
    Future<List<MaterialModel>> Function() loader,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          materialsByLevelProvider(levelId).overrideWith((ref) => loader()),
          dragDropExercisesProvider(levelId).overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: MaterialScreen(levelId: levelId, levelTitle: 'Level Variabel'),
        ),
      ),
    );
  }

  testWidgets('menampilkan indikator loading saat materi dimuat', (
    tester,
  ) async {
    final completer = Completer<List<MaterialModel>>();
    await pumpMaterial(tester, () => completer.future);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete(<MaterialModel>[material]);
    await tester.pumpAndSettle();
  });

  testWidgets('menampilkan teks error saat provider materi gagal', (
    tester,
  ) async {
    await pumpMaterial(
      tester,
      () => Future<List<MaterialModel>>.error(Exception('network failed')),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.text('Koneksi bermasalah. Periksa internet Anda.'),
      findsOneWidget,
    );
  });

  testWidgets('menampilkan isi materi dan tombol Lanjut saat sukses', (
    tester,
  ) async {
    await pumpMaterial(tester, () async => <MaterialModel>[material]);
    await tester.pumpAndSettle();

    expect(find.text('Pengenalan variabel'), findsOneWidget);
    expect(find.text('Variabel menyimpan sebuah nilai.'), findsOneWidget);
    expect(find.text('Lanjut ke Latihan'), findsOneWidget);
  });
}
