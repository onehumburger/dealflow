import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/baby_repository.dart';
import 'package:uu/repositories/growth_repository.dart';
import 'package:uu/services/ai/ai_provider.dart';
import 'package:uu/services/who_growth_standards.dart';

/// Builds a [BabyContext] with a rich system prompt by pulling recent data
/// from the local database: last 7 days of logs, latest growth percentiles,
/// recent milestones, and health events.
class BabyContextBuilder {
  final BabyRepository _babyRepo;
  final GrowthRepository _growthRepo;
  final AppDatabase _db;

  BabyContextBuilder({
    required BabyRepository babyRepo,
    required GrowthRepository growthRepo,
    required AppDatabase db,
  })  : _babyRepo = babyRepo,
        _growthRepo = growthRepo,
        _db = db;

  /// Build a [BabyContext] for the given baby.
  ///
  /// Pulls the last 7 days of daily logs, the latest growth record with
  /// WHO percentiles, recent milestones, and recent health events to
  /// construct a comprehensive system prompt.
  Future<BabyContext> build(int babyId) async {
    final baby = await _babyRepo.getBaby(babyId);
    if (baby == null) {
      throw ArgumentError('Baby with id $babyId not found');
    }

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Gather data in parallel
    final results = await Future.wait([
      _getRecentLogs(babyId, sevenDaysAgo, now),
      _growthRepo.getLatestRecord(babyId),
      _getRecentMilestones(babyId),
      _getRecentHealthEvents(babyId),
    ]);

    final recentLogs = results[0] as List<DailyLog>;
    final latestGrowth = results[1] as GrowthRecord?;
    final milestones = results[2] as List<Milestone>;
    final healthEvents = results[3] as List<HealthEvent>;

    final systemPrompt = _buildSystemPrompt(
      baby: baby,
      recentLogs: recentLogs,
      latestGrowth: latestGrowth,
      milestones: milestones,
      healthEvents: healthEvents,
      now: now,
    );

    return BabyContext(
      babyName: baby.name,
      dateOfBirth: baby.dateOfBirth,
      gender: baby.gender,
      systemPrompt: systemPrompt,
    );
  }

