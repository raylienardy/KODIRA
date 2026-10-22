import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/shared/widgets/loading_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('menampilkan spinner dan pesan saat message diberikan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const KodiraLoadingWidget(message: 'Memuat level')),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Memuat level'), findsOneWidget);
  });

  testWidgets('tetap menampilkan spinner tanpa message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap(const KodiraLoadingWidget()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Memuat data'), findsNothing);
  });

  testWidgets('punya label semantics default saat message null', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(const KodiraLoadingWidget()));

    expect(find.bySemanticsLabel('Memuat data'), findsAtLeastNWidgets(1));

    handle.dispose();
  });

  testWidgets('punya label semantics sesuai message', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(const KodiraLoadingWidget(message: 'Memuat materi')),
    );

    expect(find.bySemanticsLabel('Memuat materi'), findsAtLeastNWidgets(1));

    handle.dispose();
  });
}
