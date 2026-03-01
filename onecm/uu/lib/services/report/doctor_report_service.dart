import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uu/database/app_database.dart';
import 'package:uu/services/daily_summary_service.dart';

/// Data transfer object containing all information needed for a doctor report.
class DoctorReportData {
  final Baby baby;
  final GrowthRecord? latestGrowth;
  final Map<String, double>? percentiles;
  final DailySummary? recentSummary;
  final List<Vaccination> vaccinations;
  final List<HealthEvent> recentHealthEvents;
  final List<Milestone> milestones;

  const DoctorReportData({
    required this.baby,
    this.latestGrowth,
    this.percentiles,
    this.recentSummary,
    this.vaccinations = const [],
    this.recentHealthEvents = const [],
    this.milestones = const [],
  });
}

/// Service that generates a one-page PDF summary for pediatrician visits.
class DoctorReportService {
  /// Generates a PDF document from the provided report data.
  ///
  /// Returns the raw bytes of the PDF.
  Future<Uint8List> generatePdf(DoctorReportData data) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('MMM d, yyyy');
    final ageText = _formatAge(data.baby.dateOfBirth, now);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ── Header ──
            _buildHeader(data.baby, ageText, dateFormat),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 8),

            // ── Growth Summary ──
            _buildGrowthSection(data.latestGrowth, data.percentiles, dateFormat),
            pw.SizedBox(height: 10),

            // ── Recent Activity (7-day averages) ──
            _buildActivitySection(data.recentSummary),
            pw.SizedBox(height: 10),

            // ── Vaccination Status ──
            _buildVaccinationSection(data.vaccinations, dateFormat),
            pw.SizedBox(height: 10),

            // ── Recent Health Events ──
            _buildHealthEventsSection(data.recentHealthEvents, dateFormat),
            pw.SizedBox(height: 10),

            // ── Milestone Summary ──
            _buildMilestoneSection(data.milestones),

            pw.Spacer(),

            // ── Footer ──
            pw.Divider(),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated: ${dateFormat.format(now)}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'UU Baby Tracker',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'This report is for informational purposes only and does not '
              'constitute medical advice. Please consult your pediatrician.',
              style: const pw.TextStyle(
                fontSize: 7,
                color: PdfColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  // ── Private builders ────────────────────────────────────────────────

  pw.Widget _buildHeader(
    Baby baby,
    String ageText,
    DateFormat dateFormat,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              baby.name,
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'DOB: ${dateFormat.format(baby.dateOfBirth)}  |  Age: $ageText'
              '${baby.gender != null ? "  |  ${baby.gender}" : ""}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Text(
          'Pediatric Visit\nSummary',
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildGrowthSection(
    GrowthRecord? latest,
    Map<String, double>? percentiles,
    DateFormat dateFormat,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Growth Summary'),
        if (latest == null)
          pw.Text('No growth records available.',
              style: const pw.TextStyle(fontSize: 9))
        else ...[
          pw.Text(
            'Recorded on ${dateFormat.format(latest.date)}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              if (latest.weightKg != null)
                _metricBox(
                  'Weight',
                  '${latest.weightKg!.toStringAsFixed(2)} kg',
                  percentiles?['weight'] != null
                      ? '${percentiles!['weight']!.toStringAsFixed(0)}th %ile'
                      : null,
                ),
              if (latest.heightCm != null)
                _metricBox(
                  'Height',
                  '${latest.heightCm!.toStringAsFixed(1)} cm',
                  percentiles?['height'] != null
                      ? '${percentiles!['height']!.toStringAsFixed(0)}th %ile'
                      : null,
                ),
              if (latest.headCircumferenceCm != null)
                _metricBox(
                  'Head Circ.',
                  '${latest.headCircumferenceCm!.toStringAsFixed(1)} cm',
                  percentiles?['headCircumference'] != null
                      ? '${percentiles!['headCircumference']!.toStringAsFixed(0)}th %ile'
                      : null,
                ),
            ],
          ),
        ],
      ],
    );
  }

  pw.Widget _buildActivitySection(DailySummary? summary) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Recent Activity (7-day average)'),
        if (summary == null)
          pw.Text('No recent activity data.',
              style: const pw.TextStyle(fontSize: 9))
        else
          pw.Row(
            children: [
              _metricBox('Feedings', '${summary.feedingCount}/day', null),
              _metricBox(
                'Sleep',
                '${(summary.totalSleepMinutes / 60).toStringAsFixed(1)} hrs',
                null,
              ),
              _metricBox('Diapers', '${summary.diaperCount}/day', null),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildVaccinationSection(
    List<Vaccination> vaccinations,
    DateFormat dateFormat,
  ) {
    final administered =
        vaccinations.where((v) => v.administeredAt != null).toList();
    final upcoming =
        vaccinations.where((v) => v.administeredAt == null).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Vaccination Status'),
        if (vaccinations.isEmpty)
          pw.Text('No vaccination records.',
              style: const pw.TextStyle(fontSize: 9))
        else ...[
          pw.Text(
            'Administered: ${administered.length}  |  Upcoming/Due: ${upcoming.length}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          if (administered.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Wrap(
              spacing: 8,
              runSpacing: 2,
              children: administered
                  .take(8)
                  .map((v) => pw.Text(
                        '${v.vaccineName}${v.doseNumber != null ? " #${v.doseNumber}" : ""}',
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.green800),
                      ))
                  .toList(),
            ),
          ],
          if (upcoming.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text('Upcoming:', style: const pw.TextStyle(fontSize: 8)),
            pw.Wrap(
              spacing: 8,
              runSpacing: 2,
              children: upcoming
                  .take(5)
                  .map((v) => pw.Text(
                        '${v.vaccineName}${v.nextDueAt != null ? " (due ${dateFormat.format(v.nextDueAt!)})" : ""}',
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.orange800),
                      ))
                  .toList(),
            ),
          ],
        ],
      ],
    );
  }

  pw.Widget _buildHealthEventsSection(
    List<HealthEvent> events,
    DateFormat dateFormat,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Recent Health Events'),
        if (events.isEmpty)
          pw.Text('No recent health events.',
              style: const pw.TextStyle(fontSize: 9))
        else
          ...events.take(5).map((e) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 60,
                      child: pw.Text(
                        e.startedAt != null
                            ? dateFormat.format(e.startedAt!)
                            : 'N/A',
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey600),
                      ),
                    ),
                    pw.SizedBox(
                      width: 60,
                      child: pw.Text(
                        _formatEventType(e.type),
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        '${e.title}${e.endedAt == null ? " (active)" : ""}',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  pw.Widget _buildMilestoneSection(List<Milestone> milestones) {
    final achieved = milestones.where((m) => m.achievedAt != null).toList();
    final upcoming = milestones.where((m) => m.achievedAt == null).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Milestone Summary'),
        if (milestones.isEmpty)
          pw.Text('No milestones recorded.',
              style: const pw.TextStyle(fontSize: 9))
        else ...[
          pw.Text(
            'Achieved: ${achieved.length}  |  Upcoming: ${upcoming.length}',
            style: const pw.TextStyle(fontSize: 9),
          ),
          if (achieved.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Wrap(
              spacing: 8,
              runSpacing: 2,
              children: achieved
                  .take(6)
                  .map((m) => pw.Text(
                        m.title,
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.green800),
                      ))
                  .toList(),
            ),
          ],
          if (upcoming.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text('Next up:', style: const pw.TextStyle(fontSize: 8)),
            pw.Wrap(
              spacing: 8,
              runSpacing: 2,
              children: upcoming
                  .take(4)
                  .map((m) => pw.Text(
                        '${m.title}${m.expectedAgeMonths != null ? " (~${m.expectedAgeMonths}mo)" : ""}',
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.blue800),
                      ))
                  .toList(),
            ),
          ],
        ],
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey800,
        ),
      ),
    );
  }

  pw.Widget _metricBox(String label, String value, String? subtitle) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.only(right: 8),
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey600)),
            pw.SizedBox(height: 2),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
            if (subtitle != null) ...[
              pw.SizedBox(height: 1),
              pw.Text(subtitle,
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.blue800)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAge(DateTime dob, DateTime now) {
    final months =
        (now.year - dob.year) * 12 + now.month - dob.month;
    if (months < 1) {
      final days = now.difference(dob).inDays;
      return '$days day${days == 1 ? '' : 's'}';
    }
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years > 0) {
      return '$years yr${years == 1 ? '' : 's'}'
          '${remainingMonths > 0 ? ' $remainingMonths mo' : ''}';
    }
    return '$months mo';
  }

  String _formatEventType(String type) {
    switch (type) {
      case 'illness':
        return 'Illness';
      case 'medication':
        return 'Medication';
      case 'doctor_visit':
        return 'Doctor Visit';
      default:
        return type;
    }
  }
}
