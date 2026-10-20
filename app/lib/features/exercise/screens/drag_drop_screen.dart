import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/models/exercise_model.dart';
import '../../quiz/screens/quiz_screen.dart';
import '../providers/exercise_provider.dart';
import '../widgets/drag_token.dart';
import '../widgets/drop_zone.dart';

enum _FeedbackResult { next, retry, reset, finish, quiz }

class DragDropScreen extends ConsumerStatefulWidget {
  final int levelId;

  const DragDropScreen({required this.levelId, super.key});

  @override
  ConsumerState<DragDropScreen> createState() => _DragDropScreenState();
}

class _DragDropScreenState extends ConsumerState<DragDropScreen> {
  final ScrollController _scrollController = ScrollController();

  List<ExerciseModel> _exercises = const [];
  int _currentIndex = 0;
  _DragDropData? _data;
  List<String> _dropZoneIds = [];
  List<String> _poolIds = [];
  bool _isLoading = true;
  String? _error;
  String? _payloadError;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises({bool refresh = false}) async {
    if (refresh) {
      ref.invalidate(dragDropExercisesProvider(widget.levelId));
    }

    try {
      final exercises = await ref.read(
        dragDropExercisesProvider(widget.levelId).future,
      );
      if (!mounted) return;

      setState(() {
        _exercises = exercises;
        _isLoading = false;
        _error = null;
        if (exercises.isEmpty) {
          _currentIndex = 0;
          _data = null;
          _payloadError = null;
          _dropZoneIds = [];
          _poolIds = [];
        } else {
          _prepareExercise(0);
        }
      });

      if (exercises.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Latihan belum tersedia untuk level ini'),
            ),
          );
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = _cleanError(error);
      });
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadExercises(refresh: true);
  }

  void _prepareExercise(int index) {
    _currentIndex = index;
    final exercise = _exercises[index];
    final data = _DragDropData.tryParse(exercise);

    if (data == null) {
      _data = null;
      _payloadError =
          'Format latihan tidak valid. Periksa payload exercise ini.';
      _dropZoneIds = [];
      _poolIds = [];
      return;
    }

    _payloadError = null;
    _data = data;
    _dropZoneIds = [];
    _poolIds = data.tokens.map((token) => token.id).toList();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _addToken(String id) {
    if (!_poolIds.contains(id)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _poolIds.remove(id);
      _dropZoneIds.add(id);
    });
  }

  void _removeToken(String id) {
    if (!_dropZoneIds.contains(id)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _dropZoneIds.remove(id);
      _poolIds.add(id);
    });
  }

  void _reorderTokens(int oldIndex, int newIndex) {
    setState(() {
      final id = _dropZoneIds.removeAt(oldIndex);
      final targetIndex = newIndex.clamp(0, _dropZoneIds.length).toInt();
      _dropZoneIds.insert(targetIndex, id);
    });
  }

  void _resetExercise() {
    final data = _data;
    if (data == null) return;
    setState(() {
      _dropZoneIds = [];
      _poolIds = data.tokens.map((token) => token.id).toList();
    });
  }

  Future<void> _checkAnswer() async {
    final data = _data;
    if (data == null || _dropZoneIds.isEmpty) return;

    final isCorrect = listEquals(_dropZoneIds, data.answer);
    if (isCorrect) {
      if (_currentIndex == _exercises.length - 1) {
        final result = await _showCompletionSheet();
        if (!mounted) return;
        if (result == _FeedbackResult.quiz) {
          await _openQuiz();
          return;
        }
        if (result == _FeedbackResult.finish) {
          Navigator.of(context).maybePop();
        }
        return;
      }

      final result = await _showCorrectSheet();
      if (!mounted) return;
      if (result == _FeedbackResult.next) {
        setState(() => _prepareExercise(_currentIndex + 1));
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      }
      return;
    }

    final result = await _showWrongSheet(
      used: _dropZoneIds.length,
      total: data.tokens.length,
    );
    if (!mounted) return;
    if (result == _FeedbackResult.reset) {
      _resetExercise();
    }
  }

  Future<_FeedbackResult?> _showCorrectSheet() {
    return showModalBottomSheet<_FeedbackResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: KodiraColors.neutral900.withValues(alpha: 0.45),
      builder: (context) {
        return _FeedbackSheet(
          icon: Icons.check,
          iconColor: KodiraColors.success500,
          iconBackground: KodiraColors.success100,
          title: 'Benar!',
          message: 'Urutan token sudah tepat. Lanjut ke latihan berikutnya.',
          primaryLabel: 'Lanjut',
          onPrimary: () => Navigator.of(context).pop(_FeedbackResult.next),
        );
      },
    );
  }

  Future<_FeedbackResult?> _showWrongSheet({
    required int used,
    required int total,
  }) {
    final remaining = total - used;
    final message = remaining > 0
        ? 'Masih ada $remaining token yang belum dipakai. Susun semua token '
              'sesuai urutan yang benar, lalu periksa lagi.'
        : 'Urutan token belum sesuai. Coba lagi dengan memindahkan atau '
              'menggeser token.';

    return showModalBottomSheet<_FeedbackResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: KodiraColors.neutral900.withValues(alpha: 0.45),
      builder: (context) {
        return _FeedbackSheet(
          icon: Icons.close,
          iconColor: KodiraColors.alert700,
          iconBackground: KodiraColors.alert100,
          title: 'Belum tepat',
          message: message,
          secondaryLabel: 'Reset',
          onSecondary: () => Navigator.of(context).pop(_FeedbackResult.reset),
          primaryLabel: 'Coba Lagi',
          onPrimary: () => Navigator.of(context).pop(_FeedbackResult.retry),
        );
      },
    );
  }

  Future<_FeedbackResult?> _showCompletionSheet() {
    final hasQuiz = ref
        .read(quizExercisesProvider(widget.levelId))
        .maybeWhen(data: (value) => value.isNotEmpty, orElse: () => false);

    return showModalBottomSheet<_FeedbackResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: KodiraColors.neutral900.withValues(alpha: 0.45),
      builder: (context) {
        return _FeedbackSheet(
          icon: Icons.check,
          iconColor: KodiraColors.success500,
          iconBackground: KodiraColors.success100,
          title: 'Latihan selesai!',
          message: hasQuiz
              ? 'Kamu menyelesaikan ${_exercises.length} latihan drag & drop. '
                    'Lanjut ke kuis untuk menguji pemahamanmu.'
              : 'Kamu menyelesaikan ${_exercises.length} latihan drag & drop. '
                    'Kembali ke materi untuk melanjutkan.',
          secondaryLabel: hasQuiz ? 'Kembali ke Materi' : null,
          onSecondary: hasQuiz
              ? () => Navigator.of(context).pop(_FeedbackResult.finish)
              : null,
          primaryLabel: hasQuiz ? 'Mulai Kuis' : 'Kembali ke Materi',
          onPrimary: () => Navigator.of(
            context,
          ).pop(hasQuiz ? _FeedbackResult.quiz : _FeedbackResult.finish),
        );
      },
    );
  }

  bool get _hasExerciseData {
    return !_isLoading &&
        _error == null &&
        _exercises.isNotEmpty &&
        _data != null &&
        _payloadError == null;
  }

  /// Number of quiz exercises available for this level.
  int get _quizCount => ref
      .watch(quizExercisesProvider(widget.levelId))
      .maybeWhen(data: (value) => value.length, orElse: () => 0);

  bool get _hasQuiz => _quizCount > 0;

  Future<void> _openQuiz() async {
    final result = await Navigator.of(context).push<QuizResult>(
      MaterialPageRoute(builder: (_) => QuizScreen(levelId: widget.levelId)),
    );
    if (!mounted) return;
    if (result == QuizResult.backToMaterial) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _data == null ? 'Latihan' : 'Latihan: ${_data!.prompt}';

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
        title: Tooltip(
          message: title,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KodiraTextStyles.h3.copyWith(color: KodiraColors.neutral900),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: KodiraColors.neutral200),
        ),
      ),
      body: SafeArea(top: false, child: _buildBody()),
      bottomNavigationBar: _hasExerciseData
          ? _BottomBar(
              canCheck: _dropZoneIds.isNotEmpty,
              canReset: _dropZoneIds.isNotEmpty,
              hasQuiz: _hasQuiz,
              onCheck: _checkAnswer,
              onReset: _resetExercise,
              onQuiz: _openQuiz,
              onBackToMaterial: () => Navigator.of(context).maybePop(),
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
        title: 'Gagal memuat latihan',
        message: _error!,
        onRetry: _retry,
      );
    }
    if (_exercises.isEmpty) {
      return const _EmptyView();
    }
    if (_payloadError != null || _data == null) {
      return _ErrorView(
        title: 'Latihan tidak dapat dibuka',
        message: _payloadError ?? 'Format latihan tidak valid.',
        onRetry: _retry,
      );
    }
    return _buildExercise();
  }

  Widget _buildExercise() {
    final data = _data!;
    final selectedTokens = _dropZoneIds
        .map((id) => data.tokenById[id]!)
        .toList();
    final poolTokens = _poolIds.map((id) => data.tokenById[id]!).toList();

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressHeader(current: _currentIndex + 1, total: _exercises.length),
          const SizedBox(height: 20),
          _InstructionCard(prompt: data.prompt, language: data.language),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'AREA SUSUN',
            trailing: '${_dropZoneIds.length}/${data.tokens.length} token',
          ),
          const SizedBox(height: 10),
          DropZone(
            tokens: selectedTokens,
            onReorderItem: _reorderTokens,
            onRemove: _removeToken,
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'PILIHAN TOKEN',
            trailing: poolTokens.isEmpty
                ? 'Semua token sudah dipakai'
                : '${poolTokens.length} token tersisa',
          ),
          const SizedBox(height: 10),
          _TokenPool(tokens: poolTokens, onTap: _addToken),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
