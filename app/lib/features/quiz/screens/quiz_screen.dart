import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/exercise_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../exercise/providers/exercise_provider.dart';
import '../../home/providers/level_provider.dart';

/// Outcome of a finished quiz session.
enum QuizResult {
  /// The user finished the quiz and wants to go back to the material.
  backToMaterial,
}

/// Duration of a single question in seconds.
const int kQuizSecondsPerQuestion = 60;

/// Quiz screen: shows one question at a time with a countdown timer.
class QuizScreen extends ConsumerStatefulWidget {
  final int levelId;
  final String? levelTitle;

  const QuizScreen({required this.levelId, this.levelTitle, super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final ScrollController _scrollController = ScrollController();

  List<QuizQuestion> _questions = const [];
  int _currentIndex = 0;
  String? _selectedOptionId;
  bool _isSubmitted = false;
  bool _isTimedOut = false;
  int _secondsRemaining = kQuizSecondsPerQuestion;
  int _correctCount = 0;
  bool _isLoading = true;
  bool _isFinished = false;
  String? _error;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions({bool refresh = false}) async {
    if (refresh) {
      ref.invalidate(quizExercisesProvider(widget.levelId));
    }

    try {
      final exercises = await ref.read(
        quizExercisesProvider(widget.levelId).future,
      );
      if (!mounted) return;

      final questions = <QuizQuestion>[];
      for (final exercise in exercises) {
        final question = QuizQuestion.tryParse(exercise);
        if (question != null) {
          questions.add(question);
        }
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
        _error = null;
        _currentIndex = 0;
        _correctCount = 0;
        _selectedOptionId = null;
        _isSubmitted = false;
        _isTimedOut = false;
        _secondsRemaining = kQuizSecondsPerQuestion;
      });

      if (questions.isEmpty) {
        _stopTimer();
      } else {
        _startTimer();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadQuestions(refresh: true);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        _submitAnswer(timedOut: true);
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _selectOption(String optionId) {
    if (_isSubmitted) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedOptionId = optionId);
  }

  void _submitAnswer({bool timedOut = false}) {
    if (_isSubmitted || _questions.isEmpty) return;
    _stopTimer();

    final question = _questions[_currentIndex];
    final isCorrect = !timedOut && _selectedOptionId == question.answerId;

    setState(() {
      _isSubmitted = true;
      _isTimedOut = timedOut;
      if (isCorrect) _correctCount++;
    });
  }

  void _goToNextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionId = null;
        _isSubmitted = false;
        _isTimedOut = false;
        _secondsRemaining = kQuizSecondsPerQuestion;
      });
      _startTimer();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }
    _showResultDialog();
  }

  /// Simpan hasil kuis ke tabel `user_progress` dan buka level berikutnya
  /// bila level ini selesai dengan nilai minimal 70 persen.
  ///
  /// Mengembalikan XP yang diperoleh, atau 0 bila penyimpanan gagal.
  Future<int> _saveProgress(int score, int total) async {
    final user = ref.read(authStateProvider).user;
    if (user == null || total == 0) return 0;

    final ratio = score / total;
    final String status;
    final int xp;
    if (ratio >= 0.7) {
      status = 'completed';
      xp = 100;
    } else if (ratio >= 0.4) {
      status = 'active';
      xp = 50;
    } else {
      status = 'active';
      xp = 0;
    }

    final repo = ref.read(userProgressRepositoryProvider);
    try {
      await repo.upsert(
        userId: user.id,
        levelId: widget.levelId,
        status: status,
        masteryScore: ratio,
        xpEarned: xp,
        attempts: 1,
      );

      // Buka level berikutnya kalau level ini lulus.
      if (status == 'completed' && widget.levelId < 50) {
        final next = widget.levelId + 1;
        final existingNext = await repo.getForLevel(user.id, next);
        if (existingNext == null) {
          await repo.upsert(
            userId: user.id,
            levelId: next,
            status: 'active',
            masteryScore: 0.0,
            xpEarned: 0,
            attempts: 0,
          );
        }
      }

      ref.invalidate(allProgressProvider);
      ref.invalidate(totalXpProvider);
      return xp;
    } catch (e) {
      debugPrint('Failed to save progress: $e');
      return 0;
    }
  }

  Future<void> _showResultDialog() async {
    if (_isFinished) return;
    _stopTimer();
    setState(() => _isFinished = true);

    final xpEarned = await _saveProgress(_correctCount, _questions.length);

    // Berikan badge dan achievement yang baru setelah kuis selesai.
    try {
      final user = ref.read(authStateProvider).user;
      if (user != null) {
        await ref.read(badgeRepositoryProvider).checkAndAward(user.id);
        ref.invalidate(badgeCountProvider);
      }
    } catch (e) {
      debugPrint('Badge check failed: $e');
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _ResultDialog(
          correct: _correctCount,
          total: _questions.length,
          xpEarned: xpEarned,
          onDone: () => Navigator.of(dialogContext).pop(),
        );
      },
    );

    if (!mounted) return;
    Navigator.of(context).pop(QuizResult.backToMaterial);
  }

  QuizQuestion? get _currentQuestion {
    if (_questions.isEmpty) return null;
    if (_currentIndex >= _questions.length) return null;
    return _questions[_currentIndex];
  }

  bool get _hasQuestion => _currentQuestion != null && !_isFinished;

  @override
  Widget build(BuildContext context) {
    final title = widget.levelTitle == null
        ? 'Kuis'
        : 'Kuis ${widget.levelTitle}';

    return Scaffold(
      backgroundColor: KodiraColors.neutral100,
      appBar: AppBar(
        backgroundColor: KodiraColors.neutral0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back),
          color: KodiraColors.neutral900,
        ),
        titleSpacing: 0,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: KodiraTextStyles.h3.copyWith(color: KodiraColors.neutral900),
        ),
        actions: [
          if (_hasQuestion)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: _CounterBadge(
                  current: _currentIndex + 1,
                  total: _questions.length,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: KodiraColors.neutral200),
        ),
      ),
      body: SafeArea(top: false, child: _buildBody()),
      bottomNavigationBar: _hasQuestion
          ? _QuizBottomBar(
              isSubmitted: _isSubmitted,
              canSubmit: _selectedOptionId != null,
              isLastQuestion: _currentIndex == _questions.length - 1,
              onSubmit: _submitAnswer,
              onNext: _goToNextQuestion,
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const _LoadingView();
    }
    if (_error != null) {
      return _ErrorView(
        title: 'Gagal memuat kuis',
        message: _error!,
        onRetry: _retry,
      );
    }
    if (_questions.isEmpty) {
      return const _EmptyView();
    }
    final question = _currentQuestion;
    if (question == null) {
      return const _EmptyView();
    }
    return _buildQuestion(question);
  }

  Widget _buildQuestion(QuizQuestion question) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimerHeader(
            secondsRemaining: _secondsRemaining,
            totalSeconds: kQuizSecondsPerQuestion,
          ),
          const SizedBox(height: 20),
          _QuestionCard(prompt: question.prompt, language: question.language),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'PILIH JAWABAN',
            trailing: _isSubmitted
                ? 'Jawaban sudah dikirim'
                : 'Pilih satu jawaban',
          ),
          const SizedBox(height: 10),
          for (final option in question.options) ...[
            _OptionTile(
              option: option,
              isSelected: option.id == _selectedOptionId,
              isCorrect: _isSubmitted && option.id == question.answerId,
              isWrongSelection:
                  _isSubmitted &&
                  option.id == _selectedOptionId &&
                  option.id != question.answerId,
              isLocked: _isSubmitted,
              onTap: () => _selectOption(option.id),
            ),
            const SizedBox(height: 10),
          ],
          if (_isSubmitted) ...[
            const SizedBox(height: 6),
            _FeedbackCard(
              isCorrect: _selectedOptionId == question.answerId,
              isTimedOut: _isTimedOut,
              explanation: question.explanation,
            ),
          ],
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
/// One parsed quiz question.
class QuizQuestion {
  final String prompt;
  final String language;
  final List<QuizOption> options;
  final String answerId;
  final String explanation;

