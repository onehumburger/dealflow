import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uu/database/app_database.dart';

class LogTimelineItem extends StatelessWidget {
  final DailyLog log;

  const LogTimelineItem({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _iconColor(theme).withAlpha(30),
        child: Icon(_iconForType(log.type), color: _iconColor(theme)),
      ),
      title: Text(
        _capitalize(log.type),
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _buildSubtitle(timeFormat),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: log.notes != null && log.notes!.isNotEmpty
          ? SizedBox(
              width: 100,
              child: Text(
                log.notes!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : null,
    );
  }

  String _buildSubtitle(DateFormat timeFormat) {
    final time = timeFormat.format(log.startedAt);
    if (log.durationMinutes != null && log.durationMinutes! > 0) {
      final hours = log.durationMinutes! ~/ 60;
      final minutes = log.durationMinutes! % 60;
      final durationStr = hours > 0
          ? '${hours}h${minutes > 0 ? ' ${minutes}m' : ''}'
          : '${minutes}m';
      return '$time - $durationStr';
    }
    return time;
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'feeding':
        return Icons.restaurant;
      case 'sleep':
        return Icons.bedtime;
      case 'diaper':
        return Icons.baby_changing_station;
      case 'mood':
        return Icons.mood;
      default:
        return Icons.note;
    }
  }

  Color _iconColor(ThemeData theme) {
    switch (log.type.toLowerCase()) {
      case 'feeding':
        return Colors.orange;
      case 'sleep':
        return Colors.indigo;
      case 'diaper':
        return Colors.teal;
      case 'mood':
        return Colors.pink;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
