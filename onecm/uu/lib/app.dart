import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/config/theme.dart';
import 'package:uu/providers/theme_provider.dart';

class UUApp extends ConsumerWidget {
  const UUApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'UU',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const Scaffold(body: Center(child: Text('UU'))),
    );
  }
}
