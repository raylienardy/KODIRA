import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/features/profile/providers/profile_provider.dart';
import 'package:kodira/features/profile/widgets/mastery_section.dart';

Widget _host(Map<String, double> mastery) {
  return ProviderScope(
    overrides: <Override>[
      masteryByTopicProvider.overrideWith((ref) async => mastery),
    ],
    child: const MaterialApp(home: Scaffold(body: MasterySection())),
  );
}

void _setSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('tap baris mastery membuka concept sheet', (tester) async {
    _setSurface(tester);
    await tester.pumpWidget(_host(<String, double>{'Dasar C++': 0.8}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dasar C++'));
    await tester.pumpAndSettle();

    expect(find.text('Apa itu Mastery?'), findsOneWidget);
  });

  testWidgets('baris mastery nol tidak tappable', (tester) async {
    _setSurface(tester);
    await tester.pumpWidget(_host(<String, double>{'Dasar C++': 0.0}));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dasar C++'));
    await tester.pumpAndSettle();

    expect(find.text('Apa itu Mastery?'), findsNothing);
  });

  testWidgets('baris mastery punya label semantics yang sesuai', (
    tester,
  ) async {
    _setSurface(tester);
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(_host(<String, double>{'Dasar C++': 0.8}));
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('Buka info mastery untuk topik Dasar C++'),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('baris mastery nol memakai label nilai, bukan label buka', (
    tester,
  ) async {
    _setSurface(tester);
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(_host(<String, double>{'Dasar C++': 0.0}));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Dasar C++: 0% mastery'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Buka info mastery untuk topik Dasar C++'),
      findsNothing,
    );

    handle.dispose();
  });
}