  const QuizQuestion({
    required this.prompt,
    required this.language,
    required this.options,
    required this.answerId,
    required this.explanation,
  });

  static QuizQuestion? tryParse(ExerciseModel exercise) {
    final payload = exercise.payload;
    if (payload == null) return null;

    final rawOptions = payload['options'];
    final rawAnswer = payload['answer'];
    final rawExplanation = payload['explanation'];
    if (rawOptions is! List) return null;
    if (rawAnswer is! String) return null;
    if (rawExplanation is! String || rawExplanation.trim().isEmpty) {
      return null;
    }

    final options = <QuizOption>[];
    final optionIds = <String>{};
    for (final rawOption in rawOptions) {
      if (rawOption is! Map) return null;
      final id = rawOption['id'];
      final text = rawOption['text'];
      if (id is! String || id.isEmpty) return null;
      if (text is! String || text.trim().isEmpty) return null;
      if (!optionIds.add(id)) return null;
      options.add(QuizOption(id: id, text: text));
    }

    if (options.length < 2) return null;
    if (!optionIds.contains(rawAnswer)) return null;

    final rawLanguage = payload['language'];
    final language = rawLanguage is String && rawLanguage.isNotEmpty
        ? rawLanguage
        : 'cpp';

    return QuizQuestion(
      prompt: exercise.prompt,
      language: language,
      options: options,
      answerId: rawAnswer,
      explanation: rawExplanation,
    );
  }
}

