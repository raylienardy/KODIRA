import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/errors/error_type.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/ai_provider.dart';

class HintBottomSheet extends ConsumerStatefulWidget {
  final int levelId;
  final String topic;
  final String userCode;

  const HintBottomSheet({
    super.key,
    required this.levelId,
    required this.topic,
    required this.userCode,
  });

  @override
  ConsumerState<HintBottomSheet> createState() => _HintBottomSheetState();
}

class _HintBottomSheetState extends ConsumerState<HintBottomSheet> {
  bool _isRequesting = false;
  late int _successfulAttempts;

  @override
  void initState() {
    super.initState();
    _successfulAttempts = ref.read(hintAttemptsProvider)[widget.levelId] ?? 0;
  }

  Future<void> _requestHint(int hintLevel) async {
    if (_isRequesting || hintLevel > 3) {
      return;
    }
    if (_successfulAttempts >= 3 || hintLevel != _successfulAttempts + 1) {
      return;
    }

    setState(() => _isRequesting = true);
    await ref
        .read(hintProvider(widget.levelId).notifier)
        .requestHint(
          topic: widget.topic,
          userCode: widget.userCode,
          hintLevel: hintLevel,
        );
    if (!mounted) return;

    final result = ref.read(hintProvider(widget.levelId));
    if (!result.hasError && result.valueOrNull?.isNotEmpty == true) {
      final current = ref.read(hintAttemptsProvider);
      ref.read(hintAttemptsProvider.notifier).state = {
        ...current,
        widget.levelId: hintLevel,
      };
      _successfulAttempts = hintLevel;
    }
    setState(() => _isRequesting = false);
  }

  @override
  Widget build(BuildContext context) {
    final hintState = ref.watch(hintProvider(widget.levelId));
    final attempts = _successfulAttempts;
    final nextLevel = attempts + 1;
    final hasHint =
        hintState.hasValue &&
        hintState.valueOrNull != null &&
        hintState.valueOrNull!.isNotEmpty;
    final isMaxed = attempts >= 3;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Minta Hint',
                    style: KodiraTextStyles.h2.copyWith(
                      color: KodiraColors.neutral900,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Tutup hint',
                  child: IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isRequesting || hintState.isLoading)
              const KodiraLoadingWidget(message: 'Menyiapkan hint...')
            else if (hintState.hasError)
              KodiraErrorWidget(
                error: ErrorType.fromException(hintState.error!),
                onRetry: () => _requestHint(nextLevel),
              )
            else if (hasHint) ...[
              Semantics(
                container: true,
                liveRegion: true,
                label: 'Hint level $attempts: ${hintState.valueOrNull}',
                child: ExcludeSemantics(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: KodiraColors.primary100,
                      borderRadius: BorderRadius.circular(KodiraRadius.lg),
                      border: Border.all(color: KodiraColors.primary500),
                    ),
                    child: Text(
                      hintState.valueOrNull!,
                      style: KodiraTextStyles.body.copyWith(
                        color: KodiraColors.neutral900,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (!isMaxed && !_isRequesting && !hintState.isLoading)
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: 'Tombol minta hint level $nextLevel',
                  child: FilledButton.icon(
                    onPressed: () => _requestHint(nextLevel),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text(
                      hasHint
                          ? 'Minta Hint Level $nextLevel'
                          : 'Minta Hint Level 1',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: KodiraColors.primary700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            if (isMaxed) ...[
              Semantics(
                label: 'Hint level maksimal sudah digunakan',
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KodiraColors.neutral100,
                    borderRadius: BorderRadius.circular(KodiraRadius.md),
                  ),
                  child: Text(
                    'Hint maksimal sudah digunakan',
                    textAlign: TextAlign.center,
                    style: KodiraTextStyles.body.copyWith(
                      color: KodiraColors.neutral700,
                    ),
                  ),
                ),
              ),
            ],
            if (hasHint || isMaxed) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: KodiraColors.neutral900,
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
