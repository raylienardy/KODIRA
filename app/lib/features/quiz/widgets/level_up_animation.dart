import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Animasi pembuka saat user pertama kali menyelesaikan sebuah level.
class LevelUpAnimation extends StatefulWidget {
  final int levelNumber;
  final VoidCallback? onComplete;

  const LevelUpAnimation({
    super.key,
    required this.levelNumber,
    this.onComplete,
  });

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Naik ke level ${widget.levelNumber}',
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        KodiraColors.primary700,
                        KodiraColors.success500,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: KodiraColors.primary700.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.levelNumber}',
                    style: KodiraTextStyles.display.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Level ${widget.levelNumber} terbuka!',
                  style: KodiraTextStyles.h3.copyWith(
                    color: KodiraColors.neutral900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
