import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide Family; // hide Riverpod's Family to use our Drift-generated Family
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/auth_provider.dart';
import 'package:uu/providers/family_provider.dart';

/// Screen for managing family sharing.
///
/// Shows the user's families, family members, pending invitations,
/// and allows creating families, inviting members, and joining via code.
class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Family Sharing')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Please sign in to use family sharing.\n\n'
              'Family sharing lets you invite others to view and '
              'contribute to your baby\'s records.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final familiesAsync = ref.watch(userFamiliesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Sharing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Join a family',
            onPressed: () => _showJoinFamilyDialog(context),
          ),
        ],
      ),
      body: familiesAsync.when(
        data: (families) => _buildBody(context, families),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateFamilyDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Family'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<Family> families) {
    if (families.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.family_restroom, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No families yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Create a family to share your baby\'s records '
                'with a partner, grandparent, or caregiver.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: families.length,
      itemBuilder: (context, index) {
        return _FamilyCard(
          family: families[index],
          onTap: () => _showFamilyDetails(context, families[index]),
        );
      },
    );
  }

  Future<void> _showCreateFamilyDialog(BuildContext context) async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Family'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Family Name',
            hintText: 'e.g. The Smiths',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(nameController.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty || !mounted) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final service = ref.read(familyServiceProvider);
    final createResult = await service.createFamily(
      name: result,
      userId: user.id,
      userEmail: user.email ?? '',
    );

    if (!mounted) return;

    if (createResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Family "${result.trim()}" created!')),
      );
      ref.invalidate(userFamiliesProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(createResult.error ?? 'Failed to create family')),
      );
    }
  }

  Future<void> _showJoinFamilyDialog(BuildContext context) async {
    final codeController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join a Family'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Invite Code',
            hintText: 'e.g. ABCD1234',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(codeController.text),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty || !mounted) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final service = ref.read(familyServiceProvider);
    final joinResult = await service.acceptInviteByCode(
      inviteCode: result,
      userId: user.id,
      userEmail: user.email ?? '',
    );

    if (!mounted) return;

    if (joinResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined family "${joinResult.data!.name}"!'),
        ),
      );
      ref.invalidate(userFamiliesProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(joinResult.error ?? 'Failed to join family')),
      );
    }
  }

  Future<void> _showFamilyDetails(
      BuildContext context, Family family) async {
    ref.read(selectedFamilyIdProvider.notifier).state = family.id;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FamilyDetailScreen(family: family),
      ),
    );
  }
}

/// Card showing a family summary in the list.
class _FamilyCard extends StatelessWidget {
  final Family family;
  final VoidCallback onTap;

  const _FamilyCard({required this.family, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.family_restroom,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(family.name),
        subtitle: Text('Code: ${family.inviteCode}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Detail screen for a single family -- shows members, invite code, invite button.
class _FamilyDetailScreen extends ConsumerStatefulWidget {
  final Family family;

  const _FamilyDetailScreen({required this.family});

  @override
  ConsumerState<_FamilyDetailScreen> createState() =>
      _FamilyDetailScreenState();
}

class _FamilyDetailScreenState extends ConsumerState<_FamilyDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(familyMembersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.family.name),
      ),
      body: ListView(
        children: [
          // Invite code section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite Code',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          widget.family.inviteCode,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy invite code',
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: widget.family.inviteCode),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invite code copied!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Share this code with family members to let them join.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Members section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Members', style: theme.textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Invite'),
                  onPressed: () => _showInviteMemberDialog(context),
                ),
              ],
            ),
          ),

          // Members list
          membersAsync.when(
            data: (members) => _buildMemberList(context, members),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList(
      BuildContext context, List<FamilyMember> members) {
    if (members.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No members yet.')),
      );
    }

    return Column(
      children: members.map((member) => _MemberTile(member: member)).toList(),
    );
  }

  Future<void> _showInviteMemberDialog(BuildContext context) async {
    final emailController = TextEditingController();

    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Member'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            hintText: 'partner@example.com',
          ),
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(emailController.text),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );

    if (email == null || email.trim().isEmpty || !mounted) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final service = ref.read(familyServiceProvider);
    final result = await service.inviteMember(
      familyId: widget.family.id,
      email: email,
      invitedByUserId: user.id,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation sent to ${email.trim()}')),
      );
      ref.invalidate(familyMembersProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed to send invitation')),
      );
    }
  }
}

/// Tile showing a single family member.
class _MemberTile extends StatelessWidget {
  final FamilyMember member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = member.status == 'pending';
    final isDeclined = member.status == 'declined';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPending
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primaryContainer,
        child: Icon(
          isPending ? Icons.hourglass_empty : Icons.person,
          color: isPending
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(member.email),
      subtitle: Text(
        isPending
            ? 'Pending invitation'
            : isDeclined
                ? 'Declined'
                : member.role == 'admin'
                    ? 'Admin'
                    : 'Member',
        style: TextStyle(
          color: isPending
              ? theme.colorScheme.onSurfaceVariant
              : isDeclined
                  ? theme.colorScheme.error
                  : null,
        ),
      ),
      trailing: member.role == 'admin'
          ? Chip(
              label: const Text('Admin'),
              backgroundColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 12,
              ),
            )
          : null,
    );
  }
}
