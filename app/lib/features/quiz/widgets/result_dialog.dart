import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import 'level_up_animation.dart';
import 'mastery_bar.dart';
import 'result_logic.dart';

/// Dialog hasil kuis: tier (<40% / 40–69% / ≥70%), skor detail, mastery bar,
/// pesan XP yang sadar percobaan ulang, dan tombol adaptif.
///
/// Bila [isFirstCompletion] bernilai true dan hasilnya lulus, dialog
/// menampilkan animasi level-up lebih dulu, lalu konten hasil.
class ResultDialog extends StatefulWidget {
  final int score;
  final int total;
  final int xpEarned;
  final int xpThisAttempt;
  final double mastery;
  final int levelId;
  final int attempts;
  final bool isFirstCompletion;
  final bool isLastLevel;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;

  const ResultDialog({
    super.key,
    required this.score,
    required this.total,
    required this.xpEarned,
    required this.xpThisAttempt,
    required this.mastery,
    required this.levelId,
    required this.attempts,
    required this.isFirstCompletion,
    required this.isLastLevel,
    required this.onPrimary,
    this.onSecondary,
  });

  @override
  State<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog> {
  late bool _showAnimation;

  @override
  void initState() {
    super.initState();
    final ResultTier tier = ResultLogic.computeTier(widget.score, widget.total);
    _showAnimation = widget.isFirstCompletion && tier == ResultTier.pass;
  }

  @override
  Widget build(BuildContext context) {
    if (_showAnimation) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: KodiraColors.neutral0,
            borderRadius: BorderRadius.circular(KodiraRadius.xl2),
            boxShadow: KodiraShadows.elevation4,
          ),
          child: LevelUpAnimation(
            levelNumber: widget.levelId,
            onComplete: () => setState(() => _showAnimation = false),
          ),
        ),
      );
    }

    final ResultTier tier = ResultLogic.computeTier(widget.score, widget.total);
    final String title = ResultLogic.titleFor(tier);
    final String subtitle = ResultLogic.subtitleFor(tier);
    final String primaryLabel = ResultLogic.primaryLabelFor(
      tier: tier,
      levelId: widget.levelId,
      isLastLevel: widget.isLastLevel,
    );
    final String? secondaryLabel = ResultLogic.secondaryLabelFor(
      tier: tier,
      isLastLevel: widget.isLastLevel,
    );
    final String xpMessage = ResultLogic.xpMessageFor(
      xpEarned: widget.xpEarned,
      xpThisAttempt: widget.xpThisAttempt,
      isFirstCompletion: widget.isFirstCompletion,
      attempts: widget.attempts,
    );
    final Color accent = ResultLogic.masteryColorFor(tier);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: KodiraColors.neutral0,
          borderRadius: BorderRadius.circular(KodiraRadius.xl2),
          boxShadow: KodiraShadows.elevation4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              tier == ResultTier.pass
                  ? Icons.check_circle
                  : tier == ResultTier.remedial
                  ? Icons.trending_up
                  : Icons.school,
              size: 64,
              color: accent,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: KodiraTextStyles.h2.copyWith(
                color: KodiraColors.neutral900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: KodiraTextStyles.body.copyWith(
                color: KodiraColors.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Semantics(
              label: 'Skor ${widget.score} dari ${widget.total} soal benar',
              excludeSemantics: true,
              child: Text(
                '${widget.score} / ${widget.total}',
                style: KodiraTextStyles.display.copyWith(color: accent),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            MasteryBar(mastery: widget.mastery, color: accent),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: KodiraColors.reward100,
                borderRadius: BorderRadius.circular(KodiraRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bolt,
                    color: KodiraColors.reward700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      xpMessage,
                      style: KodiraTextStyles.body.copyWith(
                        color: KodiraColors.reward700,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: widget.onPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KodiraColors.primary700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KodiraRadius.lg),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(primaryLabel),
              ),
            ),
            if (secondaryLabel != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: TextButton(
                  onPressed: widget.onSecondary,
                  style: TextButton.styleFrom(
                    foregroundColor: KodiraColors.neutral700,
                  ),
                  child: Text(
                    secondaryLabel,
                    style: KodiraTextStyles.body.copyWith(
                      color: KodiraColors.neutral700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
