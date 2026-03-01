/// Data model for a single primary tooth.
class ToothInfo {
  /// Position label using standard dental notation (A-T).
  final String position;

  /// Human-readable name.
  final String name;

  /// Jaw: 'upper' or 'lower'.
  final String jaw;

  /// Side: 'right' or 'left'.
  final String side;

  /// Typical eruption age in months.
  final int typicalEruptionMonths;

  /// 1-based order used for sorting / display.
  final int displayOrder;

  const ToothInfo({
    required this.position,
    required this.name,
    required this.jaw,
    required this.side,
    required this.typicalEruptionMonths,
    required this.displayOrder,
  });
}

/// Pure logic service for the teething map.
///
/// Provides the canonical list of 20 primary teeth with dental notation (A-T),
/// human-readable names, jaw/side positions, and typical eruption ages.
class TeethService {
  /// All 20 primary teeth.
  List<ToothInfo> get allTeeth => _allTeeth;

  /// Get teeth for a specific jaw ('upper' or 'lower').
  List<ToothInfo> getTeethForJaw(String jaw) {
    return _allTeeth.where((t) => t.jaw == jaw).toList();
  }

  /// Get a tooth by its position label (A-T).
  ToothInfo? getToothByPosition(String position) {
    final upper = position.toUpperCase();
    try {
      return _allTeeth.firstWhere((t) => t.position == upper);
    } catch (_) {
      return null;
    }
  }

  /// Returns teeth sorted by typical eruption age.
  List<ToothInfo> get teethByEruptionOrder {
    final sorted = List<ToothInfo>.from(_allTeeth);
    sorted.sort((a, b) => a.typicalEruptionMonths.compareTo(b.typicalEruptionMonths));
    return sorted;
  }

  /// Returns the count of teeth expected to have erupted by the given age.
  int expectedEruptedCount(int babyAgeMonths) {
    return _allTeeth.where((t) => t.typicalEruptionMonths <= babyAgeMonths).length;
  }

  // ── Pre-populated primary teeth data (Universal / Palmer notation A-T) ──
  //
  // Upper right → Upper left  (A-J)
  // Lower left  → Lower right (K-T)
  //
  // Eruption ages are based on AAP / ADA typical ranges.

  static const _allTeeth = <ToothInfo>[
    // ── Upper jaw (right to left) ──
    ToothInfo(
      position: 'A',
      name: 'Upper Right Central Incisor',
      jaw: 'upper',
      side: 'right',
      typicalEruptionMonths: 8,
      displayOrder: 1,
    ),
    ToothInfo(
      position: 'B',
      name: 'Upper Right Lateral Incisor',
      jaw: 'upper',
      side: 'right',
      typicalEruptionMonths: 10,
      displayOrder: 2,
    ),
    ToothInfo(
      position: 'C',
      name: 'Upper Right Canine',
      jaw: 'upper',
      side: 'right',
      typicalEruptionMonths: 18,
      displayOrder: 3,
    ),
    ToothInfo(
      position: 'D',
      name: 'Upper Right First Molar',
      jaw: 'upper',
      side: 'right',
      typicalEruptionMonths: 14,
      displayOrder: 4,
    ),
    ToothInfo(
      position: 'E',
      name: 'Upper Right Second Molar',
      jaw: 'upper',
      side: 'right',
      typicalEruptionMonths: 24,
      displayOrder: 5,
    ),
    ToothInfo(
      position: 'F',
      name: 'Upper Left Central Incisor',
      jaw: 'upper',
      side: 'left',
      typicalEruptionMonths: 8,
      displayOrder: 6,
    ),
    ToothInfo(
      position: 'G',
      name: 'Upper Left Lateral Incisor',
      jaw: 'upper',
      side: 'left',
      typicalEruptionMonths: 10,
      displayOrder: 7,
    ),
    ToothInfo(
      position: 'H',
      name: 'Upper Left Canine',
      jaw: 'upper',
      side: 'left',
      typicalEruptionMonths: 18,
      displayOrder: 8,
    ),
    ToothInfo(
      position: 'I',
      name: 'Upper Left First Molar',
      jaw: 'upper',
      side: 'left',
      typicalEruptionMonths: 14,
      displayOrder: 9,
    ),
    ToothInfo(
      position: 'J',
      name: 'Upper Left Second Molar',
      jaw: 'upper',
      side: 'left',
      typicalEruptionMonths: 24,
      displayOrder: 10,
    ),

    // ── Lower jaw (left to right) ──
    ToothInfo(
      position: 'K',
      name: 'Lower Left Central Incisor',
      jaw: 'lower',
      side: 'left',
      typicalEruptionMonths: 6,
      displayOrder: 11,
    ),
    ToothInfo(
      position: 'L',
      name: 'Lower Left Lateral Incisor',
      jaw: 'lower',
      side: 'left',
      typicalEruptionMonths: 10,
      displayOrder: 12,
    ),
    ToothInfo(
      position: 'M',
      name: 'Lower Left Canine',
      jaw: 'lower',
      side: 'left',
      typicalEruptionMonths: 18,
      displayOrder: 13,
    ),
    ToothInfo(
      position: 'N',
      name: 'Lower Left First Molar',
      jaw: 'lower',
      side: 'left',
      typicalEruptionMonths: 14,
      displayOrder: 14,
    ),
    ToothInfo(
      position: 'O',
      name: 'Lower Left Second Molar',
      jaw: 'lower',
      side: 'left',
      typicalEruptionMonths: 24,
      displayOrder: 15,
    ),
    ToothInfo(
      position: 'P',
      name: 'Lower Right Central Incisor',
      jaw: 'lower',
      side: 'right',
      typicalEruptionMonths: 6,
      displayOrder: 16,
    ),
    ToothInfo(
      position: 'Q',
      name: 'Lower Right Lateral Incisor',
      jaw: 'lower',
      side: 'right',
      typicalEruptionMonths: 10,
      displayOrder: 17,
    ),
    ToothInfo(
      position: 'R',
      name: 'Lower Right Canine',
      jaw: 'lower',
      side: 'right',
      typicalEruptionMonths: 18,
      displayOrder: 18,
    ),
    ToothInfo(
      position: 'S',
      name: 'Lower Right First Molar',
      jaw: 'lower',
      side: 'right',
      typicalEruptionMonths: 14,
      displayOrder: 19,
    ),
    ToothInfo(
      position: 'T',
      name: 'Lower Right Second Molar',
      jaw: 'lower',
      side: 'right',
      typicalEruptionMonths: 24,
      displayOrder: 20,
    ),
  ];
}
