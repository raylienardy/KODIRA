import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/logic/xp_logic.dart';
import 'package:kodira/data/models/level_model.dart';
import 'package:kodira/features/home/widgets/level_section.dart';

void main() {
  final mudahLevels = List.generate(
    3,
    (i) => LevelModel(
      id: i + 1,
      levelNumber: i + 1,
      title: 'Level ${i + 1}',
      topic: 'Dasar',
      language: 'cpp',
      createdAt: DateTime(2026, 1, 1),
    ),
  );

  Widget buildDummyCard(LevelModel level) => Card(child: Text(level.title));

  testWidgets('rendersHeaderWithLabel', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelSection(
            tier: LevelTier.mudah,
            levels: mudahLevels,
            levelBuilder: buildDummyCard,
            initiallyExpanded: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mudah'), findsOneWidget);
    expect(find.text('(1-15)'), findsOneWidget);
  });

  testWidgets('rendersAllLevelsWhenExpanded', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelSection(
            tier: LevelTier.mudah,
            levels: mudahLevels,
            levelBuilder: buildDummyCard,
            initiallyExpanded: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('Level 3'), findsOneWidget);
  });

  testWidgets('collapsesWhenTapped', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelSection(
            tier: LevelTier.mudah,
            levels: mudahLevels,
            levelBuilder: buildDummyCard,
            initiallyExpanded: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Level 1'), findsOneWidget);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Level 1'), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });

  testWidgets('expandsAgainWhenTapped', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelSection(
            tier: LevelTier.mudah,
            levels: mudahLevels,
            levelBuilder: buildDummyCard,
            initiallyExpanded: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Level 1'), findsNothing);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Level 1'), findsOneWidget);
  });

  testWidgets('initiallyCollapsedStaysCollapsed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelSection(
            tier: LevelTier.mudah,
            levels: mudahLevels,
            levelBuilder: buildDummyCard,
            initiallyExpanded: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Level 1'), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });
}
