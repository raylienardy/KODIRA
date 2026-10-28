import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../exercise/providers/exercise_provider.dart';
import '../../exercise/screens/drag_drop_screen.dart';
import '../../exercise/screens/code_editor_screen.dart';
import '../providers/material_provider.dart';
import '../../../data/models/material_model.dart';
import '../../../core/errors/error_type.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../ai_mentor/widgets/hint_bottom_sheet.dart';

class MaterialScreen extends ConsumerStatefulWidget {
  final int levelId;
  final String levelTitle;

  const MaterialScreen({
    required this.levelId,
    required this.levelTitle,
    super.key,
  });

  @override
  ConsumerState<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends ConsumerState<MaterialScreen> {
  int _currentSlideIndex = 0;
  bool _isOpeningExercise = false;

  Future<void> _openExercise() async {
    if (_isOpeningExercise) return;

    setState(() => _isOpeningExercise = true);
    try {
      final exercises = await ref.read(
        dragDropExercisesProvider(widget.levelId).future,
      );
      if (!mounted) return;

      if (exercises.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Latihan belum tersedia untuk level ini'),
          ),
        );
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DragDropScreen(levelId: widget.levelId),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat latihan. Coba lagi.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningExercise = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(materialsByLevelProvider(widget.levelId));

    return Scaffold(
      backgroundColor: KodiraColors.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            _HeaderWidget(
              levelTitle: widget.levelTitle,
              currentSlide: _currentSlideIndex,
              materialsAsync: materialsAsync,
            ),
            Expanded(
              child: materialsAsync.when(
                data: (materials) {
                  if (materials.isEmpty) {
                    return const KodiraEmptyWidget(
                      icon: Icons.menu_book_outlined,
                      title: 'Belum ada materi untuk level ini',
                    );
                  }
                  final material = materials[_currentSlideIndex];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _MaterialCard(material: material),
                  );
                },
                loading: () =>
                    const KodiraLoadingWidget(message: 'Memuat materi'),
                error: (e, _) => KodiraErrorWidget(
                  error: ErrorType.fromException(e),
                  onRetry: () =>
                      ref.refresh(materialsByLevelProvider(widget.levelId)),
                ),
              ),
            ),
            if (materialsAsync.hasValue && materialsAsync.value!.isNotEmpty)
              _NavigationBar(
                currentIndex: _currentSlideIndex,
                total: materialsAsync.value!.length,
                isLoading: _isOpeningExercise,
                onPrev: () => setState(() => _currentSlideIndex--),
                onNext: () => setState(() => _currentSlideIndex++),
                onFinish: _openExercise,
                onCodeEditor: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CodeEditorScreen(
                        levelId: widget.levelId,
                        levelTitle: widget.levelTitle,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton:
          materialsAsync.hasValue &&
              materialsAsync.value!.isNotEmpty &&
              _currentSlideIndex < materialsAsync.value!.length - 1
          ? _HintFab(levelId: widget.levelId, topic: widget.levelTitle)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

// -------------------------------------------------------------------
class _HeaderWidget extends StatelessWidget {
  final String levelTitle;
  final int currentSlide;
  final AsyncValue<List<MaterialModel>> materialsAsync;

  const _HeaderWidget({
    required this.levelTitle,
    required this.currentSlide,
    required this.materialsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final total = materialsAsync.maybeWhen(
      data: (v) => v.length,
      orElse: () => 0,
    );
    final progress = total == 0 ? 0.0 : (currentSlide + 1) / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: KodiraColors.neutral200, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: KodiraColors.neutral100,
                borderRadius: BorderRadius.circular(KodiraRadius.sm + 2),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: KodiraColors.neutral900,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  levelTitle,
                  style: KodiraTextStyles.h3.copyWith(
                    color: KodiraColors.neutral900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Materi • ${currentSlide + 1} dari $total',
                  style: KodiraTextStyles.caption.copyWith(
                    color: KodiraColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: KodiraColors.neutral200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: KodiraColors.primary700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
class _MaterialCard extends StatelessWidget {
  final MaterialModel material;

  const _MaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KodiraRadius.lg),
        boxShadow: KodiraShadows.elevation2,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (material.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                material.title!,
                style: KodiraTextStyles.h3.copyWith(
                  color: KodiraColors.neutral900,
                ),
              ),
            ),
          if (material.content != null)
            Text(
              material.content!,
              style: KodiraTextStyles.body.copyWith(
                color: KodiraColors.neutral700,
                height: 1.6,
              ),
            ),
          if (material.codeSnippet != null)
            _CodeBlock(code: material.codeSnippet!),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
class _CodeBlock extends StatelessWidget {
  final String code;

  const _CodeBlock({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KodiraColors.codeBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 11,
          height: 1.7,
          color: Colors.white,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
class _NavigationBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final bool isLoading;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onFinish;
  final VoidCallback onCodeEditor;

  const _NavigationBar({
    required this.currentIndex,
    required this.total,
    required this.isLoading,
    required this.onPrev,
    required this.onNext,
    required this.onFinish,
    required this.onCodeEditor,
  });

  bool get isLast => currentIndex == total - 1;

  @override
  Widget build(BuildContext context) {
    final isFinish = isLast;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: KodiraColors.neutral200, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (currentIndex > 0)
                TextButton(
                  onPressed: onPrev,
                  child: const Text(
                    'Sebelumnya',
                    style: TextStyle(color: KodiraColors.neutral700),
                  ),
                ),
              const Spacer(),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isFinish && isLoading
                      ? null
                      : (isFinish ? onFinish : onNext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KodiraColors.primary700,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: KodiraColors.primary700,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KodiraRadius.md),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: isFinish && isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(isFinish ? 'Lanjut ke Latihan' : 'Lanjut'),
                ),
              ),
            ],
          ),
          if (isLast) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCodeEditor,
                icon: const Icon(Icons.code, size: 20),
                label: const Text('Latihan Coding'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: KodiraColors.primary700,
                  side: const BorderSide(color: KodiraColors.primary700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KodiraRadius.md),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
class _HintFab extends StatelessWidget {
  final int levelId;
  final String topic;

  const _HintFab({required this.levelId, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tombol minta hint untuk level $levelId',
      child: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) =>
                HintBottomSheet(levelId: levelId, topic: topic, userCode: ''),
          );
        },
        backgroundColor: KodiraColors.primary700,
        foregroundColor: Colors.white,
        elevation: 0,
        label: const Text(
          'Minta Hint',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        icon: const Icon(
          Icons.lightbulb_outline,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
