import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthState; // hide Supabase's AuthState to use our own
import 'package:supabase_flutter/supabase_flutter.dart' as supabase
    show AuthState;
import 'package:uu/config/supabase_config.dart';

/// Auth state exposed to the UI.
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  String? get displayName {
    if (user == null) return null;
    final meta = user!.userMetadata;
    if (meta != null) {
      final name = meta['full_name'] ?? meta['name'];
      if (name is String && name.isNotEmpty) return name;
    }
    return user!.email;
  }

  String? get email => user?.email;

  String? get avatarUrl {
    final meta = user?.userMetadata;
    if (meta == null) return null;
    final url = meta['avatar_url'] ?? meta['picture'];
    return url is String ? url : null;
  }

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          user?.id == other.user?.id &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => Object.hash(user?.id, isLoading, error);
}

/// Notifier that manages Supabase authentication state.
///
/// Listens to Supabase auth state changes and exposes sign-in/sign-out
/// methods. When Supabase is not configured, all operations are no-ops
/// and the user remains unauthenticated.
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient? _client;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthNotifier({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.clientOrNull,
        super(const AuthState()) {
    _init();
  }

  void _init() {
    final client = _client;
    if (client == null) return;

    // Set initial user from existing session
    final currentUser = client.auth.currentUser;
    if (currentUser != null) {
      state = state.copyWith(user: currentUser);
    }

    // Listen to auth state changes
    _authSubscription =
        client.auth.onAuthStateChange.listen((authState) {
      switch (authState.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          state = state.copyWith(
            user: authState.session?.user,
            isLoading: false,
            clearError: true,
          );
          break;
        case AuthChangeEvent.signedOut:
          state = state.copyWith(
            clearUser: true,
            isLoading: false,
            clearError: true,
          );
          break;
        default:
          break;
      }
    });
  }

  /// Sign in with Google via Supabase OAuth.
  Future<void> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      state = state.copyWith(
        error:
            'Supabase is not configured. Please set SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
      );
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sign in with Apple via Supabase OAuth.
  Future<void> signInWithApple() async {
    final client = _client;
    if (client == null) {
      state = state.copyWith(
        error:
            'Supabase is not configured. Please set SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.apple,
      );
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await client.auth.signOut();
      state = state.copyWith(clearUser: true, isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear any error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for auth state management.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience provider: whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Convenience provider: the current user or null.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