  Future<List<DailyLog>> _getRecentLogs(
    int babyId,
    DateTime from,
    DateTime to,
  ) async {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day).add(const Duration(days: 1));
    return (_db.select(_db.dailyLogs)
          ..where((l) =>
              l.babyId.equals(babyId) &
              l.startedAt.isBiggerOrEqualValue(start) &
              l.startedAt.isSmallerThanValue(end))
          ..orderBy([(l) => OrderingTerm.desc(l.startedAt)]))
        .get();
  }

  Future<List<Milestone>> _getRecentMilestones(int babyId) async {
    return (_db.select(_db.milestones)
          ..where((m) => m.babyId.equals(babyId) & m.achievedAt.isNotNull())
          ..orderBy([(m) => OrderingTerm.desc(m.achievedAt)])
          ..limit(10))
        .get();
  }

  Future<List<HealthEvent>> _getRecentHealthEvents(int babyId) async {
    return (_db.select(_db.healthEvents)
          ..where((h) => h.babyId.equals(babyId))
          ..orderBy([(h) => OrderingTerm.desc(h.createdAt)])
          ..limit(10))
        .get();
  }

  String _buildSystemPrompt({
    required Baby baby,
    required List<DailyLog> recentLogs,
    required GrowthRecord? latestGrowth,
    required List<Milestone> milestones,
    required List<HealthEvent> healthEvents,
    required DateTime now,
  }) {
    final ageInDays = now.difference(baby.dateOfBirth).inDays;
    final ageMonths = (ageInDays / 30.44).floor();
    final ageDays = ageInDays % 30;

    final buffer = StringBuffer();

    // Role and personality
    buffer.writeln(
      'You are a knowledgeable, warm, and supportive baby care assistant. '
      'You help parents track and understand their baby\'s development.',
    );
    buffer.writeln();

    // Baby profile
    buffer.writeln('## Baby Profile');
    buffer.writeln('- Name: ${baby.name}');
    buffer.writeln('- Age: $ageMonths months and $ageDays days');
    buffer.writeln('- Date of birth: ${_formatDate(baby.dateOfBirth)}');
    if (baby.gender != null) {
      buffer.writeln('- Gender: ${baby.gender}');
    }
    buffer.writeln();

    // Growth data
    if (latestGrowth != null) {
      buffer.writeln('## Latest Growth Data (${_formatDate(latestGrowth.date)})');
      _appendGrowthData(buffer, latestGrowth, baby, ageMonths);
      buffer.writeln();
    }

    // Recent activity summary
    if (recentLogs.isNotEmpty) {
      buffer.writeln('## Recent Activity (last 7 days)');
      _appendActivitySummary(buffer, recentLogs);
      buffer.writeln();
    }

    // Milestones
    if (milestones.isNotEmpty) {
      buffer.writeln('## Recent Milestones');
      for (final m in milestones.take(5)) {
        final date = m.achievedAt != null ? _formatDate(m.achievedAt!) : 'pending';
        buffer.writeln('- ${m.title} (${m.category}, $date)');
      }
      buffer.writeln();
    }

    // Health events
    if (healthEvents.isNotEmpty) {
      buffer.writeln('## Recent Health Events');
      for (final h in healthEvents.take(5)) {
        buffer.writeln('- ${h.title} (${h.type}, ${_formatDate(h.createdAt)})');
      }
      buffer.writeln();
    }

    // Instructions
    buffer.writeln('## Guidelines');
    buffer.writeln(
      '- Always consider the baby\'s age when giving advice.',
    );
    buffer.writeln(
      '- Reference the baby by name (${baby.name}).',
    );
    buffer.writeln(
      '- Be encouraging and supportive.',
    );
    buffer.writeln(
      '- If asked about health concerns, always recommend consulting '
      'a pediatrician.',
    );
    buffer.writeln(
      '- End health-related responses with: "$medicalDisclaimer"',
    );

    return buffer.toString();
  }

  void _appendGrowthData(
    StringBuffer buffer,
    GrowthRecord record,
    Baby baby,
    int ageMonths,
  ) {
    final gender = baby.gender?.toLowerCase() == 'female'
        ? Gender.female
        : Gender.male;
    final clampedAge = ageMonths.clamp(0, 36);

    if (record.weightKg != null) {
      final pct = WHOGrowthStandards.percentile(
        measurement: record.weightKg!,
        ageMonths: clampedAge,
        gender: gender,
        type: MeasurementType.weight,
      );
      buffer.writeln(
        '- Weight: ${record.weightKg!.toStringAsFixed(2)} kg '
        '(${pct.toStringAsFixed(0)}th percentile)',
      );
    }
    if (record.heightCm != null) {
      final pct = WHOGrowthStandards.percentile(
        measurement: record.heightCm!,
        ageMonths: clampedAge,
        gender: gender,
        type: MeasurementType.height,
      );
      buffer.writeln(
        '- Height: ${record.heightCm!.toStringAsFixed(1)} cm '
        '(${pct.toStringAsFixed(0)}th percentile)',
      );
    }
    if (record.headCircumferenceCm != null) {
      final pct = WHOGrowthStandards.percentile(
        measurement: record.headCircumferenceCm!,
        ageMonths: clampedAge,
        gender: gender,
        type: MeasurementType.headCircumference,
      );
      buffer.writeln(
        '- Head circumference: ${record.headCircumferenceCm!.toStringAsFixed(1)} cm '
        '(${pct.toStringAsFixed(0)}th percentile)',
      );
    }
  }

  void _appendActivitySummary(StringBuffer buffer, List<DailyLog> logs) {
    final feedingCount = logs.where((l) => l.type == 'feeding').length;
    final sleepLogs = logs.where((l) => l.type == 'sleep').toList();
    final diaperCount = logs.where((l) => l.type == 'diaper').length;
    final moodCount = logs.where((l) => l.type == 'mood').length;

    final totalSleepMinutes = sleepLogs.fold<int>(0, (sum, log) {
      if (log.endedAt != null) {
        return sum + log.endedAt!.difference(log.startedAt).inMinutes;
      }
      return sum + (log.durationMinutes ?? 0);
    });

    buffer.writeln('- Feedings logged: $feedingCount');
    buffer.writeln(
      '- Total sleep: ${(totalSleepMinutes / 60).toStringAsFixed(1)} hours',
    );
    buffer.writeln('- Diaper changes: $diaperCount');
    if (moodCount > 0) {
      buffer.writeln('- Mood entries: $moodCount');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
