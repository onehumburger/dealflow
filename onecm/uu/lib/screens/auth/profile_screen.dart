import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uu/providers/auth_provider.dart';

/// User profile screen showing account info and sign-out button.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // If user signs out, navigate back
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (!next.isAuthenticated && (prev?.isAuthenticated ?? false)) {
        if (context.mounted && context.canPop()) {
          context.pop();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: authState.avatarUrl != null
                    ? NetworkImage(authState.avatarUrl!)
                    : null,
                child: authState.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 48,
                        color: colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Display name
            Center(
              child: Text(
                authState.displayName ?? 'User',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Email
            if (authState.email != null)
              Center(
                child: Text(
                  authState.email!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Account info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.fingerprint,
                      label: 'User ID',
                      value: authState.user?.id ?? '--',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: authState.email ?? '--',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Created',
                      value: authState.user?.createdAt ?? '--',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cloud features status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Features',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FeatureRow(
                      icon: Icons.sync,
                      label: 'Data Sync',
                      enabled: authState.isAuthenticated,
                    ),
                    const SizedBox(height: 8),
                    _FeatureRow(
                      icon: Icons.family_restroom,
                      label: 'Family Sharing',
                      enabled: authState.isAuthenticated,
                    ),
                    const SizedBox(height: 8),
                    _FeatureRow(
                      icon: Icons.cloud_upload_outlined,
                      label: 'Media Backup',
                      enabled: authState.isAuthenticated,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Error message
            if (authState.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  authState.error!,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Sign out button
            FilledButton.tonalIcon(
              onPressed: authState.isLoading
                  ? null
                  : () => ref.read(authProvider.notifier).signOut(),
              icon: authState.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.onErrorContainer,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Icon(
          enabled ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: enabled ? colorScheme.primary : colorScheme.outline,
        ),
      ],
    );
  }
}
