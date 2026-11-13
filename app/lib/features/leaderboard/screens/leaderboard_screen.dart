import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/logic/title_logic.dart';
import '../../../data/repositories/leaderboard_repository.dart';
import '../providers/leaderboard_provider.dart';

/// Halaman Leaderboard KODIRA dengan 2 tab (#7-perclass):
/// - "Global"   : peringkat semua pengguna (view `leaderboard_global`).
/// - "Kelas Saya": peringkat hanya di dalam kelas user aktif
///   (view `leaderboard_by_class`, filter `primary_class_id`).
///
/// Kedua tab menyajikan peringkat 1 s/d 10 dengan highlight Top 3
/// (Medali Emas, Perak, Perunggu) dan kartu posisi personal di bawah.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: KodiraColors.neutral100,
        appBar: AppBar(
          backgroundColor: KodiraColors.neutral0,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: KodiraColors.neutral900,
          title: Text(
            'Leaderboard',
            style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
          ),
          bottom: const TabBar(
            labelColor: KodiraColors.primary700,
            unselectedLabelColor: KodiraColors.neutral500,
            indicatorColor: KodiraColors.primary700,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            tabs: <Tab>[
              Tab(text: 'Global'),
              Tab(text: 'Kelas Saya'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[_GlobalLeaderboardTab(), _ClassLeaderboardTab()],
        ),
      ),
    );
  }
}

/// Tab "Global": konten leaderboard lama (semua user).
class _GlobalLeaderboardTab extends ConsumerWidget {
  const _GlobalLeaderboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top10Async = ref.watch(top10LeaderboardProvider);
    final myRankAsync = ref.watch(myRankProvider);

    return top10Async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: KodiraColors.primary700),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(KodiraSpacing.s6),
          child: Text(
            'Gagal memuat data leaderboard. Silakan coba lagi.',
            textAlign: TextAlign.center,
            style: KodiraTextStyles.body.copyWith(color: KodiraColors.alert700),
          ),
        ),
      ),
      data: (entries) => _LeaderboardContent(
        entries: entries,
        myRankAsync: myRankAsync,
        onRefresh: () async {
          ref.invalidate(top10LeaderboardProvider);
          ref.invalidate(myRankProvider);
        },
      ),
    );
  }
}

/// Tab "Kelas Saya": leaderboard yang difilter berdasarkan kelas user aktif.
///
/// Fallback: jika user belum punya `primary_class_id`, tampilkan pesan
/// "Kamu belum terdaftar di kelas manapun" dengan tombol "Muat Ulang".
class _ClassLeaderboardTab extends ConsumerWidget {
  const _ClassLeaderboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classIdAsync = ref.watch(currentUserClassIdProvider);

    return classIdAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: KodiraColors.primary700),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(KodiraSpacing.s6),
          child: Text(
            'Gagal memuat data kelas. Silakan coba lagi.',
            textAlign: TextAlign.center,
            style: KodiraTextStyles.body.copyWith(color: KodiraColors.alert700),
          ),
        ),
      ),
      data: (String? classId) {
        if (classId == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(KodiraSpacing.s6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.groups_2_outlined,
                    size: 48,
                    color: KodiraColors.neutral300,
                  ),
                  const SizedBox(height: KodiraSpacing.s3),
                  Text(
                    'Kamu belum terdaftar di kelas manapun',
                    textAlign: TextAlign.center,
                    style: KodiraTextStyles.body.copyWith(
                      color: KodiraColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: KodiraSpacing.s4),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(currentUserClassIdProvider),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Muat Ulang'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KodiraColors.primary700,
                      side: const BorderSide(color: KodiraColors.primary700),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final top10Async = ref.watch(top10ByClassProvider(classId));
        final myRankAsync = ref.watch(myRankByClassProvider(classId));

        return top10Async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: KodiraColors.primary700),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(KodiraSpacing.s6),
              child: Text(
                'Gagal memuat data leaderboard. Silakan coba lagi.',
                textAlign: TextAlign.center,
                style: KodiraTextStyles.body.copyWith(
                  color: KodiraColors.alert700,
                ),
              ),
            ),
          ),
          data: (entries) => _LeaderboardContent(
            entries: entries,
            myRankAsync: myRankAsync,
            onRefresh: () async {
              ref.invalidate(currentUserClassIdProvider);
              ref.invalidate(top10ByClassProvider(classId));
              ref.invalidate(myRankByClassProvider(classId));
            },
          ),
        );
      },
    );
  }
}

