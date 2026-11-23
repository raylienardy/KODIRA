import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/features/exercise/widgets/fill_blank_exercise_view.dart';

void main() {
  group('FillBlankExerciseView Tests', () {
    testWidgets(
      'renders fill_in_the_blank view, selects slot, picks option and validates',
      (tester) async {
        final data = FillBlankExerciseData.fromJson({
          'language': 'cpp',
          'code_template': 'int main() {\n  ___ x = 10;\n  return 0;\n}',
          'blanks': [
            {
              'id': 'b1',
              'answer': 'int',
              'options': ['int', 'float', 'double'],
            },
          ],
        });

        Map<String, String> currentAnswers = {};

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FillBlankExerciseView(
                data: data,
                onAnswersChanged: (answers) {
                  currentAnswers = answers;
                },
              ),
            ),
          ),
        );

        // Verify template rendered with blank placeholder
        expect(find.text('___'), findsOneWidget);

        // Tap the blank slot
        await tester.tap(find.text('___'));
        await tester.pumpAndSettle();

        // Verify option chips appear
        expect(find.text('int'), findsWidgets);
        expect(find.text('float'), findsOneWidget);

        // Tap 'int' option
        // The options are wrapped in ActionChip with label Text('int')
        // There might be multiple 'int' if code template has int or answer has int. Let's tap the option chip.
        await tester.tap(find.widgetWithText(ActionChip, 'int').first);
        await tester.pumpAndSettle();

        // Verify answer recorded
        expect(currentAnswers['b1'], 'int');
      },
    );
  });
}
