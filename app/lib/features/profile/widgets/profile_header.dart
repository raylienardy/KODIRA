import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/logic/title_logic.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/level_provider.dart';

/// Bagian atas layar Profil: avatar, nama, NIM, gelar, dan jumlah badge.
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key, this.isTeacher = false});
  final bool isTeacher;

  Future<void> _showChangeNimDialog(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authStateProvider).user;
    final currentNim = user?.nim ?? '';
    final controller = TextEditingController(text: currentNim);
    final isTeacherUser = user?.role == 'teacher';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(isTeacherUser ? 'Ganti NIDN' : 'Ganti NIM'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: isTeacherUser ? 'NIDN Baru' : 'NIM Baru',
                hintText: isTeacherUser ? '10 digit' : '12-13 digit',
                counterText: '',
              ),
              keyboardType: TextInputType.number,
              maxLength: 13,
              style: const TextStyle(color: KodiraColors.neutral900),
            ),
            const SizedBox(height: 8),
            Text(
              'Perubahan NIM akan merubah email login Anda.',
              style: KodiraTextStyles.caption.copyWith(
                color: KodiraColors.neutral500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: KodiraColors.primary700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) {
      final newNim = controller.text.trim();
      if (newNim.isEmpty) return;

      try {
        await ref.read(authRepositoryProvider).updateNim(newNim: newNim);
        await ref.read(authStateProvider.notifier).refreshUser();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('NIM berhasil diupdate')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal update NIM: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final badgeCount = ref
        .watch(badgeCountProvider)
        .maybeWhen(data: (value) => value, orElse: () => 0);
    final totalXpAsync = ref.watch(totalXpProvider);
    final int totalXp = totalXpAsync.maybeWhen(
      data: (value) => value,
      orElse: () => 0,
    );
    final UserTitle title = TitleLogic.fromTotalXp(totalXp);

    final String rawName = user?.name.trim() ?? 'User';
    final String initial = rawName.isNotEmpty ? rawName[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: const BoxDecoration(
        color: KodiraColors.neutral0,
        border: Border(bottom: BorderSide(color: KodiraColors.neutral200)),
      ),
      child: Column(
        children: [
          // Avatar dengan inisial nama.
          CircleAvatar(
            radius: 40,
            backgroundColor: KodiraColors.primary100,
            child: Text(
              initial,
              style: KodiraTextStyles.h1.copyWith(
                color: KodiraColors.primary700,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nama User
          Text(
            rawName,
            style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // NIM User & Aksi Ganti
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user?.nim ?? '-',
                style: KodiraTextStyles.body.copyWith(
                  color: KodiraColors.neutral500,
                ),
              ),
              if (!isTeacher) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => _showChangeNimDialog(context, ref),
                  icon: const Icon(Icons.edit, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: KodiraColors.primary700,
                  tooltip: 'Ganti NIM',
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Badge Count & Title
          if (!isTeacher) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Container(
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: KodiraColors.neutral0,
                    borderRadius: BorderRadius.circular(KodiraRadius.full),
                    border: Border.all(color: KodiraColors.neutral200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        TitleLogic.emoji(title),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        TitleLogic.label(title),
                        style: KodiraTextStyles.caption.copyWith(
                          color: KodiraColors.primary700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