// -------------------------------------------------------------------
/// One answer choice of a quiz question.
class QuizOption {
  final String id;
  final String text;

  const QuizOption({required this.id, required this.text});
}

// -------------------------------------------------------------------
class _CounterBadge extends StatelessWidget {
  final int current;
  final int total;

  const _CounterBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: KodiraColors.primary100,
        borderRadius: BorderRadius.circular(KodiraRadius.full),
      ),
      child: Text(
        '$current / $total',
        style: KodiraTextStyles.caption.copyWith(
          color: KodiraColors.primary900,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
class _TimerHeader extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;

  const _TimerHeader({
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  bool get _isLow => secondsRemaining <= 10;

  String get _formatted {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0 ? 0.0 : secondsRemaining / totalSeconds;

    return Semantics(
      excludeSemantics: true,
      label: 'Sisa waktu $secondsRemaining detik',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: _isLow ? KodiraColors.alert700 : KodiraColors.neutral500,
              ),
              const SizedBox(width: 6),
              Text(
                'Sisa waktu',
                style: KodiraTextStyles.bodySm.copyWith(
                  color: KodiraColors.neutral700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _formatted,
                style: KodiraTextStyles.bodySm.copyWith(
                  color: KodiraColors.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(KodiraRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: KodiraColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isLow ? KodiraColors.alert700 : KodiraColors.primary700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
class _QuestionCard extends StatelessWidget {
  final String prompt;
  final String language;

  const _QuestionCard({required this.prompt, required this.language});

  @override
  Widget build(BuildContext context) {
    final languageLabel = language.toLowerCase() == 'cpp'
        ? 'C++'
        : language.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KodiraColors.neutral0,
        borderRadius: BorderRadius.circular(KodiraRadius.lg),
        border: Border.all(color: KodiraColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: KodiraColors.codeBg,
              borderRadius: BorderRadius.circular(KodiraRadius.xs),
            ),
            child: Text(
              languageLabel,
              style: KodiraTextStyles.overline.copyWith(
                color: Colors.white,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            prompt,
            style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih satu jawaban yang paling tepat, lalu kirim sebelum waktu '
            'habis.',
            style: KodiraTextStyles.body.copyWith(
              color: KodiraColors.neutral700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: KodiraTextStyles.overline.copyWith(
            color: KodiraColors.neutral500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            trailing,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KodiraTextStyles.caption.copyWith(
              color: KodiraColors.neutral500,
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------
class _OptionTile extends StatelessWidget {
  final QuizOption option;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrongSelection;
  final bool isLocked;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrongSelection,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color backgroundColor;
    final Color badgeColor;
    final Color badgeTextColor;
    final IconData? trailingIcon;
    final Color? trailingIconColor;

    if (isCorrect) {
      borderColor = KodiraColors.success700;
      backgroundColor = KodiraColors.success100;
      badgeColor = KodiraColors.success100;
      badgeTextColor = KodiraColors.neutral900;
      trailingIcon = Icons.check_circle;
      trailingIconColor = KodiraColors.success700;
    } else if (isWrongSelection) {
      borderColor = KodiraColors.alert700;
      backgroundColor = KodiraColors.alert100;
      badgeColor = KodiraColors.alert100;
      badgeTextColor = KodiraColors.neutral900;
      trailingIcon = Icons.cancel;
      trailingIconColor = KodiraColors.alert700;
    } else if (isSelected) {
      borderColor = KodiraColors.primary700;
      backgroundColor = KodiraColors.primary100;
      badgeColor = KodiraColors.primary100;
      badgeTextColor = KodiraColors.neutral900;
      trailingIcon = Icons.radio_button_checked;
      trailingIconColor = KodiraColors.primary700;
    } else {
      borderColor = KodiraColors.neutral200;
      backgroundColor = KodiraColors.neutral0;
      badgeColor = KodiraColors.neutral100;
      badgeTextColor = KodiraColors.neutral900;
      trailingIcon = null;
      trailingIconColor = null;
    }

    final label = option.id.toUpperCase();
    final stateLabel = isCorrect
        ? 'jawaban benar'
        : isWrongSelection
        ? 'jawaban salah'
        : isSelected
        ? 'terpilih'
        : 'belum dipilih';

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: !isLocked,
      label: 'Pilihan $label, ${option.text}, $stateLabel',
      excludeSemantics: true,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(KodiraRadius.md),
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(KodiraRadius.md),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(KodiraRadius.md),
              border: Border.all(
                color: borderColor,
                width: isSelected || isCorrect || isWrongSelection ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    label,
                    style: KodiraTextStyles.caption.copyWith(
                      color: badgeTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.text,
                    style: KodiraTextStyles.bodyLg.copyWith(
                      color: KodiraColors.neutral900,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: trailingIconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(trailingIcon, size: 16, color: Colors.white),
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

// -------------------------------------------------------------------
class _FeedbackCard extends StatelessWidget {
  final bool isCorrect;
  final bool isTimedOut;
  final String explanation;

  const _FeedbackCard({
    required this.isCorrect,
    required this.isTimedOut,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isCorrect
        ? KodiraColors.success700
        : KodiraColors.alert700;
    final backgroundColor = isCorrect
        ? KodiraColors.success100
        : KodiraColors.alert100;
    final icon = isCorrect
        ? Icons.check
        : (isTimedOut ? Icons.timer_off_outlined : Icons.close);
    final title = isCorrect
        ? 'Benar!'
        : (isTimedOut ? 'Waktu habis' : 'Belum tepat');

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(KodiraRadius.lg),
          border: Border.all(color: accentColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: KodiraTextStyles.h3.copyWith(
                      color: KodiraColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    explanation,
                    style: KodiraTextStyles.body.copyWith(
                      color: KodiraColors.neutral700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
class _QuizBottomBar extends StatelessWidget {
  final bool isSubmitted;
  final bool canSubmit;
  final bool isLastQuestion;
  final VoidCallback onSubmit;
  final VoidCallback onNext;

  const _QuizBottomBar({
    required this.isSubmitted,
    required this.canSubmit,
    required this.isLastQuestion,
    required this.onSubmit,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final label = isSubmitted
        ? (isLastQuestion ? 'Lihat Hasil' : 'Lanjut')
        : 'Kirim Jawaban';

    return Container(
      decoration: const BoxDecoration(
        color: KodiraColors.neutral0,
        border: Border(top: BorderSide(color: KodiraColors.neutral200)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isSubmitted ? onNext : (canSubmit ? onSubmit : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: KodiraColors.primary700,
                foregroundColor: Colors.white,
                disabledBackgroundColor: KodiraColors.neutral200,
                disabledForegroundColor: KodiraColors.neutral500,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KodiraRadius.md),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
class _ResultDialog extends StatelessWidget {
  final int correct;
  final int total;
  final int xpEarned;
  final VoidCallback onDone;

  const _ResultDialog({
    required this.correct,
    required this.total,
    required this.xpEarned,
    required this.onDone,
  });

  String get _status {
    if (total == 0) return 'Kuis selesai.';
    final ratio = correct / total;
    if (correct == total) {
      return 'Luar biasa! Kamu menjawab semua soal dengan benar.';
    }
    if (ratio >= 0.67) {
      return 'Bagus! Pemahamanmu sudah kuat, tinggal sedikit lagi.';
    }
    if (ratio >= 0.34) {
      return 'Cukup baik. Bagian yang masih salah perlu diulang.';
    }
    return 'Perlu belajar lagi. Baca kembali materinya lalu coba lagi.';
  }

  IconData get _icon {
    if (total == 0) return Icons.info_outline;
    final ratio = correct / total;
    if (correct == total) return Icons.emoji_events_outlined;
    if (ratio >= 0.67) return Icons.thumb_up_outlined;
    return Icons.refresh;
  }

  Color get _accentColor {
    if (total == 0) return KodiraColors.primary700;
    final ratio = correct / total;
    if (correct == total) return KodiraColors.reward700;
    if (ratio >= 0.67) return KodiraColors.success700;
    return KodiraColors.alert700;
  }

  @override
  Widget build(BuildContext context) {
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
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: KodiraColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _accentColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Kuis Selesai',
              style: KodiraTextStyles.h2.copyWith(
                color: KodiraColors.neutral900,
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              label: 'Skor $correct dari $total soal benar',
              excludeSemantics: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$correct',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      color: KodiraColors.neutral900,
                    ),
                  ),
                  Text(
                    ' / $total',
                    style: KodiraTextStyles.h2.copyWith(
                      color: KodiraColors.neutral500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jawaban benar $correct dari $total soal',
              style: KodiraTextStyles.bodySm.copyWith(
                color: KodiraColors.neutral500,
              ),
            ),
            if (xpEarned > 0) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: KodiraColors.reward100,
                  borderRadius: BorderRadius.circular(KodiraRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt,
                      size: 16,
                      color: KodiraColors.reward700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Kamu mendapat $xpEarned XP',
                      style: KodiraTextStyles.bodySm.copyWith(
                        color: KodiraColors.reward700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: KodiraTextStyles.body.copyWith(
                color: KodiraColors.neutral700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KodiraColors.primary700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KodiraRadius.md),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Kembali ke Materi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat kuis',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SkeletonLine(width: 160, height: 12),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KodiraColors.neutral0,
                borderRadius: BorderRadius.circular(KodiraRadius.lg),
                border: Border.all(color: KodiraColors.neutral200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonLine(width: 56, height: 20),
                  SizedBox(height: 16),
                  _SkeletonLine(width: double.infinity, height: 18),
                  SizedBox(height: 8),
                  _SkeletonLine(width: 220, height: 12),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SkeletonLine(width: 120, height: 12),
            const SizedBox(height: 10),
            for (var i = 0; i < 4; i++) ...[
              const _SkeletonLine(width: double.infinity, height: 56),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: KodiraColors.neutral200,
        borderRadius: BorderRadius.circular(KodiraRadius.full),
      ),
    );
  }
}

// -------------------------------------------------------------------
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: KodiraColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz_outlined,
                size: 32,
                color: KodiraColors.neutral500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kuis belum tersedia',
              textAlign: TextAlign.center,
              style: KodiraTextStyles.h2.copyWith(
                color: KodiraColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kuis untuk level ini belum tersedia. Kembali ke materi untuk '
              'melanjutkan.',
              textAlign: TextAlign.center,
              style: KodiraTextStyles.body.copyWith(
                color: KodiraColors.neutral700,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KodiraColors.primary700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KodiraRadius.md),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Kembali ke Materi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: KodiraColors.alert100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: KodiraColors.alert700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: KodiraTextStyles.h2.copyWith(
                color: KodiraColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: KodiraTextStyles.body.copyWith(
                color: KodiraColors.neutral700,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KodiraColors.primary700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KodiraRadius.md),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Kembali ke Materi'),
            ),
          ],
        ),
      ),
    );
  }
}
