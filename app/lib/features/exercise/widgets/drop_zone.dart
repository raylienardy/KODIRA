import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import 'drag_token.dart';

/// Area susun tempat token diurutkan.
///
/// Token dapat diubah urutannya dengan long-press lalu drag, atau
/// dikembalikan ke token pool lewat tombol tutup.
class DropZone extends StatelessWidget {
  final List<DragTokenData> tokens;
  final ReorderCallback onReorderItem;
  final ValueChanged<String> onRemove;

  const DropZone({
    required this.tokens,
    required this.onReorderItem,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 148),
        decoration: BoxDecoration(
          color: KodiraColors.neutral0,
          borderRadius: BorderRadius.circular(KodiraRadius.md),
        ),
        child: CustomPaint(
          painter: const _DashedBorderPainter(
            color: KodiraColors.neutral300,
            radius: KodiraRadius.md,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: tokens.isEmpty ? const _EmptyDropZone() : _buildTokenList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      buildDefaultDragHandles: false,
      itemCount: tokens.length,
      onReorderItem: onReorderItem,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + (0.02 * animation.value),
              child: Material(
                color: Colors.transparent,
                elevation: 8 * animation.value,
                shadowColor: KodiraColors.neutral900.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(KodiraRadius.sm),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final token = tokens[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey('drop-${token.id}'),
          index: index,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: index == tokens.length - 1 ? 0 : 8,
            ),
            child: _DropToken(
              token: token,
              index: index,
              onRemove: () => onRemove(token.id),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyDropZone extends StatelessWidget {
  const _EmptyDropZone();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      label:
          'Area susun kosong. Ketuk token di pilihan token untuk menambahkan.',
      child: SizedBox(
        height: 132,
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: KodiraColors.neutral100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.touch_app_outlined,
                    size: 22,
                    color: KodiraColors.neutral500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Susun token di sini sesuai urutan',
                  textAlign: TextAlign.center,
                  style: KodiraTextStyles.bodySm.copyWith(
                    color: KodiraColors.neutral700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ketuk token di bawah untuk mulai.',
                  textAlign: TextAlign.center,
                  style: KodiraTextStyles.caption.copyWith(
                    color: KodiraColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropToken extends StatelessWidget {
  final DragTokenData token;
  final int index;
  final VoidCallback onRemove;

  const _DropToken({
    required this.token,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Material(
          color: KodiraColors.primary100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KodiraRadius.sm),
            side: const BorderSide(color: KodiraColors.primary700),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: KodiraColors.primary700,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: KodiraTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    container: true,
                    label: 'Posisi ${index + 1}: ${token.text}',
                    child: ExcludeSemantics(
                      child: Text(
                        token.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KodiraTextStyles.code.copyWith(
                          color: KodiraColors.primary900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.drag_indicator,
                  size: 18,
                  color: KodiraColors.primary700,
                ),
                Semantics(
                  container: true,
                  button: true,
                  label: 'Kembalikan token ${token.text} ke pilihan token',
                  onTap: onRemove,
                  child: ExcludeSemantics(
                    child: IconButton(
                      onPressed: onRemove,
                      tooltip: 'Kembalikan token',
                      icon: const Icon(Icons.close, size: 18),
                      color: KodiraColors.primary900,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;

    final rect = (Offset.zero & size).deflate(1);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    const dashLength = 6.0;
    const gapLength = 4.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
