import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/level_provider.dart';

/// Bagian atas layar Profil: avatar, nama, NIM, dan jumlah badge.
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final badgeCount = ref
        .watch(badgeCountProvider)
        .maybeWhen(data: (value) => value, orElse: () => 0);

    final String rawName = user?.name.trim() ?? '';
    final String name = rawName.isEmpty ? 'Mahasiswa' : rawName;
    final String nim = (user?.nim.trim().isNotEmpty ?? false)
        ? user!.nim.trim()
        : 'NIM belum tersedia';
    final String initial = name.substring(0, 1).toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: KodiraColors.neutral100,
        borderRadius: BorderRadius.circular(KodiraRadius.lg),
      ),
      child: Column(
        children: [
          Semantics(
            label: 'Avatar $name',
            image: true,
            child: ExcludeSemantics(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [KodiraColors.primary700, KodiraColors.success500],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: KodiraTextStyles.display.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: '$name, NIM $nim',
            child: ExcludeSemantics(
              child: Column(
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: KodiraTextStyles.h2.copyWith(
                      color: KodiraColors.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nim,
                    textAlign: TextAlign.center,
                    style: KodiraTextStyles.body.copyWith(
                      color: KodiraColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            label: 'Badge terkumpul: $badgeCount',
            child: ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: KodiraColors.primary100,
                  borderRadius: BorderRadius.circular(KodiraRadius.full),
                ),
                child: Text(
                  '🎖️ $badgeCount Badge',
                  style: KodiraTextStyles.caption.copyWith(
                    color: KodiraColors.primary900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
