import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../data/logic/xp_logic.dart';
import '../../../data/models/level_model.dart';

class LevelSection extends StatefulWidget {
  final LevelTier tier;
  final List<LevelModel> levels;
  final Widget Function(LevelModel) levelBuilder;
  final bool initiallyExpanded;

  const LevelSection({
    super.key,
    required this.tier,
    required this.levels,
    required this.levelBuilder,
    this.initiallyExpanded = true,
  });

  @override
  State<LevelSection> createState() => _LevelSectionState();
}

class _LevelSectionState extends State<LevelSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  Color _colorFor(LevelTier tier) => switch (tier) {
    LevelTier.mudah => KodiraColors.success500,
    LevelTier.sedang => KodiraColors.reward500,
    LevelTier.tinggi => KodiraColors.alert700,
  };

  String _rangeLabel(LevelTier tier) => switch (tier) {
    LevelTier.mudah => '(1-15)',
    LevelTier.sedang => '(16-35)',
    LevelTier.tinggi => '(36-50)',
  };

  @override
  Widget build(BuildContext context) {
    final tierColor = _colorFor(widget.tier);
    final rangeLabel = _rangeLabel(widget.tier);
    final tierLabel = widget.tier.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          label:
              '$tierLabel $rangeLabel, ${widget.levels.length} level, ${_isExpanded ? "terbuka" : "tertutup"}',
          excludeSemantics: true,
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(KodiraRadius.full),
                    ),
                    child: Text(
                      tierLabel,
                      style: KodiraTextStyles.caption.copyWith(
                        color: tierColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rangeLabel,
                    style: KodiraTextStyles.bodySm.copyWith(
                      color: KodiraColors.neutral500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: KodiraColors.neutral700,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          Column(children: widget.levels.map(widget.levelBuilder).toList()),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
