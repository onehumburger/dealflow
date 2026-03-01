import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/teeth_service.dart';

void main() {
  late TeethService service;

  setUp(() {
    service = TeethService();
  });

  group('ToothInfo data class', () {
    test('has required fields', () {
      const t = ToothInfo(
        position: 'A',
        name: 'Upper Right Central Incisor',
        jaw: 'upper',
        side: 'right',
        typicalEruptionMonths: 8,
        displayOrder: 1,
      );
      expect(t.position, 'A');
      expect(t.name, 'Upper Right Central Incisor');
      expect(t.jaw, 'upper');
      expect(t.side, 'right');
      expect(t.typicalEruptionMonths, 8);
      expect(t.displayOrder, 1);
    });
  });

  group('allTeeth', () {
    test('contains exactly 20 teeth', () {
      expect(service.allTeeth.length, 20);
    });

    test('all positions are unique A-T', () {
      final positions = service.allTeeth.map((t) => t.position).toSet();
      expect(positions.length, 20);
      for (var i = 0; i < 20; i++) {
        final letter = String.fromCharCode('A'.codeUnitAt(0) + i);
        expect(positions, contains(letter));
      }
    });

    test('contains 10 upper and 10 lower teeth', () {
      final upper = service.allTeeth.where((t) => t.jaw == 'upper');
      final lower = service.allTeeth.where((t) => t.jaw == 'lower');
      expect(upper.length, 10);
      expect(lower.length, 10);
    });

    test('each jaw has 5 right and 5 left teeth', () {
      for (final jaw in ['upper', 'lower']) {
        final jawTeeth = service.allTeeth.where((t) => t.jaw == jaw);
        final right = jawTeeth.where((t) => t.side == 'right');
        final left = jawTeeth.where((t) => t.side == 'left');
        expect(right.length, 5, reason: '$jaw jaw should have 5 right teeth');
        expect(left.length, 5, reason: '$jaw jaw should have 5 left teeth');
      }
    });

    test('display orders are unique 1-20', () {
      final orders = service.allTeeth.map((t) => t.displayOrder).toSet();
      expect(orders.length, 20);
      for (var i = 1; i <= 20; i++) {
        expect(orders, contains(i));
      }
    });

    test('all eruption ages are between 6 and 33 months', () {
      for (final t in service.allTeeth) {
        expect(t.typicalEruptionMonths, greaterThanOrEqualTo(6),
            reason: '${t.position} eruption age should be >= 6');
        expect(t.typicalEruptionMonths, lessThanOrEqualTo(33),
            reason: '${t.position} eruption age should be <= 33');
      }
    });
  });

  group('getTeethForJaw', () {
    test('returns 10 upper teeth', () {
      final upper = service.getTeethForJaw('upper');
      expect(upper.length, 10);
      expect(upper.every((t) => t.jaw == 'upper'), isTrue);
    });

    test('returns 10 lower teeth', () {
      final lower = service.getTeethForJaw('lower');
      expect(lower.length, 10);
      expect(lower.every((t) => t.jaw == 'lower'), isTrue);
    });

    test('returns empty for invalid jaw', () {
      final result = service.getTeethForJaw('middle');
      expect(result, isEmpty);
    });
  });

  group('getToothByPosition', () {
    test('returns correct tooth for valid position', () {
      final tooth = service.getToothByPosition('A');
      expect(tooth, isNotNull);
      expect(tooth!.position, 'A');
      expect(tooth.name, contains('Central Incisor'));
    });

    test('returns null for invalid position', () {
      expect(service.getToothByPosition('Z'), isNull);
    });

    test('is case-insensitive', () {
      final tooth = service.getToothByPosition('a');
      expect(tooth, isNotNull);
      expect(tooth!.position, 'A');
    });
  });

  group('teethByEruptionOrder', () {
    test('returns all 20 teeth sorted by eruption age', () {
      final sorted = service.teethByEruptionOrder;
      expect(sorted.length, 20);
      for (var i = 1; i < sorted.length; i++) {
        expect(
          sorted[i].typicalEruptionMonths,
          greaterThanOrEqualTo(sorted[i - 1].typicalEruptionMonths),
          reason: 'teeth should be sorted by eruption age',
        );
      }
    });

    test('lower central incisors are among the first to erupt', () {
      final sorted = service.teethByEruptionOrder;
      final firstTwoAges =
          sorted.take(4).map((t) => t.typicalEruptionMonths).toSet();
      // Lower central incisors erupt at ~6 months
      expect(firstTwoAges, contains(6));
    });
  });

  group('expectedEruptedCount', () {
    test('returns 0 for a newborn (0 months)', () {
      expect(service.expectedEruptedCount(0), 0);
    });

    test('returns some teeth for 8-month-old', () {
      final count = service.expectedEruptedCount(8);
      expect(count, greaterThan(0));
      expect(count, lessThan(20));
    });

    test('returns 20 for 36-month-old', () {
      expect(service.expectedEruptedCount(36), 20);
    });

    test('count increases with age', () {
      final at6 = service.expectedEruptedCount(6);
      final at12 = service.expectedEruptedCount(12);
      final at24 = service.expectedEruptedCount(24);
      expect(at12, greaterThanOrEqualTo(at6));
      expect(at24, greaterThanOrEqualTo(at12));
    });
  });
}
