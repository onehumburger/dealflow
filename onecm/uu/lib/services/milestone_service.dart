/// A pre-populated expected milestone from pediatric guidelines.
class ExpectedMilestone {
  final String category; // motor, language, social, cognitive
  final String title;
  final String description;
  final int expectedAgeMonths;

  const ExpectedMilestone({
    required this.category,
    required this.title,
    required this.description,
    required this.expectedAgeMonths,
  });
}

/// A delay alert for a milestone that has not been achieved by its expected window.
class MilestoneDelayAlert {
  final ExpectedMilestone milestone;
  final String message;
  final String severity; // 'info', 'gentle', 'concern'

  const MilestoneDelayAlert({
    required this.milestone,
    required this.message,
    required this.severity,
  });
}

/// Pure logic service for milestone tracking.
///
/// Provides a pre-populated list of expected developmental milestones
/// across motor, language, social, and cognitive categories for ages 0-36 months.
/// Methods for checking upcoming milestones, overdue milestones, and delay alerts.
class MilestoneService {
  /// Calculate baby's age in completed months.
  static int calculateBabyAgeMonths(DateTime dateOfBirth, DateTime now) {
    int months = (now.year - dateOfBirth.year) * 12 +
        (now.month - dateOfBirth.month);
    if (now.day < dateOfBirth.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  /// All expected milestones across the 0-36 month range.
  List<ExpectedMilestone> get allExpectedMilestones => _allMilestones;

  /// Get expected milestones for a baby of a given age (in months).
  /// Returns milestones with expectedAgeMonths <= [ageMonths].
  /// Optionally filter by [category].
  List<ExpectedMilestone> getExpectedMilestonesForAge(
    int ageMonths, {
    String? category,
  }) {
    return _allMilestones.where((m) {
      final ageMatch = m.expectedAgeMonths <= ageMonths;
      final catMatch = category == null || m.category == category;
      return ageMatch && catMatch;
    }).toList();
  }

  /// Get milestones expected within the next 1-2 months from current age.
  /// Excludes milestones already achieved (by title).
  List<ExpectedMilestone> getUpcomingMilestones({
    required int babyAgeMonths,
    required Set<String> achievedTitles,
  }) {
    return _allMilestones.where((m) {
      final isUpcoming = m.expectedAgeMonths > babyAgeMonths &&
          m.expectedAgeMonths <= babyAgeMonths + 2;
      final notAchieved = !achievedTitles.contains(m.title);
      return isUpcoming && notAchieved;
    }).toList();
  }

  /// Get milestones that are overdue: expected age + buffer <= current age,
  /// and not yet achieved.
  List<ExpectedMilestone> getOverdueMilestones({
    required int babyAgeMonths,
    required Set<String> achievedTitles,
    int bufferMonths = 2,
  }) {
    return _allMilestones.where((m) {
      final isOverdue = m.expectedAgeMonths + bufferMonths <= babyAgeMonths;
      final notAchieved = !achievedTitles.contains(m.title);
      return isOverdue && notAchieved;
    }).toList();
  }

  /// Generate gentle delay alerts for milestones not achieved by expected age.
  ///
  /// Severity levels:
  /// - 'info': milestone is 1-3 months overdue (just a heads-up)
  /// - 'gentle': milestone is 4-6 months overdue (worth discussing with pediatrician)
  /// - 'concern': milestone is 7+ months overdue (recommend professional evaluation)
  List<MilestoneDelayAlert> getDelayAlerts({
    required int babyAgeMonths,
    required Set<String> achievedTitles,
  }) {
    final alerts = <MilestoneDelayAlert>[];

    for (final m in _allMilestones) {
      if (achievedTitles.contains(m.title)) continue;

      final delayMonths = babyAgeMonths - m.expectedAgeMonths;
      if (delayMonths <= 0) continue;

      String severity;
      String message;

      if (delayMonths <= 3) {
        severity = 'info';
        message =
            '${m.title} is typically expected around ${m.expectedAgeMonths} months. '
            'Every baby develops at their own pace.';
      } else if (delayMonths <= 6) {
        severity = 'gentle';
        message =
            '${m.title} is usually seen by ${m.expectedAgeMonths} months. '
            'You might want to mention this at your next pediatrician visit.';
      } else {
        severity = 'concern';
        message =
            '${m.title} is typically expected by ${m.expectedAgeMonths} months. '
            'Consider discussing this with your pediatrician for guidance.';
      }

      alerts.add(MilestoneDelayAlert(
        milestone: m,
        message: message,
        severity: severity,
      ));
    }

    return alerts;
  }

  // ── Pre-populated milestone data ──────────────────────────────────────

  static const _allMilestones = <ExpectedMilestone>[
    // ── Motor milestones ──
    ExpectedMilestone(
      category: 'motor',
      title: 'Head control',
      description: 'Holds head steady when held upright',
      expectedAgeMonths: 2,
    ),
    ExpectedMilestone(
      category: 'motor',
      title: 'Pushes up on arms',
      description: 'Pushes up on arms when lying on tummy',
      expectedAgeMonths: 3,
    ),
    ExpectedMilestone(
      category: 'motor',
      title: 'Rolling over',
      description: 'Rolls from tummy to back and back to tummy',
      expectedAgeMonths: 4,
    ),
    ExpectedMilestone(
      category: 'motor',
      title: 'Sitting with support',
      description: 'Sits with support or propping',
      expectedAgeMonths: 5,
    ),
    ExpectedMilestone(
      category: 'motor',
      title: 'Sitting unassisted',
      description: 'Sits without support for extended periods',
      expectedAgeMonths: 6,
    ),
    ExpectedMilestone(
      category: 'motor',
      title: 'Crawling',
      description: 'Moves around on hands and knees',
      expectedAgeMonths: 9,
    ),
    ExpectedMilestone(
      category: 'motor',
      title: 'Pulling to stand',
      description: 'Pulls self up to standing using furniture',
      expectedAgeMonths: 10,
    ),
    ExpectedMilestone(
      category: 'motor',
      title: 'Walking',
      description: 'Takes independent steps and walks',
      expectedAgeMonths: 12,
    ),
    ExpectedMilestone(
      category: 'motor',
      title: 'Running',
      description: 'Runs with increasing coordination',
      expectedAgeMonths: 18,
    ),
    ExpectedMilestone(
      category: 'motor',
      title: 'Climbing stairs',
      description: 'Walks up stairs with hand held or railing',
      expectedAgeMonths: 24,
    ),
    ExpectedMilestone(
      category: 'motor',
      title: 'Jumping',
      description: 'Jumps with both feet off the ground',
      expectedAgeMonths: 30,
    ),

    // ── Language milestones ──
    ExpectedMilestone(
      category: 'language',
      title: 'Cooing',
      description: 'Makes cooing and gurgling sounds',
      expectedAgeMonths: 2,
    ),
    ExpectedMilestone(
      category: 'language',
      title: 'Laughing',
      description: 'Laughs out loud',
      expectedAgeMonths: 4,
    ),
    ExpectedMilestone(
      category: 'language',
      title: 'Babbling',
      description: 'Babbles chains of consonant-vowel sounds (ba-ba, da-da)',
      expectedAgeMonths: 6,
    ),
    ExpectedMilestone(
      category: 'language',
      title: 'Responds to name',
      description: 'Turns head when name is called',
      expectedAgeMonths: 7,
    ),
    ExpectedMilestone(
      category: 'language',
      title: 'First words',
      description: 'Says first meaningful words like "mama" or "dada"',
      expectedAgeMonths: 12,
    ),
    ExpectedMilestone(
      category: 'language',
      title: 'Points to objects',
      description: 'Points to show interest or to request',
      expectedAgeMonths: 12,
    ),
    ExpectedMilestone(
      category: 'language',
      title: 'Two-word phrases',
      description: 'Combines two words ("more milk", "daddy go")',
      expectedAgeMonths: 21,
    ),
    ExpectedMilestone(
      category: 'language',
      title: 'Sentences',
      description: 'Speaks in short sentences of 3-4 words',
      expectedAgeMonths: 30,
    ),

    // ── Social milestones ──
    ExpectedMilestone(
      category: 'social',
      title: 'Social smile',
      description: 'Smiles in response to others',
      expectedAgeMonths: 2,
    ),
    ExpectedMilestone(
      category: 'social',
      title: 'Enjoys social play',
      description: 'Enjoys interactive games like peek-a-boo',
      expectedAgeMonths: 6,
    ),
    ExpectedMilestone(
      category: 'social',
      title: 'Stranger anxiety',
      description: 'Shows wariness or anxiety around unfamiliar people',
      expectedAgeMonths: 8,
    ),
    ExpectedMilestone(
      category: 'social',
      title: 'Waves bye-bye',
      description: 'Waves goodbye when prompted or spontaneously',
      expectedAgeMonths: 10,
    ),
    ExpectedMilestone(
      category: 'social',
      title: 'Imitates others',
      description: 'Imitates actions and gestures of others',
      expectedAgeMonths: 12,
    ),
    ExpectedMilestone(
      category: 'social',
      title: 'Parallel play',
      description: 'Plays alongside other children',
      expectedAgeMonths: 18,
    ),
    ExpectedMilestone(
      category: 'social',
      title: 'Shows empathy',
      description: 'Shows concern when someone is upset',
      expectedAgeMonths: 24,
    ),
    ExpectedMilestone(
      category: 'social',
      title: 'Cooperative play',
      description: 'Begins playing with other children cooperatively',
      expectedAgeMonths: 30,
    ),

    // ── Cognitive milestones ──
    ExpectedMilestone(
      category: 'cognitive',
      title: 'Follows objects',
      description: 'Follows moving objects with eyes',
      expectedAgeMonths: 2,
    ),
    ExpectedMilestone(
      category: 'cognitive',
      title: 'Reaches for objects',
      description: 'Reaches for and grasps objects',
      expectedAgeMonths: 4,
    ),
    ExpectedMilestone(
      category: 'cognitive',
      title: 'Explores objects',
      description: 'Explores objects by mouthing, shaking, and banging',
      expectedAgeMonths: 6,
    ),
    ExpectedMilestone(
      category: 'cognitive',
      title: 'Object permanence',
      description: 'Understands that objects exist even when hidden',
      expectedAgeMonths: 8,
    ),
    ExpectedMilestone(
      category: 'cognitive',
      title: 'Cause and effect',
      description: 'Understands cause and effect (push button, get sound)',
      expectedAgeMonths: 12,
    ),
    ExpectedMilestone(
      category: 'cognitive',
      title: 'Pretend play',
      description: 'Engages in pretend play (feeding a doll, talking on phone)',
      expectedAgeMonths: 18,
    ),
    ExpectedMilestone(
      category: 'cognitive',
      title: 'Sorting and matching',
      description: 'Sorts objects by shape or color, matches simple items',
      expectedAgeMonths: 24,
    ),
    ExpectedMilestone(
      category: 'cognitive',
      title: 'Counts to three',
      description: 'Counts small numbers of objects (up to 3)',
      expectedAgeMonths: 30,
    ),
    ExpectedMilestone(
      category: 'cognitive',
      title: 'Names colors',
      description: 'Identifies and names basic colors',
      expectedAgeMonths: 36,
    ),
  ];
}
