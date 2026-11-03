import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/logic/xp_logic.dart';
import 'package:kodira/features/adaptive/models/mastery_breakdown.dart';
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
  MasteryBreakdown? breakdown,
  XpResult? xpResult,
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
    breakdown: breakdown,
    xpResult: xpResult,
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

  testWidgets('tap mastery bar membuka breakdown sheet saat data tersedia', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final breakdown = MasteryBreakdown(
      accuracy: 1.0,
      consistency: 0.5,
      timeNorm: 0.0,
      total: 0.875,
    );

    await tester.pumpWidget(_wrap(_dialog(breakdown: breakdown)));
    await tester.tap(find.text('Mastery'));
    await tester.pumpAndSettle();

    expect(find.text('Breakdown Mastery'), findsOneWidget);
  });

  testWidgets('mastery bar tidak tappable saat breakdown null', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(_dialog()));
    await tester.tap(find.text('Mastery'));
    await tester.pumpAndSettle();

    expect(find.text('Breakdown Mastery'), findsNothing);
  });

  testWidgets('xpResult perbaikan menampilkan XP percobaan', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const XpResult xpResult = XpResult(
      baseXp: 100,
      multiplier: 1.5,
      attemptXp: 150,
      previousXp: 50,
      finalXp: 150,
      isPass: true,
      isRemedial: false,
      isFail: false,
    );

    await tester.pumpWidget(_wrap(_dialog(xpResult: xpResult)));

    expect(find.text('Kamu mendapat 150 XP'), findsOneWidget);
  });

  testWidgets('xpResult tanpa perbaikan menampilkan XP maksimal', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const XpResult xpResult = XpResult(
      baseXp: 50,
      multiplier: 1.0,
      attemptXp: 50,
      previousXp: 200,
      finalXp: 200,
      isPass: true,
      isRemedial: false,
      isFail: false,
    );

    await tester.pumpWidget(_wrap(_dialog(xpResult: xpResult)));

    expect(find.text('XP kamu sudah maksimal (200)'), findsOneWidget);
  });

  testWidgets('xpResult gagal menampilkan pesan remedial', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const XpResult xpResult = XpResult(
      baseXp: 0,
      multiplier: 1.0,
      attemptXp: 0,
      previousXp: 0,
      finalXp: 0,
      isPass: false,
      isRemedial: false,
      isFail: true,
    );

    await tester.pumpWidget(_wrap(_dialog(xpResult: xpResult)));

    expect(find.text('Belum dapat XP — coba remedial'), findsOneWidget);
  });

  testWidgets('xpResult null memakai pesan XP lama sebagai fallback', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(_dialog()));

    expect(
      find.text('XP sudah maksimal (100). Percobaan ke-1.'),
      findsOneWidget,
    );
  });
}
