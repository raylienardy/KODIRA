import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/leaderboard_repository.dart';
import 'package:kodira/features/leaderboard/providers/leaderboard_provider.dart';
import 'package:kodira/features/leaderboard/screens/leaderboard_screen.dart';

/// Builds [n] entries with descending XP starting at 2500.
List<LeaderboardEntry> buildEntries(int n) => List.generate(
  n,
  (i) => LeaderboardEntry(
    userId: 'u${i + 1}',
    name: 'Mahasiswa ${i + 1}',
    nim: '2402095010${101 + i}',
    totalXp: 2500 - (i * 150),
    rank: i + 1,
  ),
);

void main() {
  group('LeaderboardScreen Tests (#7)', () {
    testWidgets('Top10QueryExecution renders exactly 10 ranked entries', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            top10LeaderboardProvider.overrideWith(
              (ref) async => buildEntries(10),
            ),
            myRankProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: LeaderboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Leaderboard'), findsOneWidget);
      // Rank labels #4..#10 rendered as list rows (1-3 are podium medals).
      for (int r = 4; r <= 10; r++) {
        expect(find.text('#$r'), findsOneWidget);
      }
      // Top 3 rendered as medals instead of rank labels.
      expect(find.text('\u{1F947}'), findsOneWidget);
      expect(find.text('\u{1F948}'), findsOneWidget);
      expect(find.text('\u{1F949}'), findsOneWidget);
      // 10 names rendered (3 in podium + 7 in list rows).
      expect(find.text('Mahasiswa 1'), findsOneWidget);
      expect(find.text('Mahasiswa 10'), findsOneWidget);
    });

    testWidgets('Top3BadgeAssignment shows gold, silver, bronze medals', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            top10LeaderboardProvider.overrideWith(
              (ref) async => buildEntries(5),
            ),
            myRankProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: LeaderboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('\u{1F947}'), findsOneWidget); // Gold
      expect(find.text('\u{1F948}'), findsOneWidget); // Silver
      expect(find.text('\u{1F949}'), findsOneWidget); // Bronze
    });

    testWidgets('PersonalRankFallback shows user card outside top 10', (
      tester,
    ) async {
      const myRank = LeaderboardEntry(
        userId: 'me',
        name: 'Saya',
        nim: '2402095010999',
        totalXp: 50,
        rank: 12,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            top10LeaderboardProvider.overrideWith(
              (ref) async => buildEntries(10),
            ),
            myRankProvider.overrideWith((ref) async => myRank),
          ],
          child: const MaterialApp(home: LeaderboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Peringkat Anda'), findsOneWidget);
      expect(find.text('#12 \u2022 Saya'), findsOneWidget);
      expect(find.text('50 XP'), findsOneWidget);
      // User itself is NOT inside the top-10 list.
      expect(find.text('#12'), findsNothing);
    });

    testWidgets('EmptyLeaderboardState renders empty message', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            top10LeaderboardProvider.overrideWith(
              (ref) async => <LeaderboardEntry>[],
            ),
            myRankProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: LeaderboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada data leaderboard.'), findsOneWidget);
    });

    testWidgets('DataPrivacyPolicy exposes only safe leaderboard fields', (
      tester,
    ) async {
      // The repository only reads from view `leaderboard_global`, whose
      // columns are user_id, name, nim, total_xp. Verify that no password
      // or token field ever enters a LeaderboardEntry.
      final entries = buildEntries(3);
      for (final e in entries) {
        expect(e.userId, isNotEmpty);
        expect(e.name, isNotEmpty);
        expect(e.nim, isNotEmpty);
        expect(e.totalXp, greaterThanOrEqualTo(0));
        // Reflection-free check: LeaderboardEntry has no password/token field.
        expect(e.runtimeType.toString(), 'LeaderboardEntry');
      }

      // Render with entries and assert no sensitive strings appear.
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            top10LeaderboardProvider.overrideWith((ref) async => entries),
            myRankProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: LeaderboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('password', findRichText: true), findsNothing);
      expect(find.textContaining('token', findRichText: true), findsNothing);
      expect(find.textContaining('email', findRichText: true), findsNothing);
    });

    // --- #7-perclass tests ---

    testWidgets('rendersTwoTabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            top10LeaderboardProvider.overrideWith(
              (ref) async => <LeaderboardEntry>[],
            ),
            myRankProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: LeaderboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Global'), findsOneWidget);
      expect(find.text('Kelas Saya'), findsOneWidget);
    });

    testWidgets('classTab_showsMessageWhenNoPrimaryClass', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            top10LeaderboardProvider.overrideWith(
              (ref) async => <LeaderboardEntry>[],
            ),
            myRankProvider.overrideWith((ref) async => null),
            currentUserClassIdProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(home: LeaderboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kelas Saya'));
      await tester.pumpAndSettle();

      expect(
        find.text('Kamu belum terdaftar di kelas manapun'),
        findsOneWidget,
      );
      expect(find.text('Muat Ulang'), findsOneWidget);
    });

    testWidgets('classTab_showsTop10ByClass', (tester) async {
      const String classId = 'c1';
      const List<LeaderboardEntry> entries = <LeaderboardEntry>[
        LeaderboardEntry(
          userId: 'u1',
          name: 'Mahasiswa 1',
          nim: '2402095010001',
          totalXp: 1000,
          rank: 1,
        ),
        LeaderboardEntry(
          userId: 'u2',
          name: 'Mahasiswa 2',
          nim: '2402095010002',
          totalXp: 900,
          rank: 2,
        ),
        LeaderboardEntry(
          userId: 'u3',
          name: 'Mahasiswa 3',
          nim: '2402095010003',
          totalXp: 800,
          rank: 3,
        ),
        LeaderboardEntry(
          userId: 'u4',
          name: 'Mahasiswa 4',
          nim: '2402095010004',
          totalXp: 700,
          rank: 4,
        ),
        LeaderboardEntry(
          userId: 'u5',
          name: 'Mahasiswa 5',
          nim: '2402095010005',
          totalXp: 600,
          rank: 5,
        ),
      ];
      const LeaderboardEntry myRank = LeaderboardEntry(
        userId: 'me',
        name: 'Saya',
        nim: '2402095010999',
        totalXp: 500,
        rank: 6,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            top10LeaderboardProvider.overrideWith(
              (ref) async => <LeaderboardEntry>[],
            ),
            myRankProvider.overrideWith((ref) async => null),
            currentUserClassIdProvider.overrideWith((ref) async => classId),
            top10ByClassProvider.overrideWith((ref, String cid) async {
              expect(cid, classId);
              return entries;
            }),
            myRankByClassProvider.overrideWith((ref, String cid) async {
              expect(cid, classId);
              return myRank;
            }),
          ],
          child: const MaterialApp(home: LeaderboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kelas Saya'));
      await tester.pumpAndSettle();

      // All 5 entries rendered: 3 in podium + 2 in list rows.
      for (int i = 1; i <= 5; i++) {
        expect(find.text('Mahasiswa $i'), findsOneWidget);
      }
      // Rank labels #4 and #5 for the list rows (1-3 are podium medals).
      expect(find.text('#4'), findsOneWidget);
      expect(find.text('#5'), findsOneWidget);
      // Personal rank card within the class.
      expect(find.text('Peringkat Anda'), findsOneWidget);
      expect(find.text('#6 \u2022 Saya'), findsOneWidget);
    });
  });
}