class _DragDropData {
  final String prompt;
  final String language;
  final List<DragTokenData> tokens;
  final List<String> answer;
  final Map<String, DragTokenData> tokenById;

  const _DragDropData({
    required this.prompt,
    required this.language,
    required this.tokens,
    required this.answer,
    required this.tokenById,
  });

  static _DragDropData? tryParse(ExerciseModel exercise) {
    final payload = exercise.payload;
    if (payload == null) return null;

    final rawTokens = payload['tokens'];
    final rawAnswer = payload['answer'];
    final rawLanguage = payload['language'];
    if (rawTokens is! List || rawAnswer is! List) return null;

    final tokens = <DragTokenData>[];
    final tokenIds = <String>{};

    for (final rawToken in rawTokens) {
      if (rawToken is! Map) return null;
      final id = rawToken['id'];
      final text = rawToken['text'];
      if (id is! String || id.isEmpty || text is! String || text.isEmpty) {
        return null;
      }
      if (!tokenIds.add(id)) return null;
      tokens.add(DragTokenData(id: id, text: text));
    }

    if (tokens.isEmpty) return null;

    final answer = <String>[];
    for (final rawId in rawAnswer) {
      if (rawId is! String) return null;
      answer.add(rawId);
    }

    if (answer.length != tokens.length) return null;
    if (answer.any((id) => !tokenIds.contains(id))) return null;
    if (answer.toSet().length != answer.length) return null;

    final language = rawLanguage is String && rawLanguage.isNotEmpty
        ? rawLanguage
        : 'cpp';

    return _DragDropData(
      prompt: exercise.prompt,
      language: language,
      tokens: tokens,
      answer: answer,
      tokenById: {for (final token in tokens) token.id: token},
    );
  }
}

