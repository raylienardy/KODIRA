import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/features/adaptive/models/mastery_breakdown.dart';
import 'package:kodira/features/quiz/widgets/mastery_breakdown_sheet.dart';

MasteryBreakdown _breakdown() => MasteryBreakdown(
  accuracy: 0.85,
  consistency: 0.9,
  timeNorm: 0.5,
  total: 0.8275,
);

Widget _host(MasteryBreakdown breakdown) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (BuildContext context) => Center(
          child: ElevatedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => MasteryBreakdownSheet(breakdown: breakdown),
            ),
            child: const Text('Buka'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.pumpWidget(_host(_breakdown()));
  await tester.tap(find.text('Buka'));
  await tester.pumpAndSettle();
}

void _setSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('menampilkan tiga komponen beserta bobotnya', (tester) async {
    _setSurface(tester);
    await _openSheet(tester);

    expect(find.text('Akurasi (A) — bobot 65%'), findsOneWidget);
    expect(find.text('Konsistensi (C) — bobot 25%'), findsOneWidget);
    expect(find.text('Kecepatan (1 − Tn) — bobot 10%'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('menampilkan catatan E dan formula ringkas', (tester) async {
    _setSurface(tester);
    await _openSheet(tester);

    expect(
      find.text('E = 1 − A, kontribusinya sudah termasuk dalam Akurasi.'),
      findsOneWidget,
    );
    expect(find.text('M = 0.65·A + 0.25·C + 0.10·(1 − Tn)'), findsOneWidget);
  });

  testWidgets('menampilkan total mastery', (tester) async {
    _setSurface(tester);
    await _openSheet(tester);

    expect(find.text('Total Mastery'), findsOneWidget);
    expect(find.text('83%'), findsOneWidget);
  });

  testWidgets('tombol Tutup menutup sheet', (tester) async {
    _setSurface(tester);
    await _openSheet(tester);

    expect(find.text('Breakdown Mastery'), findsOneWidget);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    expect(find.text('Breakdown Mastery'), findsNothing);
  });

  testWidgets('setiap komponen punya label semantics', (tester) async {
    _setSurface(tester);
    final SemanticsHandle handle = tester.ensureSemantics();

    await _openSheet(tester);

    expect(find.bySemanticsLabel('Akurasi 85 persen'), findsOneWidget);
    expect(find.bySemanticsLabel('Konsistensi 90 persen'), findsOneWidget);
    expect(find.bySemanticsLabel('Kecepatan 50 persen'), findsOneWidget);
    expect(find.bySemanticsLabel('Total mastery 83 persen'), findsOneWidget);

    handle.dispose();
  });
}
