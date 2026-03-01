import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase
    show AuthState;
import 'package:uu/providers/auth_provider.dart';

// --- Mocks ---

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

// --- Helpers ---

/// Creates a fake [User] for testing.
User fakeUser({
  String id = 'test-user-id',
  String? email = 'test@example.com',
  Map<String, dynamic>? userMetadata,
}) {
  return User(
    id: id,
    appMetadata: {},
    userMetadata: userMetadata ?? {'full_name': 'Test User'},
    aud: 'authenticated',
    createdAt: '2025-01-01T00:00:00Z',
    email: email,
  );
}

void main() {
  group('AuthState', () {
    test('defaults to unauthenticated', () {
      const state = AuthState();
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('isAuthenticated is true when user is present', () {
      final state = AuthState(user: fakeUser());
      expect(state.isAuthenticated, isTrue);
    });

    test('displayName returns full_name from userMetadata', () {
      final state = AuthState(
        user: fakeUser(userMetadata: {'full_name': 'Alice'}),
      );
      expect(state.displayName, 'Alice');
    });

    test('displayName returns name from userMetadata as fallback', () {
      final state = AuthState(
        user: fakeUser(userMetadata: {'name': 'Bob'}),
      );
      expect(state.displayName, 'Bob');
    });

    test('displayName returns email when no name in metadata', () {
      final state = AuthState(
        user: fakeUser(email: 'alice@test.com', userMetadata: {}),
      );
      expect(state.displayName, 'alice@test.com');
    });

    test('displayName returns null when no user', () {
      const state = AuthState();
      expect(state.displayName, isNull);
    });

    test('email returns user email', () {
      final state = AuthState(user: fakeUser(email: 'a@b.com'));
      expect(state.email, 'a@b.com');
    });

    test('avatarUrl extracts avatar_url from metadata', () {
      final state = AuthState(
        user: fakeUser(
          userMetadata: {'avatar_url': 'https://img.example.com/photo.jpg'},
        ),
      );
      expect(state.avatarUrl, 'https://img.example.com/photo.jpg');
    });

    test('avatarUrl extracts picture from metadata', () {
      final state = AuthState(
        user: fakeUser(
          userMetadata: {'picture': 'https://img.example.com/pic.jpg'},
        ),
      );
      expect(state.avatarUrl, 'https://img.example.com/pic.jpg');
    });

    test('avatarUrl returns null when no metadata', () {
      final state = AuthState(user: fakeUser(userMetadata: {}));
      expect(state.avatarUrl, isNull);
    });

    test('copyWith preserves values', () {
      final state = AuthState(user: fakeUser(), isLoading: true, error: 'err');
      final copy = state.copyWith();
      expect(copy.user?.id, state.user?.id);
      expect(copy.isLoading, isTrue);
      expect(copy.error, 'err');
    });

    test('copyWith clearUser sets user to null', () {
      final state = AuthState(user: fakeUser());
      final copy = state.copyWith(clearUser: true);
      expect(copy.user, isNull);
    });

    test('copyWith clearError sets error to null', () {
      const state = AuthState(error: 'some error');
      final copy = state.copyWith(clearError: true);
      expect(copy.error, isNull);
    });

    test('equality works on same values', () {
      final a = AuthState(user: fakeUser());
      final b = AuthState(user: fakeUser());
      expect(a, equals(b));
    });

    test('equality fails on different values', () {
      final a = AuthState(user: fakeUser());
      const b = AuthState();
      expect(a, isNot(equals(b)));
    });
  });

  group('AuthNotifier (no Supabase client)', () {
    late AuthNotifier notifier;

    setUp(() {
      notifier = AuthNotifier(client: null);
    });

    tearDown(() {
      notifier.dispose();
    });

    test('initializes as unauthenticated', () {
      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('signInWithGoogle sets error when no client', () async {
      await notifier.signInWithGoogle();
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error, contains('not configured'));
      expect(notifier.state.isLoading, isFalse);
    });

    test('signInWithApple sets error when no client', () async {
      await notifier.signInWithApple();
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.error, contains('not configured'));
      expect(notifier.state.isLoading, isFalse);
    });

    test('signOut does nothing when no client', () async {
      await notifier.signOut();
      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('clearError removes error', () async {
      await notifier.signInWithGoogle();
      expect(notifier.state.error, isNotNull);
      notifier.clearError();
      expect(notifier.state.error, isNull);
    });
  });

  group('AuthNotifier (with mock client)', () {
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late StreamController<supabase.AuthState> authStreamController;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      authStreamController = StreamController<supabase.AuthState>.broadcast();

      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(null);
      when(() => mockAuth.onAuthStateChange)
          .thenAnswer((_) => authStreamController.stream);
    });

    tearDown(() async {
      await authStreamController.close();
    });

    test('initializes without current user', () {
      final notifier = AuthNotifier(client: mockClient);
      addTearDown(notifier.dispose);

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.user, isNull);
    });

    test('initializes with existing session user', () {
      final user = fakeUser();
      when(() => mockAuth.currentUser).thenReturn(user);

      final notifier = AuthNotifier(client: mockClient);
      addTearDown(notifier.dispose);

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.id, user.id);
    });

    test('responds to signedIn auth state change', () async {
      final notifier = AuthNotifier(client: mockClient);
      addTearDown(notifier.dispose);

      expect(notifier.state.isAuthenticated, isFalse);

      final user = fakeUser();
      final session = Session(
        accessToken: 'test-token',
        tokenType: 'bearer',
        user: user,
      );
      authStreamController.add(supabase.AuthState(
        AuthChangeEvent.signedIn,
        session,
      ));

      // Let the stream event be processed
      await Future.delayed(Duration.zero);

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.id, user.id);
      expect(notifier.state.isLoading, isFalse);
    });

    test('responds to signedOut auth state change', () async {
      final user = fakeUser();
      when(() => mockAuth.currentUser).thenReturn(user);

      final notifier = AuthNotifier(client: mockClient);
      addTearDown(notifier.dispose);

      expect(notifier.state.isAuthenticated, isTrue);

      authStreamController.add(supabase.AuthState(
        AuthChangeEvent.signedOut,
        null,
      ));

      await Future.delayed(Duration.zero);

      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.user, isNull);
    });

    test('responds to tokenRefreshed auth state change', () async {
      final notifier = AuthNotifier(client: mockClient);
      addTearDown(notifier.dispose);

      final user = fakeUser(email: 'refreshed@test.com');
      final session = Session(
        accessToken: 'refreshed-token',
        tokenType: 'bearer',
        user: user,
      );
      authStreamController.add(supabase.AuthState(
        AuthChangeEvent.tokenRefreshed,
        session,
      ));

      await Future.delayed(Duration.zero);

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.email, 'refreshed@test.com');
    });

    test('signOut calls client signOut and clears user', () async {
      final user = fakeUser();
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final notifier = AuthNotifier(client: mockClient);
      addTearDown(notifier.dispose);

      expect(notifier.state.isAuthenticated, isTrue);

      await notifier.signOut();

      verify(() => mockAuth.signOut()).called(1);
      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.isLoading, isFalse);
    });

    test('signOut handles AuthException gracefully', () async {
      when(() => mockAuth.signOut())
          .thenThrow(AuthException('Session expired'));

      final notifier = AuthNotifier(client: mockClient);
      addTearDown(notifier.dispose);

      await notifier.signOut();

      expect(notifier.state.error, 'Session expired');
      expect(notifier.state.isLoading, isFalse);
    });
  });

  group('Riverpod providers', () {
    test('authProvider provides AuthNotifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(authProvider);
      expect(state, isA<AuthState>());
      expect(state.isAuthenticated, isFalse);
    });

    test('isAuthenticatedProvider reflects auth state', () {
      // Container owns the notifier lifecycle when using overrideWith
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((_) => AuthNotifier(client: null)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isAuthenticatedProvider), isFalse);
    });

    test('currentUserProvider reflects auth state', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((_) => AuthNotifier(client: null)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(currentUserProvider), isNull);
    });

    test('overriding authProvider with authenticated state works', () {
      final mockClient = MockSupabaseClient();
      final mockAuth = MockGoTrueClient();
      final user = fakeUser();
      final authStreamController =
          StreamController<supabase.AuthState>.broadcast();

      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockAuth.onAuthStateChange)
          .thenAnswer((_) => authStreamController.stream);

      final container = ProviderContainer(
        overrides: [
          authProvider
              .overrideWith((_) => AuthNotifier(client: mockClient)),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(authStreamController.close);

      expect(container.read(isAuthenticatedProvider), isTrue);
      expect(container.read(currentUserProvider)?.id, 'test-user-id');
    });
  });
}
