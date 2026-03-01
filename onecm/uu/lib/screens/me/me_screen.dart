import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uu/providers/auth_provider.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Me'),
      ),
      body: ListView(
        children: [
          // Account section
          _AccountTile(authState: authState),
          const Divider(),

          // Menu items
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: const Text('Growth Charts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/me/growth-charts'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notification Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/me/notification-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.family_restroom),
            title: const Text('Family Sharing'),
            subtitle: const Text('Invite family members'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/me/family'),
          ),
        ],
      ),
    );
  }
}

/// Shows the user's account tile -- either signed-in profile info
/// or a sign-in prompt.
class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (authState.isAuthenticated) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          backgroundImage: authState.avatarUrl != null
              ? NetworkImage(authState.avatarUrl!)
              : null,
          child: authState.avatarUrl == null
              ? Icon(Icons.person, color: colorScheme.onPrimaryContainer)
              : null,
        ),
        title: Text(authState.displayName ?? 'User'),
        subtitle: authState.email != null ? Text(authState.email!) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/me/profile'),
      );
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
      ),
      title: const Text('Sign In'),
      subtitle: const Text('Unlock sync, sharing & backup'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/me/sign-in'),
    );
  }
}
