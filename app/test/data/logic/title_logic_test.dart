import 'package:flutter_test/flutter_test.dart';

import 'package:kodira/data/logic/title_logic.dart';

void main() {
  group('TitleLogic.fromTotalXp', () {
    test('fromTotalXp_zero_isPemula', () {
      expect(TitleLogic.fromTotalXp(0), UserTitle.pemula);
    });

    test('fromTotalXp_499_isPemula', () {
      expect(TitleLogic.fromTotalXp(499), UserTitle.pemula);
    });

    test('fromTotalXp_500_isMenengah', () {
      expect(TitleLogic.fromTotalXp(500), UserTitle.menengah);
    });

    test('fromTotalXp_1499_isMenengah', () {
      expect(TitleLogic.fromTotalXp(1499), UserTitle.menengah);
    });

    test('fromTotalXp_1500_isMahir', () {
      expect(TitleLogic.fromTotalXp(1500), UserTitle.mahir);
    });

    test('fromTotalXp_3499_isMahir', () {
      expect(TitleLogic.fromTotalXp(3499), UserTitle.mahir);
    });

    test('fromTotalXp_3500_isMaster', () {
      expect(TitleLogic.fromTotalXp(3500), UserTitle.master);
    });

    test('fromTotalXp_6999_isMaster', () {
      expect(TitleLogic.fromTotalXp(6999), UserTitle.master);
    });

    test('fromTotalXp_7000_isGrandMaster', () {
      expect(TitleLogic.fromTotalXp(7000), UserTitle.grandMaster);
    });

    test('fromTotalXp_negative_isPemula', () {
      expect(TitleLogic.fromTotalXp(-100), UserTitle.pemula);
    });
  });

  group('TitleLogic.label', () {
    test('returns Indonesian labels for all tiers', () {
      expect(TitleLogic.label(UserTitle.pemula), 'Pemula');
      expect(TitleLogic.label(UserTitle.menengah), 'Menengah');
      expect(TitleLogic.label(UserTitle.mahir), 'Mahir');
      expect(TitleLogic.label(UserTitle.master), 'Master');
      expect(TitleLogic.label(UserTitle.grandMaster), 'Grand Master');
    });
  });

  group('TitleLogic.emoji', () {
    test('returns correct emoji for all tiers', () {
      expect(TitleLogic.emoji(UserTitle.pemula), '🌱');
      expect(TitleLogic.emoji(UserTitle.menengah), '🌿');
      expect(TitleLogic.emoji(UserTitle.mahir), '🌳');
      expect(TitleLogic.emoji(UserTitle.master), '🏆');
      expect(TitleLogic.emoji(UserTitle.grandMaster), '👑');
    });
  });

  group('TitleLogic.description', () {
    test('returns non-empty description for all tiers', () {
      for (final title in UserTitle.values) {
        expect(TitleLogic.description(title), isNotEmpty);
      }
    });
  });
}
