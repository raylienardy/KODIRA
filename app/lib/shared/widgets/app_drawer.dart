import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Drawer navigasi utama KODIRA.
///
/// Menggantikan `PopupMenuButton` lama di HomeScreen. Berisi empat menu:
/// Profil, Ganti Password, Ganti Kelas (belum tersedia), dan Logout.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: KodiraColors.neutral0,
      child: Column(
        children: [
          const _DrawerHeader(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    onTap: () => _navigate(context, '/profile'),
                  ),
                  _DrawerItem(
                    icon: Icons.lock_outline,
                    label: 'Ganti Password',
                    onTap: () => _navigate(context, '/change-password'),
                  ),
                  const _DrawerItem(
                    icon: Icons.school_outlined,
                    label: 'Ganti Kelas',
                    trailing: 'Segera hadir',
                    enabled: false,
                  ),
                  _DrawerItem(
                    icon: Icons.leaderboard_outlined,
                    label: 'Leaderboard',
                    onTap: () => _navigate(context, '/leaderboard'),
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline,
                    label: 'Tentang Aplikasi',
                    onTap: () => _navigate(context, '/about'),
                  ),
                  const Spacer(),
                  const Divider(height: 1, color: KodiraColors.neutral200),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    iconColor: KodiraColors.alert700,
                    labelColor: KodiraColors.alert700,
                    onTap: () => _confirmLogout(context, ref),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tutup drawer lalu buka [route] jika belum berada di route tersebut.
  void _navigate(BuildContext context, String route) {
    final GoRouter router = GoRouter.of(context);
    final String current = router.routerDelegate.currentConfiguration.uri.path;
    Navigator.of(context).pop();
    if (current == route) return;
    router.push(route);
  }

  /// Dialog konfirmasi logout, lalu panggil `AuthNotifier.logout()`.
  ///
  /// Logika dialog dipertahankan sama dengan implementasi lama di HomeScreen
  /// supaya perilaku pengguna tidak berubah.
  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: KodiraColors.alert700),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final AuthNotifier notifier = ref.read(authStateProvider.notifier);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    // Tutup drawer sebelum logout supaya tidak ada route drawer yang tertinggal
    // saat router mengalihkan pengguna ke halaman login.
    Navigator.of(context).pop();

    try {
      await notifier.logout();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal logout. Coba lagi.')),
      );
    }
  }
}

/// Bagian atas drawer: identitas pengguna yang sedang login.
class _DrawerHeader extends ConsumerWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final String rawName = user?.name.trim() ?? '';
    final String name = rawName.isEmpty ? 'Mahasiswa' : rawName;
    final String nim = (user?.nim.trim().isNotEmpty ?? false)
        ? user!.nim.trim()
        : 'NIM belum tersedia';
    final String initial = name.substring(0, 1).toUpperCase();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [KodiraColors.primary700, KodiraColors.primary500],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Text(
                  initial,
                  style: KodiraTextStyles.h2.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KODIRA',
                      style: KodiraTextStyles.overline.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KodiraTextStyles.h3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nim,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KodiraTextStyles.bodySm.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satu baris menu drawer dengan ikon, label, dan trailing opsional.
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.enabled = true,
    this.onTap,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final bool enabled;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final Color resolvedIconColor =
        iconColor ??
        (enabled ? KodiraColors.neutral700 : KodiraColors.neutral500);
    final Color resolvedLabelColor =
        labelColor ??
        (enabled ? KodiraColors.neutral900 : KodiraColors.neutral500);
    final String semanticsLabel = trailing == null
        ? label
        : '$label ($trailing)';

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: resolvedIconColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: KodiraTextStyles.bodyLg.copyWith(
                      color: resolvedLabelColor,
                      fontWeight: enabled ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: KodiraColors.neutral100,
                      borderRadius: BorderRadius.circular(KodiraRadius.full),
                    ),
                    child: Text(
                      trailing!,
                      style: KodiraTextStyles.caption.copyWith(
                        color: KodiraColors.neutral500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
