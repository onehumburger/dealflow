import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/services/who_growth_standards.dart';

class PercentileChart extends StatelessWidget {
  final MeasurementType measurementType;
  final Gender gender;
  final List<GrowthRecord> records;
  final DateTime dateOfBirth;

  const PercentileChart({
    super.key,
    required this.measurementType,
    required this.gender,
    required this.records,
    required this.dateOfBirth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relevantRecords = _getRelevantRecords();

    if (relevantRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: 12),
            Text(
              'No measurements yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add a measurement to see the growth chart',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final curves = WHOGrowthStandards.getCurves(
      gender: gender,
      type: measurementType,
      percentiles: [3, 15, 50, 85, 97],
    );

    final percentileColors = <int, Color>{
      3: Colors.grey.shade300,
      15: Colors.blue.shade100,
      50: Colors.blue.shade300,
      85: Colors.blue.shade100,
      97: Colors.grey.shade300,
    };

    // Build WHO percentile lines
    final lineBars = <LineChartBarData>[];
    for (final entry in curves.entries) {
      final percentile = entry.key;
      final points = entry.value;
      lineBars.add(LineChartBarData(
        spots: points
            .map((p) => FlSpot(p.month.toDouble(), p.value))
            .toList(),
        isCurved: true,
        color: percentileColors[percentile] ?? Colors.grey,
        barWidth: percentile == 50 ? 2.0 : 1.0,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ));
    }

    // Build baby's data line
    final babySpots = relevantRecords.map((r) {
      final ageMonths = _ageInMonths(r.date);
      final value = _getValue(r);
      return FlSpot(ageMonths.toDouble(), value!);
    }).toList();

    lineBars.add(LineChartBarData(
      spots: babySpots,
      isCurved: true,
      color: theme.colorScheme.primary,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: theme.colorScheme.primary,
            strokeWidth: 2,
            strokeColor: theme.colorScheme.surface,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    ));

    // Calculate current percentile for latest record
    final latestRecord = relevantRecords.last;
    final latestAge = _ageInMonths(latestRecord.date);
    final latestValue = _getValue(latestRecord)!;
    final currentPercentile = latestAge <= 36
        ? WHOGrowthStandards.percentile(
            measurement: latestValue,
            ageMonths: latestAge.clamp(0, 36),
            gender: gender,
            type: measurementType,
          )
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: lineBars,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Age (months)'),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 6,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(_yAxisLabel()),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: _gridInterval(),
                  verticalInterval: 6,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: theme.colorScheme.outline),
                    left: BorderSide(color: theme.colorScheme.outline),
                  ),
                ),
                minX: 0,
                maxX: 36,
              ),
            ),
          ),
          if (currentPercentile != null) ...[
            const SizedBox(height: 8),
            Text(
              'Current percentile: ${currentPercentile.toStringAsFixed(0)}th',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<GrowthRecord> _getRelevantRecords() {
    return records
        .where((r) => _getValue(r) != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  double? _getValue(GrowthRecord record) {
    switch (measurementType) {
      case MeasurementType.weight:
        return record.weightKg;
      case MeasurementType.height:
        return record.heightCm;
      case MeasurementType.headCircumference:
        return record.headCircumferenceCm;
    }
  }

  int _ageInMonths(DateTime date) {
    return (date.year - dateOfBirth.year) * 12 +
        date.month -
        dateOfBirth.month;
  }

  String _yAxisLabel() {
    switch (measurementType) {
      case MeasurementType.weight:
        return 'Weight (kg)';
      case MeasurementType.height:
        return 'Height (cm)';
      case MeasurementType.headCircumference:
        return 'Head (cm)';
    }
  }

  double _gridInterval() {
    switch (measurementType) {
      case MeasurementType.weight:
        return 2;
      case MeasurementType.height:
        return 10;
      case MeasurementType.headCircumference:
        return 5;
    }
  }
}
