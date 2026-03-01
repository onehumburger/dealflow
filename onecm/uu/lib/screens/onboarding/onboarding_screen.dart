import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/onboarding_provider.dart';
import 'package:uu/screens/onboarding/widgets/baby_form.dart';
import 'package:uu/screens/onboarding/widgets/onboarding_page.dart';

/// The total number of pages in the onboarding carousel.
const _pageCount = 4;

/// The index of the last page (baby setup).
const _lastPageIndex = _pageCount - 1;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final _formData = BabyFormData();

  int _currentPage = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_currentPage < _lastPageIndex) {
      _goToPage(_currentPage + 1);
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  void _onSkip() {
    _goToPage(_lastPageIndex);
  }

  Future<void> _onGetStarted() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(babyRepositoryProvider);
      final baby = await repo.createBaby(
        name: _formData.name,
        dateOfBirth: _formData.dateOfBirth!,
        gender: _formData.gender,
      );

      ref.read(selectedBabyIdProvider.notifier).state = baby.id;
      ref.read(onboardingNotifierProvider).hasCompleted = true;

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool get _isLastPage => _currentPage == _lastPageIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Carousel
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildFeaturesPage(theme),
                  _buildPermissionsPage(),
                  _buildBabySetupPage(theme),
                ],
              ),
            ),

            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pageCount, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back / Skip button
                  if (_currentPage == 0)
                    TextButton(
                      onPressed: _onSkip,
                      child: const Text('Skip'),
                    )
                  else if (_isLastPage)
                    const SizedBox(width: 72)
                  else
                    TextButton(
                      onPressed: _onBack,
                      child: const Text('Back'),
                    ),

                  // Next / Get Started button
                  if (_isLastPage)
                    FilledButton(
                      onPressed: _isSaving ? null : _onGetStarted,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Get Started',
                              style: TextStyle(fontSize: 16),
                            ),
                    )
                  else
                    FilledButton(
                      onPressed: _onNext,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Page builders ----

  Widget _buildWelcomePage() {
    return const OnboardingPage(
      icon: Icons.child_friendly,
      title: 'Welcome to UU',
      description: "Track your baby's growth journey",
    );
  }

  Widget _buildFeaturesPage(ThemeData theme) {
    return OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'Powerful Features',
      description: 'Everything you need to monitor and support '
          "your little one's development.",
      action: Column(
        children: [
          _FeatureRow(
            icon: Icons.trending_up,
            label: 'Growth Tracking',
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.chat_bubble_outline,
            label: 'AI Chat',
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.notifications_active_outlined,
            label: 'Smart Notifications',
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.family_restroom,
            label: 'Family Sharing',
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsPage() {
    return const OnboardingPage(
      icon: Icons.notifications_none_rounded,
      title: 'Stay Connected',
      description: 'Enable notifications to get feeding reminders, '
          'milestone alerts, and helpful tips at the right time.',
    );
  }

  Widget _buildBabySetupPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          Icon(
            Icons.child_care,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            "Set up your baby's profile",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Tell us about your little one to get started.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          BabyForm(formKey: _formKey, formData: _formData),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

/// A row displaying a feature icon and label used on the features page.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
