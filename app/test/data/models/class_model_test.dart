import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/class_model.dart';

void main() {
  group('ClassModel', () {
    test('fromMap parses correctly', () {
      final map = {
        'id': 'c1',
        'name': 'PTIK B 2024',
        'code': 'PTIK24',
        'description': 'Default class',
        'created_at': '2026-11-10T00:00:00Z',
      };
      final model = ClassModel.fromMap(map);
      expect(model.id, 'c1');
      expect(model.name, 'PTIK B 2024');
      expect(model.code, 'PTIK24');
      expect(model.description, 'Default class');
    });

    test('fromMap handles null description', () {
      final map = {
        'id': 'c1',
        'name': 'X',
        'code': 'XXXXXX',
        'description': null,
        'created_at': '2026-11-10T00:00:00Z',
      };
      final model = ClassModel.fromMap(map);
      expect(model.description, isNull);
    });

    test('equality by id+name+code', () {
      final a = ClassModel(
        id: 'c1',
        name: 'X',
        code: 'XXXXXX',
        createdAt: DateTime(2026),
      );
      final b = ClassModel(
        id: 'c1',
        name: 'X',
        code: 'XXXXXX',
        createdAt: DateTime(2027), // different date, still equal
      );
      expect(a, b);
    });
  });
}
