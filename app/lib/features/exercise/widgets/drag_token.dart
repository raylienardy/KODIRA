import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Data satu token yang berasal dari payload exercise.
class DragTokenData {
  final String id;
  final String text;

  const DragTokenData({required this.id, required this.text});
}

/// Token yang belum dipakai, ditampilkan di token pool.
///
/// Token dapat dipindahkan ke area susun dengan satu ketukan agar tetap
/// ramah touch screen dan mudah dioperasikan dengan pembaca layar.
class DragToken extends StatelessWidget {
  final DragTokenData token;
  final VoidCallback onTap;
  final double maxWidth;

  const DragToken({
    required this.token,
    required this.onTap,
    required this.maxWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Token ${token.text}. Ketuk untuk menambahkan ke area susun.',
      onTap: onTap,
      child: ExcludeSemantics(
        child: TweenAnimationBuilder<double>(
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
            constraints: BoxConstraints(minHeight: 44, maxWidth: maxWidth),
            child: Material(
              color: KodiraColors.neutral100,
              borderRadius: BorderRadius.circular(KodiraRadius.sm),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(KodiraRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          token.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KodiraTextStyles.code.copyWith(
                            color: KodiraColors.neutral900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.add,
                        size: 15,
                        color: KodiraColors.neutral500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
