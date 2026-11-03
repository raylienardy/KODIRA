import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/features/profile/widgets/mastery_concept_sheet.dart';

Widget _host() {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (BuildContext context) => Center(
          child: ElevatedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => const MasteryConceptSheet(),
            ),
            child: const Text('Buka'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.pumpWidget(_host());
  await tester.tap(find.text('Buka'));
  await tester.pumpAndSettle();
}

void _setSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('menampilkan judul dan penjelasan konsep', (tester) async {
    _setSurface(tester);
    await _openSheet(tester);

    expect(find.text('Apa itu Mastery?'), findsOneWidget);
    expect(
      find.textContaining('Mastery adalah nilai penguasaan level'),
      findsOneWidget,
    );
    expect(
      find.textContaining('bukan hanya jumlah soal yang benar'),
      findsOneWidget,
    );
  });

  testWidgets('menampilkan tiga tips perbaikan', (tester) async {
    _setSurface(tester);
    await _openSheet(tester);

    expect(
      find.text('Kerjakan ulang kuis level ini untuk penguatan.'),
      findsOneWidget,
    );
    expect(
      find.text('Perhatikan feedback AI Mentor saat salah.'),
      findsOneWidget,
    );
    expect(
      find.text('Ulang materi jika mastery di bawah 40%.'),
      findsOneWidget,
    );
  });

  testWidgets('tombol Tutup menutup sheet', (tester) async {
    _setSurface(tester);
    await _openSheet(tester);

    expect(find.text('Apa itu Mastery?'), findsOneWidget);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    expect(find.text('Apa itu Mastery?'), findsNothing);
  });
}
