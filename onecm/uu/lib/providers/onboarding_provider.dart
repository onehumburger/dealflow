import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that controls whether onboarding redirect is active.
/// Used as GoRouter's refreshListenable.
class OnboardingNotifier extends ChangeNotifier {
  bool _hasCompleted = false;
  bool get hasCompleted => _hasCompleted;

  set hasCompleted(bool value) {
    if (_hasCompleted != value) {
      _hasCompleted = value;
      notifyListeners();
    }
  }
}

/// Global provider for the onboarding state.
/// Shared between the router (for redirect) and screens.
final onboardingNotifierProvider = Provider<OnboardingNotifier>((ref) {
  final notifier = OnboardingNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
