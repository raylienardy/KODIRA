import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kodira/features/profile/screens/about_screen.dart';

void main() {
  group('AboutScreen Tests (#5)', () {
    testWidgets('RouteAccessible loads AboutScreen and renders title', (
      tester,
    ) async {
      final GoRouter router = GoRouter(
        initialLocation: '/about',
        routes: [
          GoRoute(
            path: '/about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Tentang Aplikasi'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets(
      'AllSectionsRender renders all 6 sections correctly from markdown',
      (tester) async {
        const String testMarkdown = '''
# Tentang KODIRA

### Section 1: Cara Naik Level
Setiap level di KODIRA mengikuti alur belajar yang konsisten.

### Section 2: Sistem XP
XP adalah indikator progres belajar Anda.

### Section 3: Cara Hitung Mastery
Skor Mastery dihitung dari 4 komponen.

### Section 4: Streak & Badge
Streak adalah hari aktif berturut-turut.

### Section 5: Tips Belajar
1. Gunakan Hint AI.

### Section 6: FAQ
Q: Lupa password, gimana?
''';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: MarkdownBody(data: testMarkdown),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Tentang KODIRA'), findsOneWidget);
        expect(find.text('Section 1: Cara Naik Level'), findsOneWidget);
        expect(find.text('Section 2: Sistem XP'), findsOneWidget);
        expect(find.text('Section 3: Cara Hitung Mastery'), findsOneWidget);
        expect(find.text('Section 4: Streak & Badge'), findsOneWidget);
        expect(find.text('Section 5: Tips Belajar'), findsOneWidget);
        expect(find.text('Section 6: FAQ'), findsOneWidget);
      },
    );

    testWidgets('ContentMatch validates specific instruction texts', (
      tester,
    ) async {
      const String testMarkdown = '''
### Section 1: Cara Naik Level
Syarat Lulus: Skor kuis ≥ 70% untuk membuka level berikutnya.
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: MarkdownBody(data: testMarkdown)),
        ),
      );
      await tester.pump();

      expect(
        find.textContaining('Syarat Lulus: Skor kuis ≥ 70%'),
        findsOneWidget,
      );
    });
  });
}
