import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/exercise_model.dart';

/// Pemetaan field pada model exercise (P4-007).
///
/// CATATAN: isi `payload` disimpan apa adanya sebagai `Map<String, dynamic>`.
/// Model ini tidak mem-parse isi payload, sehinggaparsing isi payload
/// (options/answer/explanation) diuji lewat layer pemanggil di
/// `quiz_screen.dart`, bukan di sini.
void main() {
  group('ExerciseModel.fromJson', () {
    test('memetakan seluruh field exercise quiz', () {
      final ExerciseModel model = ExerciseModel.fromJson(<String, dynamic>{
        'id': 316,
        'level_id': 1,
        'type': 'quiz',
        'prompt': 'Soal: Apa fungsi dari baris #include <iostream>?',
        'payload': <String, dynamic>{
          'options': <dynamic>[
            <String, dynamic>{'id': 'a', 'text': 'Opsi A'},
            <String, dynamic>{'id': 'b', 'text': 'Opsi B'},
          ],
          'answer': 'b',
          'explanation': 'Penjelasan singkat.',
          'language': 'cpp',
        },
        'difficulty': 3,
        'created_at': '2026-10-20T10:00:00Z',
      });

      expect(model.id, 316);
      expect(model.levelId, 1);
      expect(model.type, 'quiz');
      expect(model.prompt, startsWith('Soal:'));
      expect(model.difficulty, 3);
      expect(model.createdAt, DateTime.utc(2026, 10, 20, 10));
    });

    test('payload null tidak membuat model error', () {
      final ExerciseModel model = ExerciseModel.fromJson(<String, dynamic>{
        'id': 1,
        'level_id': 1,
        'type': 'drag_drop',
        'prompt': 'Susun kode Hello World',
        'payload': null,
        'difficulty': null,
        'created_at': '2026-10-20T10:00:00Z',
      });

      expect(model.payload, isNull);
      expect(model.difficulty, isNull);
      expect(model.type, 'drag_drop');
    });

    test('isi payload quiz disimpan apa adanya tanpa diubah', () {
      final Map<String, dynamic> payload = <String, dynamic>{
        'options': <dynamic>[
          <String, dynamic>{'id': 'a', 'text': 'Opsi A'},
          <String, dynamic>{'id': 'b', 'text': 'Opsi B'},
          <String, dynamic>{'id': 'c', 'text': 'Opsi C'},
          <String, dynamic>{'id': 'd', 'text': 'Opsi D'},
        ],
        'answer': 'c',
        'explanation': 'Penjelasan singkat.',
        'language': 'java',
      };

      final ExerciseModel model = ExerciseModel.fromJson(<String, dynamic>{
        'id': 400,
        'level_id': 40,
        'type': 'quiz',
        'prompt': 'Soal: Apa itu class?',
        'payload': payload,
        'difficulty': 4,
        'created_at': '2026-10-20T10:00:00Z',
      });

      expect(model.payload, isNotNull);
      expect(model.payload!['answer'], 'c');
      expect(model.payload!['language'], 'java');
      expect(model.payload!['explanation'], 'Penjelasan singkat.');
      expect((model.payload!['options'] as List<dynamic>).length, 4);
    });

    test('payload tanpa kunci answer tetap aman', () {
      final ExerciseModel model = ExerciseModel.fromJson(<String, dynamic>{
        'id': 5,
        'level_id': 2,
        'type': 'drag_drop',
        'prompt': 'Susun deklarasi fungsi',
        'payload': <String, dynamic>{
          'tokens': <dynamic>[
            <String, dynamic>{'id': 't1', 'text': 'void'},
          ],
        },
        'difficulty': 2,
        'created_at': '2026-10-20T10:00:00Z',
      });

      expect(model.payload!.containsKey('answer'), isFalse);
      expect((model.payload!['tokens'] as List<dynamic>).length, 1);
    });
  });

  group('ExerciseModel.fromSupabase', () {
    test('memetakan baris database bertipe drag_drop', () {
      final ExerciseModel model = ExerciseModel.fromSupabase(<String, dynamic>{
        'id': 1,
        'level_id': 1,
        'type': 'drag_drop',
        'prompt': 'Susun kode Hello World',
        'payload': <String, dynamic>{
          'tokens': <dynamic>[
            <String, dynamic>{'id': 't1', 'text': '#include <iostream>'},
          ],
          'answer': <dynamic>['t1'],
          'language': 'cpp',
        },
        'difficulty': 1,
        'created_at': '2026-10-16T08:22:43Z',
      });

      expect(model.id, 1);
      expect(model.levelId, 1);
      expect(model.type, 'drag_drop');
      expect(model.difficulty, 1);
      expect(model.payload!['language'], 'cpp');
      expect(model.createdAt, DateTime.utc(2026, 10, 16, 8, 22, 43));
    });

    test('baris database tanpa payload menghasilkan payload null', () {
      final ExerciseModel model = ExerciseModel.fromSupabase(<String, dynamic>{
        'id': 9,
        'level_id': 3,
        'type': 'quiz',
        'prompt': 'Soal tanpa payload',
        'payload': null,
        'difficulty': null,
        'created_at': '2026-10-16T08:22:43Z',
      });

      expect(model.payload, isNull);
      expect(model.difficulty, isNull);
      expect(model.type, 'quiz');
    });
  });
}
