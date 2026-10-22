import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Tampilan data kosong standar KODIRA.
///
/// Menampilkan ikon, judul, subjudul opsional, dan tombol aksi opsional.
class KodiraEmptyWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const KodiraEmptyWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool showAction = onAction != null && actionLabel != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: subtitle == null ? title : '$title. $subtitle',
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    Icon(icon, size: 64, color: KodiraColors.neutral300),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: KodiraTextStyles.bodyLg.copyWith(
                        color: KodiraColors.neutral900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: KodiraTextStyles.body.copyWith(
                          color: KodiraColors.neutral500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (showAction) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KodiraColors.primary700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KodiraRadius.lg),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