// -------------------------------------------------------------------
class _ProgressHeader extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressHeader({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;
    final percent = (progress * 100).round();

    return Semantics(
      excludeSemantics: true,
      label: 'Latihan $current dari $total, $percent persen',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Latihan $current dari $total',
                style: KodiraTextStyles.bodySm.copyWith(
                  color: KodiraColors.neutral700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$percent%',
                style: KodiraTextStyles.caption.copyWith(
                  color: KodiraColors.primary700,
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
              valueColor: const AlwaysStoppedAnimation<Color>(
                KodiraColors.primary700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
class _InstructionCard extends StatelessWidget {
  final String prompt;
  final String language;

  const _InstructionCard({required this.prompt, required this.language});

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
          Row(
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
              const Spacer(),
              const Icon(
                Icons.touch_app_outlined,
                size: 18,
                color: KodiraColors.neutral500,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            prompt,
            style: KodiraTextStyles.h2.copyWith(color: KodiraColors.neutral900),
          ),
          const SizedBox(height: 6),
          Text(
            'Susun token menjadi urutan kode yang benar. Ketuk token untuk '
            'memindahkan, lalu tahan dan geser untuk mengubah urutan di area '
            'susun.',
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
class _TokenPool extends StatelessWidget {
  final List<DragTokenData> tokens;
  final ValueChanged<String> onTap;

  const _TokenPool({required this.tokens, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KodiraColors.neutral0,
        borderRadius: BorderRadius.circular(KodiraRadius.lg),
        border: Border.all(color: KodiraColors.neutral200),
      ),
      child: tokens.isEmpty
          ? Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: KodiraColors.success700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Semua token sudah dipakai. Periksa susunanmu.',
                    style: KodiraTextStyles.bodySm.copyWith(
                      color: KodiraColors.neutral700,
                    ),
                  ),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final token in tokens)
                      DragToken(
                        key: ValueKey('pool-${token.id}'),
                        token: token,
                        maxWidth: constraints.maxWidth,
                        onTap: () => onTap(token.id),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

// -------------------------------------------------------------------
class _BottomBar extends StatelessWidget {
  final bool canCheck;
  final bool canReset;
  final bool hasQuiz;
  final VoidCallback onCheck;
  final VoidCallback onReset;
  final VoidCallback onQuiz;
  final VoidCallback onBackToMaterial;

  const _BottomBar({
    required this.canCheck,
    required this.canReset,
    required this.hasQuiz,
    required this.onCheck,
    required this.onReset,
    required this.onQuiz,
    required this.onBackToMaterial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KodiraColors.neutral0,
        border: Border(top: BorderSide(color: KodiraColors.neutral200)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                flex: hasQuiz ? 1 : 2,
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: hasQuiz
                        ? (canReset ? onReset : null)
                        : onBackToMaterial,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KodiraColors.neutral700,
                      side: BorderSide(
                        color: hasQuiz
                            ? (canReset
                                  ? KodiraColors.neutral300
                                  : KodiraColors.neutral200)
                            : KodiraColors.neutral300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KodiraRadius.md),
                      ),
                      textStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: hasQuiz ? 14 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(hasQuiz ? 'Reset' : 'Kembali ke Materi'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (hasQuiz) ...[
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: onQuiz,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KodiraColors.primary900,
                        side: const BorderSide(color: KodiraColors.primary700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KodiraRadius.md),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Kuis'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canCheck ? onCheck : null,
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
                    child: const Text('Periksa'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
class _FeedbackSheet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String primaryLabel;
  final VoidCallback onPrimary;

  const _FeedbackSheet({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
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
      child: SafeArea(
        top: false,
        child: Semantics(
          container: true,
          liveRegion: true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: KodiraColors.neutral0,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(KodiraRadius.xl2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: KodiraColors.neutral200,
                    borderRadius: BorderRadius.circular(KodiraRadius.full),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 32),
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
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (secondaryLabel != null && onSecondary != null)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: onSecondary,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: KodiraColors.neutral700,
                              side: const BorderSide(
                                color: KodiraColors.neutral300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  KodiraRadius.md,
                                ),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(secondaryLabel!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: onPrimary,
                            style: _primaryButtonStyle(),
                            child: Text(primaryLabel),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onPrimary,
                      style: _primaryButtonStyle(),
                      child: Text(primaryLabel),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
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
    );
  }
}

// -------------------------------------------------------------------
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat latihan',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SkeletonLine(width: 140, height: 12),
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
            const _SkeletonLine(width: 110, height: 12),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 148,
              decoration: BoxDecoration(
                color: KodiraColors.neutral0,
                borderRadius: BorderRadius.circular(KodiraRadius.md),
                border: Border.all(color: KodiraColors.neutral200),
              ),
            ),
            const SizedBox(height: 24),
            const _SkeletonLine(width: 120, height: 12),
            const SizedBox(height: 10),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SkeletonChip(width: 120),
                _SkeletonChip(width: 150),
                _SkeletonChip(width: 96),
                _SkeletonChip(width: 132),
              ],
            ),
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

class _SkeletonChip extends StatelessWidget {
  final double width;

  const _SkeletonChip({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 44,
      decoration: BoxDecoration(
        color: KodiraColors.neutral200,
        borderRadius: BorderRadius.circular(KodiraRadius.sm),
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
                Icons.inventory_2_outlined,
                size: 32,
                color: KodiraColors.neutral500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Latihan belum tersedia',
              textAlign: TextAlign.center,
              style: KodiraTextStyles.h2.copyWith(
                color: KodiraColors.neutral900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Latihan untuk level ini belum tersedia. Kembali ke materi '
              'untuk melanjutkan.',
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
                style: _primaryButtonStyle(),
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
                style: _primaryButtonStyle(),
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

ButtonStyle _primaryButtonStyle() {
  return ElevatedButton.styleFrom(
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
  );
}
