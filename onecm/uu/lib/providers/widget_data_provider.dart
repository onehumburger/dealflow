import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/daily_log_provider.dart';
import 'package:uu/services/widget_data_service.dart';

final widgetDataProvider = Provider<WidgetData>((ref) {
  final logsAsync = ref.watch(todayLogsProvider);
  return logsAsync.when(
    data: (logs) => WidgetDataService.computeWidgetData(logs, DateTime.now()),
    loading: () => const WidgetData(feedCountToday: 0, diaperCountToday: 0),
    error: (_, __) => const WidgetData(feedCountToday: 0, diaperCountToday: 0),
  );
});
