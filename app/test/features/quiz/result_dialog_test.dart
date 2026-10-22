import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/features/quiz/widgets/result_dialog.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

ResultDialog _dialog({
  int score = 3,
  int total = 3,
  int levelId = 3,
  int attempts = 1,
  int xpEarned = 100,
  int xpThisAttempt = 100,
  bool isFirstCompletion = false,
  bool isLastLevel = false,
  VoidCallback? onPrimary,
  VoidCallback? onSecondary,
}) {
  return ResultDialog(
    score: score,
    total: total,
    xpEarned: xpEarned,
    xpThisAttempt: xpThisAttempt,
    mastery: total == 0 ? 0 : score / total,
    levelId: levelId,
    attempts: attempts,
    isFirstCompletion: isFirstCompletion,
    isLastLevel: isLastLevel,
    onPrimary: onPrimary ?? () {},
    onSecondary: onSecondary,
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('skor penuh menampilkan Lulus dan tombol level berikutnya', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(_dialog(score: 3, total: 3, levelId: 3)));

    expect(find.text('Lulus!'), findsOneWidget);
    expect(find.text('Lanjut ke Level 4'), findsOneWidget);
    expect(find.text('Kembali ke Home'), findsOneWidget);
  });

  testWidgets('skor 2 dari 3 menampilkan Hampir dan tombol remedial', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(_dialog(score: 2, total: 3)));

    expect(find.text('Hampir!'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(find.text('Review Materi'), findsOneWidget);
    expect(find.text('Kembali ke Home'), findsNothing);
  });

  testWidgets('skor 1 dari 3 menampilkan Belum Lulus', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(_dialog(score: 1, total: 3)));

    expect(find.text('Belum Lulus'), findsOneWidget);
    expect(find.text('Review Materi'), findsOneWidget);
  });

  testWidgets('level terakhir hanya menampilkan tombol Kembali ke Home', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        _dialog(
          score: 3,
          total: 3,
          levelId: 50,
          isLastLevel: true,
          attempts: 2,
        ),
      ),
    );

    expect(find.text('Kembali ke Home'), findsOneWidget);
    expect(find.text('Lanjut ke Level 51'), findsNothing);
    expect(find.text('Review Materi'), findsNothing);
  });

  testWidgets('menekan tombol primary memanggil callback', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    var primaryCalls = 0;
    await tester.pumpWidget(
      _wrap(_dialog(score: 3, total: 3, onPrimary: () => primaryCalls++)),
    );

    await tester.tap(find.text('Lanjut ke Level 4'));
    await tester.pump();

    expect(primaryCalls, 1);
  });

  testWidgets('menekan tombol secondary memanggil callback', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    var secondaryCalls = 0;
    await tester.pumpWidget(
      _wrap(_dialog(score: 2, total: 3, onSecondary: () => secondaryCalls++)),
    );

    await tester.tap(find.text('Review Materi'));
    await tester.pump();

    expect(secondaryCalls, 1);
  });

  testWidgets('penyelesaian pertama menampilkan animasi lalu hasil', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(_dialog(score: 3, total: 3, isFirstCompletion: true)),
    );

    expect(find.text('Level 3 terbuka!'), findsOneWidget);
    expect(find.text('Lulus!'), findsNothing);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(find.text('Level 3 terbuka!'), findsNothing);
    expect(find.text('Lulus!'), findsOneWidget);
  });
}
