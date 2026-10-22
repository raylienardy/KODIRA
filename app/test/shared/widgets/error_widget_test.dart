import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/core/errors/error_type.dart';
import 'package:kodira/shared/widgets/error_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('menampilkan pesan error sesuai ErrorType', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const KodiraErrorWidget(error: ErrorType.network)),
    );

    expect(find.text(ErrorType.network.userMessage), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('menampilkan tombol retry untuk error yang bisa diulang', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(KodiraErrorWidget(error: ErrorType.timeout, onRetry: () {})),
    );

    expect(find.text('Coba Lagi'), findsOneWidget);
  });

  testWidgets('tidak menampilkan retry untuk error non-retryable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(KodiraErrorWidget(error: ErrorType.unauthorized, onRetry: () {})),
    );

    expect(find.text('Coba Lagi'), findsNothing);
  });

  testWidgets('tidak menampilkan retry saat onRetry null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const KodiraErrorWidget(error: ErrorType.server)),
    );

    expect(find.text('Coba Lagi'), findsNothing);
  });

  testWidgets('menekan tombol retry memanggil callback', (
    WidgetTester tester,
  ) async {
    var called = 0;

    await tester.pumpWidget(
      _wrap(
        KodiraErrorWidget(error: ErrorType.network, onRetry: () => called++),
      ),
    );

    await tester.tap(find.text('Coba Lagi'));
    await tester.pump();

    expect(called, 1);
  });
}
