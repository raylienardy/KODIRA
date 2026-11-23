import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class FillBlankExerciseData {
  final String language;
  final String codeTemplate;
  final List<FillBlankSlot> blanks;

  FillBlankSlot? slotById(String id) {
    try {
      return blanks.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  const FillBlankExerciseData({
    required this.language,
    required this.codeTemplate,
    required this.blanks,
  });

  factory FillBlankExerciseData.fromJson(Map<String, dynamic> json) {
    final rawBlanks = json['blanks'] as List;
    return FillBlankExerciseData(
      language: json['language'] ?? 'cpp',
      codeTemplate: json['code_template'] ?? '',
      blanks: rawBlanks.map((b) => FillBlankSlot.fromJson(b)).toList(),
    );
  }
}

class FillBlankSlot {
  final String id;
  final String answer;
  final List<String> options;

  const FillBlankSlot({
    required this.id,
    required this.answer,
    required this.options,
  });

  factory FillBlankSlot.fromJson(Map<String, dynamic> json) {
    return FillBlankSlot(
      id: json['id'],
      answer: json['answer'],
      options: List<String>.from(json['options'] ?? []),
    );
  }
}

class FillBlankExerciseView extends StatefulWidget {
  final FillBlankExerciseData data;
  final Function(Map<String, String>) onAnswersChanged;
  final Map<String, String> initialAnswers;

  const FillBlankExerciseView({
    required this.data,
    required this.onAnswersChanged,
    this.initialAnswers = const {},
    super.key,
  });

  @override
  State<FillBlankExerciseView> createState() => _FillBlankExerciseViewState();
}

class _FillBlankExerciseViewState extends State<FillBlankExerciseView> {
  late Map<String, String> _answers;
  String? _activeSlotId;

  @override
  void initState() {
    super.initState();
    _answers = Map.from(widget.initialAnswers);
  }

  void _selectSlot(String id) {
    setState(() {
      _activeSlotId = id;
    });
  }

  void _fillAnswer(String option) {
    if (_activeSlotId == null) return;
    setState(() {
      _answers[_activeSlotId!] = option;
      widget.onAnswersChanged(_answers);
      // Move to next empty slot if exists
      final currentIndex = widget.data.blanks.indexWhere(
        (b) => b.id == _activeSlotId,
      );
      if (currentIndex != -1 && currentIndex < widget.data.blanks.length - 1) {
        _activeSlotId = widget.data.blanks[currentIndex + 1].id;
      } else {
        _activeSlotId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCodeEditor(),
        const SizedBox(height: 24),
        if (_activeSlotId != null) _buildOptions(),
      ],
    );
  }

  Widget _buildCodeEditor() {
    final textStyle = const TextStyle(
      fontFamily: 'JetBrains Mono',
      fontSize: 14,
      height: 1.6,
    );

    // Split template by ___ to insert interactive blanks
    final parts = widget.data.codeTemplate.split('___');
    final List<InlineSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));
      if (i < widget.data.blanks.length) {
        final slot = widget.data.blanks[i];
        final answer = _answers[slot.id];
        final isActive = _activeSlotId == slot.id;

        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => _selectSlot(slot.id),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? KodiraColors.primary700.withValues(alpha: 0.3)
                      : (answer != null
                            ? KodiraColors.neutral700
                            : KodiraColors.neutral500),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isActive
                        ? KodiraColors.primary700
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Text(
                  answer ?? '___',
                  style: textStyle.copyWith(
                    color: answer != null ? Colors.white : Colors.white54,
                    fontWeight: answer != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(KodiraRadius.md),
      ),
      child: RichText(
        text: TextSpan(
          style: textStyle.copyWith(color: Colors.white),
          children: spans,
        ),
      ),
    );
  }

  Widget _buildOptions() {
    final slot = widget.data.slotById(_activeSlotId!);
    if (slot == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PILIH JAWABAN:',
          style: KodiraTextStyles.overline.copyWith(
            color: KodiraColors.neutral500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in slot.options)
              ActionChip(
                label: Text(option),
                onPressed: () => _fillAnswer(option),
                backgroundColor: KodiraColors.neutral0,
                labelStyle: KodiraTextStyles.bodySm.copyWith(
                  color: KodiraColors.neutral900,
                  fontFamily: 'JetBrains Mono',
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KodiraRadius.sm),
                ),
                side: const BorderSide(color: KodiraColors.neutral300),
              ),
          ],
        ),
      ],
    );
  }
}
