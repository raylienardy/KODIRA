import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/ai_provider.dart';

class FeedbackBottomSheet extends ConsumerWidget {
  final int levelId;
  final String topic;
  final String userCode;
  final String expectedAnswer;
  final bool isCorrect;

  const FeedbackBottomSheet({
    super.key,
    required this.levelId,
    required this.topic,
    required this.userCode,
    required this.expectedAnswer,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = FeedbackRequest(
      levelId: levelId,
      topic: topic,
      userCode: userCode,
      expectedAnswer: expectedAnswer,
      isCorrect: isCorrect,
    );
    final feedbackState = ref.watch(feedbackProvider(request));

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
                    'Feedback AI',
                    style: KodiraTextStyles.h2.copyWith(
                      color: KodiraColors.neutral900,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Tutup feedback AI',
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
            if (feedbackState.isLoading)
              const KodiraLoadingWidget(message: 'Menyiapkan feedback...')
            else
              Semantics(
                container: true,
                liveRegion: true,
                label: feedbackState.hasError
                    ? 'Feedback AI tidak tersedia saat ini'
                    : 'Feedback AI: ${feedbackState.valueOrNull ?? 'Feedback AI tidak tersedia saat ini'}',
                child: ExcludeSemantics(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: KodiraColors.neutral100,
                      borderRadius: BorderRadius.circular(KodiraRadius.lg),
                      border: Border.all(color: KodiraColors.neutral200),
                    ),
                    child: Text(
                      feedbackState.hasError ||
                              (feedbackState.valueOrNull?.isEmpty ?? true)
                          ? 'Feedback AI tidak tersedia saat ini'
                          : feedbackState.valueOrNull!,
                      style: KodiraTextStyles.body.copyWith(
                        color: KodiraColors.neutral900,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
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
        ),
      ),
    );
  }
}
