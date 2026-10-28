import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../ai_mentor/providers/ai_provider.dart';
import '../../quiz/screens/quiz_screen.dart';

/// Dialog remedial ketika mastery kuis berada di bawah ambang 40%.
///
/// Memungkinkan user meminta 3 soal latihan baru yang di-generate oleh AI
/// atau kembali ke materi untuk mempelajari topik tersebut lebih lanjut.
class RemedialDialog extends ConsumerStatefulWidget {
  final int levelId;
  final String topic;
  final String language;
  final double mastery;
  final VoidCallback onRetry;
  final VoidCallback onBackToMaterial;
  final void Function(List<QuizQuestion> questions)? onStartRemedial;

  const RemedialDialog({
    super.key,
    required this.levelId,
    required this.topic,
    required this.language,
    required this.mastery,
    required this.onRetry,
    required this.onBackToMaterial,
    this.onStartRemedial,
  });

  @override
  ConsumerState<RemedialDialog> createState() => _RemedialDialogState();
}

class _RemedialDialogState extends ConsumerState<RemedialDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _generateRemedialQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final aiRepo = ref.read(aiRepositoryProvider);
      final rawList = await aiRepo.generateQuiz(
        levelId: widget.levelId,
        topic: widget.topic,
        language: widget.language,
        questionCount: 3,
        context:
            'Mahasiswa memperoleh skor mastery ${(widget.mastery * 100).toStringAsFixed(0)}%. Berikan soal pemahaman konsep fundamental.',
      );

      final parsed = <QuizQuestion>[];
      for (final item in rawList) {
        final q = QuizQuestion.fromAiMap(item, language: widget.language);
        if (q != null) {
          parsed.add(q);
        }
      }

      if (parsed.isEmpty) {
        throw Exception('Format soal dari AI tidak dapat dibaca');
      }

      if (!mounted) return;

      if (widget.onStartRemedial != null) {
        widget.onStartRemedial!(parsed);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              levelId: widget.levelId,
              levelTitle: widget.topic,
              overrideQuestions: parsed,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int pct = (widget.mastery * 100).round().clamp(0, 100);

    return Dialog(
      backgroundColor: KodiraColors.neutral0,
      elevation: 4,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: KodiraColors.neutral300, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _buildInitialState(pct),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: KodiraColors.primary500,
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          label: 'AI sedang menyiapkan 3 soal remedial baru',
          child: Text(
            'AI sedang menyiapkan soal remedial...',
            textAlign: TextAlign.center,
            style: KodiraTextStyles.h3.copyWith(color: KodiraColors.neutral900),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Menyesuaikan soal dengan materi yang perlu kamu kuasai.',
          textAlign: TextAlign.center,
          style: KodiraTextStyles.bodySm.copyWith(
            color: KodiraColors.neutral700,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: KodiraColors.alert100,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            size: 32,
            color: KodiraColors.alert700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Gagal Menyiapkan Soal',
          textAlign: TextAlign.center,
          style: KodiraTextStyles.h3.copyWith(color: KodiraColors.neutral900),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? 'Terjadi kendala jaringan saat menghubungi AI.',
          textAlign: TextAlign.center,
          style: KodiraTextStyles.bodySm.copyWith(
            color: KodiraColors.neutral700,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _generateRemedialQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: KodiraColors.primary500,
              foregroundColor: KodiraColors.neutral0,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Semantics(
              button: true,
              label: 'Coba panggil AI lagi',
              child: Text(
                'Coba Lagi',
                style: KodiraTextStyles.bodyLg.copyWith(
                  color: KodiraColors.neutral0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: widget.onBackToMaterial,
            style: OutlinedButton.styleFrom(
              foregroundColor: KodiraColors.neutral900,
              side: const BorderSide(color: KodiraColors.neutral300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Semantics(
              button: true,
              label: 'Kembali ke materi pelajaran',
              child: Text(
                'Kembali ke Materi',
                style: KodiraTextStyles.bodyLg.copyWith(
                  color: KodiraColors.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialState(int pct) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: KodiraColors.alert100,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school_outlined,
            size: 34,
            color: KodiraColors.alert700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Perlu Belajar Lagi',
          textAlign: TextAlign.center,
          style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
        ),
        const SizedBox(height: 10),
        Text(
          'Mastery kamu $pct% — masih di bawah batas 40%. Yuk kerjakan soal remedial dari AI untuk memperkuat pemahamanmu.',
          textAlign: TextAlign.center,
          style: KodiraTextStyles.body.copyWith(
            color: KodiraColors.neutral700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _generateRemedialQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: KodiraColors.primary500,
              foregroundColor: KodiraColors.neutral0,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Semantics(
              button: true,
              label: 'Kerjakan 3 soal remedial dari AI',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Kerjakan Soal Remedial',
                    style: KodiraTextStyles.bodyLg.copyWith(
                      color: KodiraColors.neutral0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: widget.onBackToMaterial,
            style: OutlinedButton.styleFrom(
              foregroundColor: KodiraColors.neutral900,
              side: const BorderSide(color: KodiraColors.neutral300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Semantics(
              button: true,
              label: 'Kembali membaca materi pelajaran',
              child: Text(
                'Kembali ke Materi',
                style: KodiraTextStyles.bodyLg.copyWith(
                  color: KodiraColors.neutral900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