/// Konten leaderboard yang dipakai bersama oleh kedua tab:
/// Top 3 podium + list rank 4-10 + kartu posisi personal di bawah.
class _LeaderboardContent extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final AsyncValue<LeaderboardEntry?> myRankAsync;
  final Future<void> Function() onRefresh;

  const _LeaderboardContent({
    required this.entries,
    required this.myRankAsync,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(KodiraSpacing.s6),
          child: Text(
            'Belum ada data leaderboard.',
            style: KodiraTextStyles.body.copyWith(
              color: KodiraColors.neutral500,
            ),
          ),
        ),
      );
    }

    final top3 = entries.take(3).toList();
    final rest = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntry>[];

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: KodiraColors.primary700,
            onRefresh: onRefresh,
            child: ListView(
              padding: const EdgeInsets.all(KodiraSpacing.s4),
              children: [
                // Top 3 Podium
                if (top3.isNotEmpty) _Top3PodiumSection(top3: top3),
                const SizedBox(height: KodiraSpacing.s4),
                // Rank 4-10 List
                if (rest.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rest.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: KodiraSpacing.s2),
                    itemBuilder: (context, index) {
                      final entry = rest[index];
                      return _LeaderboardRowCard(entry: entry);
                    },
                  ),
              ],
            ),
          ),
        ),
        // Fixed Bottom Personal Rank Card
        myRankAsync.when(
          data: (myRank) {
            if (myRank == null) return const SizedBox.shrink();
            return _PersonalRankBottomCard(entry: myRank);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Widget section untuk menampilkan Top 3 pengguna dalam format podium.
class _Top3PodiumSection extends StatelessWidget {
  final List<LeaderboardEntry> top3;

  const _Top3PodiumSection({required this.top3});

  @override
  Widget build(BuildContext context) {
    // Top 3 order for podium display: [2nd, 1st, 3rd]
    final LeaderboardEntry? first = top3.isNotEmpty ? top3[0] : null;
    final LeaderboardEntry? second = top3.length > 1 ? top3[1] : null;
    final LeaderboardEntry? third = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.all(KodiraSpacing.s4),
      decoration: BoxDecoration(
        color: KodiraColors.neutral0,
        borderRadius: BorderRadius.circular(KodiraRadius.lg),
        boxShadow: KodiraShadows.elevation1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null)
            Expanded(
              child: _PodiumCard(
                entry: second,
                medal: '🥈',
                color: const Color(0xFFC0C0C0),
                height: 110,
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: KodiraSpacing.s2),
          if (first != null)
            Expanded(
              child: _PodiumCard(
                entry: first,
                medal: '🥇',
                color: KodiraColors.reward500,
                height: 130,
                isFirst: true,
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: KodiraSpacing.s2),
          if (third != null)
            Expanded(
              child: _PodiumCard(
                entry: third,
                medal: '🥉',
                color: const Color(0xFFCD7F32),
                height: 95,
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }
}

/// Kartu individu untuk Top 3 podium.
class _PodiumCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final String medal;
  final Color color;
  final double height;
  final bool isFirst;

  const _PodiumCard({
    required this.entry,
    required this.medal,
    required this.color,
    required this.height,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(KodiraSpacing.s2),
      decoration: BoxDecoration(
        color: isFirst ? KodiraColors.primary100 : KodiraColors.neutral100,
        borderRadius: BorderRadius.circular(KodiraRadius.md),
        border: Border.all(
          color: isFirst ? KodiraColors.primary500 : KodiraColors.neutral200,
          width: isFirst ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(medal, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: KodiraTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: KodiraColors.neutral900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${entry.totalXp} XP',
            style: KodiraTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: KodiraColors.primary700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris item untuk peringkat 4-10.
class _LeaderboardRowCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardRowCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KodiraSpacing.s4,
        vertical: KodiraSpacing.s3,
      ),
      decoration: BoxDecoration(
        color: KodiraColors.neutral0,
        borderRadius: BorderRadius.circular(KodiraRadius.md),
        boxShadow: KodiraShadows.elevation1,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${entry.rank}',
              style: KodiraTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: KodiraColors.neutral500,
              ),
            ),
          ),
          const SizedBox(width: KodiraSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KodiraTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: KodiraColors.neutral900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _TitleChip(title: TitleLogic.fromTotalXp(entry.totalXp)),
                  ],
                ),
                Text(
                  entry.nim,
                  style: KodiraTextStyles.caption.copyWith(
                    color: KodiraColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.totalXp} XP',
            style: KodiraTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: KodiraColors.primary700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget chip kecil untuk menampilkan gelar user.
class _TitleChip extends StatelessWidget {
  final UserTitle title;

  const _TitleChip({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: KodiraColors.primary100,
        borderRadius: BorderRadius.circular(KodiraRadius.full),
      ),
      child: Text(
        '${TitleLogic.emoji(title)} ${TitleLogic.label(title)}',
        style: KodiraTextStyles.caption.copyWith(
          color: KodiraColors.primary700,
          fontWeight: FontWeight.w600,
          fontSize: 10, // Sedikit lebih kecil supaya pas di baris
        ),
      ),
    );
  }
}

/// Kartu bagian bawah untuk menampilkan posisi peringkat pengguna aktif.
class _PersonalRankBottomCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _PersonalRankBottomCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: KodiraSpacing.s5,
        vertical: KodiraSpacing.s4,
      ),
      decoration: const BoxDecoration(
        color: KodiraColors.primary700,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(KodiraRadius.lg),
          topRight: Radius.circular(KodiraRadius.lg),
        ),
        boxShadow: KodiraShadows.elevation3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_circle_outlined,
                color: KodiraColors.neutral0,
                size: 24,
              ),
              const SizedBox(width: KodiraSpacing.s3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Peringkat Anda',
                    style: KodiraTextStyles.caption.copyWith(
                      color: KodiraColors.neutral100,
                    ),
                  ),
                  Text(
                    '#${entry.rank} • ${entry.name}',
                    style: KodiraTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: KodiraColors.neutral0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KodiraSpacing.s3,
              vertical: KodiraSpacing.s1,
            ),
            decoration: BoxDecoration(
              color: KodiraColors.reward500,
              borderRadius: BorderRadius.circular(KodiraRadius.full),
            ),
            child: Text(
              '${entry.totalXp} XP',
              style: KodiraTextStyles.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                color: KodiraColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
