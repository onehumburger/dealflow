# UU Baby Growth Tracker — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build an offline-first Flutter baby tracking app with Supabase backend, AI chatbot, and smart notifications for parents of 0-3 year olds.

**Architecture:** Flutter frontend with Riverpod state management, Drift (SQLite) for local-first data, Supabase for cloud sync/auth/storage, Edge Functions for AI analysis. Offline-first: all reads from local DB, writes queued for sync.

**Tech Stack:** Flutter 3.x, Dart, Riverpod, Drift (SQLite), Supabase (PostgreSQL, Auth, Storage, Realtime, Edge Functions), fl_chart, Google Gemini API, FCM.

**Design doc:** `docs/plans/2026-02-28-uu-baby-app-design.md`

---

## Phase 1: Project Setup & Core Infrastructure (Tasks 1-6)

### Task 1: Create Flutter Project and Configure Dependencies

**Files:**
- Create: `uu/pubspec.yaml`
- Create: `uu/lib/main.dart`
- Create: `uu/analysis_options.yaml`

**Step 1: Create the Flutter project**

Run:
```bash
cd /Users/BBB/ccproj/onecm
flutter create uu --org com.uu.app --platforms android,ios
cd uu
```
Expected: Flutter project created with standard structure.

**Step 2: Add dependencies to pubspec.yaml**

Replace the `dependencies` and `dev_dependencies` sections in `uu/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  # Local database
  drift: ^2.22.1
  drift_flutter: ^0.2.4
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.5
  path: ^1.9.1
  # Supabase
  supabase_flutter: ^2.8.2
  # Routing
  go_router: ^14.8.1
  # Charts
  fl_chart: ^0.70.2
  # UI utilities
  intl: ^0.19.0
  uuid: ^4.5.1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  # Notifications
  flutter_local_notifications: ^18.0.1
  # Image handling
  cached_network_image: ^3.4.1
  image_picker: ^1.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  # Code generation
  build_runner: ^2.4.14
  drift_dev: ^2.22.1
  freezed: ^2.5.7
  json_serializable: ^6.9.0
  riverpod_generator: ^2.6.3
  # Testing
  mocktail: ^1.0.4
```

**Step 3: Install dependencies**

Run: `flutter pub get`
Expected: All packages resolve successfully.

**Step 4: Commit**

```bash
git add uu/
git commit -m "feat: create Flutter project with core dependencies"
```

---

### Task 2: Set Up Drift Database with Core Tables

**Files:**
- Create: `uu/lib/database/tables/babies_table.dart`
- Create: `uu/lib/database/tables/growth_records_table.dart`
- Create: `uu/lib/database/tables/daily_logs_table.dart`
- Create: `uu/lib/database/app_database.dart`
- Create: `uu/lib/database/tables/tables.dart` (barrel export)
- Test: `uu/test/database/app_database_test.dart`

**Step 1: Write the failing test**

```dart
// uu/test/database/app_database_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase', () {
    test('can create and read a baby', () async {
      final id = await db.into(db.babies).insert(BabiesCompanion.insert(
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
      ));

      final baby = await (db.select(db.babies)
            ..where((b) => b.id.equals(id)))
          .getSingle();

      expect(baby.name, 'Luna');
      expect(baby.dateOfBirth, DateTime(2025, 6, 15));
    });

    test('can create and read a growth record', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
      ));

      await db.into(db.growthRecords).insert(GrowthRecordsCompanion.insert(
        babyId: babyId,
        date: DateTime(2025, 7, 15),
        weightKg: const Value(4.5),
        heightCm: const Value(55.0),
        headCircumferenceCm: const Value(37.0),
      ));

      final records = await (db.select(db.growthRecords)
            ..where((r) => r.babyId.equals(babyId)))
          .get();

      expect(records.length, 1);
      expect(records.first.weightKg, 4.5);
    });

    test('can create and read a daily log', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
      ));

      await db.into(db.dailyLogs).insert(DailyLogsCompanion.insert(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime(2025, 7, 15, 8, 0),
      ));

      final logs = await (db.select(db.dailyLogs)
            ..where((l) => l.babyId.equals(babyId)))
          .get();

      expect(logs.length, 1);
      expect(logs.first.type, 'feeding');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/database/app_database_test.dart`
Expected: FAIL — imports don't resolve (files don't exist yet).

**Step 3: Write the table definitions and database**

```dart
// uu/lib/database/tables/babies_table.dart
import 'package:drift/drift.dart';

class Babies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get dateOfBirth => dateTime()();
  TextColumn get gender => text().nullable()();
  TextColumn get bloodType => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
```

```dart
// uu/lib/database/tables/growth_records_table.dart
import 'package:drift/drift.dart';

class GrowthRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get babyId => integer().references(Babies, #id)();
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get headCircumferenceCm => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
```

Note: The `Babies` import for references is resolved by Drift's code generation when all tables are in the same `@DriftDatabase`.

```dart
// uu/lib/database/tables/daily_logs_table.dart
import 'package:drift/drift.dart';

class DailyLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get babyId => integer()();
  TextColumn get type => text().check(type.isIn(['feeding', 'sleep', 'diaper', 'mood']))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get metadata => text().nullable()(); // JSON string
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
```

```dart
// uu/lib/database/tables/tables.dart
export 'babies_table.dart';
export 'growth_records_table.dart';
export 'daily_logs_table.dart';
```

```dart
// uu/lib/database/app_database.dart
import 'package:drift/drift.dart';
import 'tables/babies_table.dart';
import 'tables/growth_records_table.dart';
import 'tables/daily_logs_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Babies, GrowthRecords, DailyLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
```

**Step 4: Run code generation**

Run: `cd uu && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `app_database.g.dart` with data classes and companion classes.

**Step 5: Run tests**

Run: `cd uu && flutter test test/database/app_database_test.dart -v`
Expected: All 3 tests PASS.

**Step 6: Commit**

```bash
git add uu/lib/database/ uu/test/database/
git commit -m "feat: add Drift database with babies, growth_records, daily_logs tables"
```

---

### Task 3: Set Up App Theme with Dark Mode Support

**Files:**
- Create: `uu/lib/config/theme.dart`
- Test: `uu/test/config/theme_test.dart`

**Step 1: Write the failing test**

```dart
// uu/test/config/theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/config/theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme has expected primary color', () {
      final theme = AppTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, isNotNull);
    });

    test('dark theme has dark brightness', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
    });

    test('both themes use the same font family', () {
      expect(
        AppTheme.light.textTheme.bodyLarge?.fontFamily,
        AppTheme.dark.textTheme.bodyLarge?.fontFamily,
      );
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/config/theme_test.dart`
Expected: FAIL — `AppTheme` not found.

**Step 3: Write the theme**

```dart
// uu/lib/config/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Warm, friendly palette for a baby app
  static const _primaryColor = Color(0xFF6B9DFC); // Soft blue
  static const _secondaryColor = Color(0xFFFFA3B5); // Soft pink

  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      brightness: Brightness.light,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      brightness: Brightness.dark,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
```

**Step 4: Run tests**

Run: `cd uu && flutter test test/config/theme_test.dart -v`
Expected: All 3 tests PASS.

**Step 5: Commit**

```bash
git add uu/lib/config/theme.dart uu/test/config/theme_test.dart
git commit -m "feat: add light and dark app themes"
```

---

### Task 4: Set Up Riverpod Providers for Database and Theme

**Files:**
- Create: `uu/lib/providers/database_provider.dart`
- Create: `uu/lib/providers/theme_provider.dart`
- Create: `uu/lib/providers/providers.dart` (barrel)
- Modify: `uu/lib/main.dart`
- Create: `uu/lib/app.dart`
- Test: `uu/test/providers/theme_provider_test.dart`

**Step 1: Write the failing test**

```dart
// uu/test/providers/theme_provider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    test('defaults to system theme mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = container.read(themeModeProvider);
      expect(mode, ThemeMode.system);
    });

    test('can switch to dark mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(themeModeProvider.notifier).state = ThemeMode.dark;
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/providers/theme_provider_test.dart`
Expected: FAIL — import not found.

**Step 3: Write the providers and app shell**

```dart
// uu/lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
```

```dart
// uu/lib/providers/database_provider.dart
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'uu_database'));
  ref.onDispose(() => db.close());
  return db;
});
```

```dart
// uu/lib/providers/providers.dart
export 'database_provider.dart';
export 'theme_provider.dart';
```

```dart
// uu/lib/app.dart
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
      home: const Scaffold(
        body: Center(child: Text('UU')),
      ),
    );
  }
}
```

```dart
// uu/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: UUApp()));
}
```

**Step 4: Run tests**

Run: `cd uu && flutter test test/providers/theme_provider_test.dart -v`
Expected: All tests PASS.

**Step 5: Commit**

```bash
git add uu/lib/providers/ uu/lib/app.dart uu/lib/main.dart uu/test/providers/
git commit -m "feat: add Riverpod providers for database and theme, set up app shell"
```

---

### Task 5: Set Up GoRouter Navigation Shell

**Files:**
- Create: `uu/lib/config/router.dart`
- Create: `uu/lib/screens/home/home_screen.dart`
- Create: `uu/lib/screens/logs/logs_screen.dart`
- Create: `uu/lib/screens/chat/chat_screen.dart`
- Create: `uu/lib/screens/me/me_screen.dart`
- Create: `uu/lib/screens/shell/app_shell.dart`
- Modify: `uu/lib/app.dart`
- Test: `uu/test/screens/shell/app_shell_test.dart`

**Step 1: Write the failing test**

```dart
// uu/test/screens/shell/app_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/app.dart';

void main() {
  group('AppShell', () {
    testWidgets('shows bottom navigation with 5 items', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: UUApp()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('shows Home tab by default', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: UUApp()));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('can navigate to Logs tab', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: UUApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.text('Logs'), findsWidgets);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/screens/shell/app_shell_test.dart`
Expected: FAIL — navigation not implemented yet.

**Step 3: Write the placeholder screens, shell, and router**

```dart
// uu/lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Home'));
  }
}
```

```dart
// uu/lib/screens/logs/logs_screen.dart
import 'package:flutter/material.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Logs'));
  }
}
```

```dart
// uu/lib/screens/chat/chat_screen.dart
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Chat'));
  }
}
```

```dart
// uu/lib/screens/me/me_screen.dart
import 'package:flutter/material.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Me'));
  }
}
```

```dart
// uu/lib/screens/shell/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Quick-add menu
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_outlined), selectedIcon: Icon(Icons.list), label: 'Logs'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: ''), // placeholder for FAB
          NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
```

```dart
// uu/lib/config/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uu/screens/home/home_screen.dart';
import 'package:uu/screens/logs/logs_screen.dart';
import 'package:uu/screens/chat/chat_screen.dart';
import 'package:uu/screens/me/me_screen.dart';
import 'package:uu/screens/shell/app_shell.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/logs', builder: (context, state) => const LogsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/add', builder: (context, state) => const SizedBox()), // placeholder
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/me', builder: (context, state) => const MeScreen()),
        ]),
      ],
    ),
  ],
);
```

Update `uu/lib/app.dart` to use the router:

```dart
// uu/lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/config/router.dart';
import 'package:uu/config/theme.dart';
import 'package:uu/providers/theme_provider.dart';

class UUApp extends ConsumerWidget {
  const UUApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'UU',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
```

**Step 4: Run tests**

Run: `cd uu && flutter test test/screens/shell/app_shell_test.dart -v`
Expected: All 3 tests PASS.

**Step 5: Commit**

```bash
git add uu/lib/screens/ uu/lib/config/router.dart uu/lib/app.dart uu/test/screens/
git commit -m "feat: add GoRouter navigation shell with 5-tab bottom nav"
```

---

### Task 6: Baby Repository with CRUD Operations

**Files:**
- Create: `uu/lib/repositories/baby_repository.dart`
- Test: `uu/test/repositories/baby_repository_test.dart`

**Step 1: Write the failing test**

```dart
// uu/test/repositories/baby_repository_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/baby_repository.dart';

void main() {
  late AppDatabase db;
  late BabyRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = BabyRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BabyRepository', () {
    test('createBaby returns the new baby with id', () async {
      final baby = await repo.createBaby(
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
        gender: 'female',
      );

      expect(baby.id, greaterThan(0));
      expect(baby.name, 'Luna');
      expect(baby.gender, 'female');
    });

    test('getBaby returns null for non-existent id', () async {
      final baby = await repo.getBaby(999);
      expect(baby, isNull);
    });

    test('getAllBabies returns all created babies', () async {
      await repo.createBaby(name: 'Luna', dateOfBirth: DateTime(2025, 6, 15));
      await repo.createBaby(name: 'Max', dateOfBirth: DateTime(2024, 1, 10));

      final babies = await repo.getAllBabies();
      expect(babies.length, 2);
    });

    test('updateBaby changes the name', () async {
      final baby = await repo.createBaby(
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
      );

      await repo.updateBaby(baby.id, name: 'Luna Star');

      final updated = await repo.getBaby(baby.id);
      expect(updated?.name, 'Luna Star');
    });

    test('watchBaby emits updates', () async {
      final baby = await repo.createBaby(
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
      );

      final stream = repo.watchBaby(baby.id);

      expectLater(
        stream,
        emitsInOrder([
          predicate<Baby>((b) => b.name == 'Luna'),
          predicate<Baby>((b) => b.name == 'Luna Updated'),
        ]),
      );

      // Give stream time to emit first value
      await Future.delayed(const Duration(milliseconds: 50));
      await repo.updateBaby(baby.id, name: 'Luna Updated');
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/repositories/baby_repository_test.dart`
Expected: FAIL — `BabyRepository` not found.

**Step 3: Write the repository**

```dart
// uu/lib/repositories/baby_repository.dart
import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class BabyRepository {
  final AppDatabase _db;

  BabyRepository(this._db);

  Future<Baby> createBaby({
    required String name,
    required DateTime dateOfBirth,
    String? gender,
    String? bloodType,
    String? photoUrl,
  }) async {
    final id = await _db.into(_db.babies).insert(BabiesCompanion.insert(
      name: name,
      dateOfBirth: dateOfBirth,
      gender: Value(gender),
      bloodType: Value(bloodType),
      photoUrl: Value(photoUrl),
    ));
    return (await getBaby(id))!;
  }

  Future<Baby?> getBaby(int id) {
    return (_db.select(_db.babies)..where((b) => b.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Baby>> getAllBabies() {
    return _db.select(_db.babies).get();
  }

  Future<void> updateBaby(int id, {String? name, String? gender, String? photoUrl}) {
    return (_db.update(_db.babies)..where((b) => b.id.equals(id))).write(
      BabiesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        gender: gender != null ? Value(gender) : const Value.absent(),
        photoUrl: photoUrl != null ? Value(photoUrl) : const Value.absent(),
      ),
    );
  }

  Stream<Baby> watchBaby(int id) {
    return (_db.select(_db.babies)..where((b) => b.id.equals(id)))
        .watchSingle();
  }
}
```

**Step 4: Run tests**

Run: `cd uu && flutter test test/repositories/baby_repository_test.dart -v`
Expected: All 5 tests PASS.

**Step 5: Commit**

```bash
git add uu/lib/repositories/ uu/test/repositories/
git commit -m "feat: add BabyRepository with CRUD and watch operations"
```

---

## Phase 1 continued: Core Features (Tasks 7-15)

### Task 7: Growth Record Repository

**Files:**
- Create: `uu/lib/repositories/growth_repository.dart`
- Test: `uu/test/repositories/growth_repository_test.dart`

**Step 1: Write the failing test**

```dart
// uu/test/repositories/growth_repository_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/growth_repository.dart';

void main() {
  late AppDatabase db;
  late GrowthRepository repo;
  late int babyId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = GrowthRepository(db);
    babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
      name: 'Luna',
      dateOfBirth: DateTime(2025, 6, 15),
    ));
  });

  tearDown(() async => await db.close());

  group('GrowthRepository', () {
    test('addRecord and getRecordsForBaby', () async {
      await repo.addRecord(
        babyId: babyId,
        date: DateTime(2025, 7, 15),
        weightKg: 4.5,
        heightCm: 55.0,
        headCircumferenceCm: 37.0,
      );

      final records = await repo.getRecordsForBaby(babyId);
      expect(records.length, 1);
      expect(records.first.weightKg, 4.5);
      expect(records.first.heightCm, 55.0);
    });

    test('getLatestRecord returns most recent', () async {
      await repo.addRecord(babyId: babyId, date: DateTime(2025, 7, 1), weightKg: 4.0);
      await repo.addRecord(babyId: babyId, date: DateTime(2025, 8, 1), weightKg: 5.0);

      final latest = await repo.getLatestRecord(babyId);
      expect(latest?.weightKg, 5.0);
    });

    test('watchRecordsForBaby emits on new entry', () async {
      final stream = repo.watchRecordsForBaby(babyId);

      expectLater(
        stream,
        emitsInOrder([
          hasLength(0),
          hasLength(1),
        ]),
      );

      await Future.delayed(const Duration(milliseconds: 50));
      await repo.addRecord(babyId: babyId, date: DateTime(2025, 7, 15), weightKg: 4.5);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/repositories/growth_repository_test.dart`
Expected: FAIL.

**Step 3: Write the repository**

```dart
// uu/lib/repositories/growth_repository.dart
import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class GrowthRepository {
  final AppDatabase _db;

  GrowthRepository(this._db);

  Future<void> addRecord({
    required int babyId,
    required DateTime date,
    double? weightKg,
    double? heightCm,
    double? headCircumferenceCm,
    String? notes,
  }) {
    return _db.into(_db.growthRecords).insert(GrowthRecordsCompanion.insert(
      babyId: babyId,
      date: date,
      weightKg: Value(weightKg),
      heightCm: Value(heightCm),
      headCircumferenceCm: Value(headCircumferenceCm),
      notes: Value(notes),
    ));
  }

  Future<List<GrowthRecord>> getRecordsForBaby(int babyId) {
    return (_db.select(_db.growthRecords)
          ..where((r) => r.babyId.equals(babyId))
          ..orderBy([(r) => OrderingTerm.asc(r.date)]))
        .get();
  }

  Future<GrowthRecord?> getLatestRecord(int babyId) {
    return (_db.select(_db.growthRecords)
          ..where((r) => r.babyId.equals(babyId))
          ..orderBy([(r) => OrderingTerm.desc(r.date)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<GrowthRecord>> watchRecordsForBaby(int babyId) {
    return (_db.select(_db.growthRecords)
          ..where((r) => r.babyId.equals(babyId))
          ..orderBy([(r) => OrderingTerm.asc(r.date)]))
        .watch();
  }
}
```

**Step 4: Run tests**

Run: `cd uu && flutter test test/repositories/growth_repository_test.dart -v`
Expected: All 3 tests PASS.

**Step 5: Commit**

```bash
git add uu/lib/repositories/growth_repository.dart uu/test/repositories/growth_repository_test.dart
git commit -m "feat: add GrowthRepository with CRUD and watch"
```

---

### Task 8: Daily Log Repository

**Files:**
- Create: `uu/lib/repositories/daily_log_repository.dart`
- Test: `uu/test/repositories/daily_log_repository_test.dart`

**Step 1: Write the failing test**

```dart
// uu/test/repositories/daily_log_repository_test.dart
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/daily_log_repository.dart';

void main() {
  late AppDatabase db;
  late DailyLogRepository repo;
  late int babyId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DailyLogRepository(db);
    babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
      name: 'Luna',
      dateOfBirth: DateTime(2025, 6, 15),
    ));
  });

  tearDown(() async => await db.close());

  group('DailyLogRepository', () {
    test('quickLog creates a log with just type and timestamp', () async {
      final log = await repo.quickLog(
        babyId: babyId,
        type: 'diaper',
      );

      expect(log.type, 'diaper');
      expect(log.startedAt, isNotNull);
    });

    test('createLog with metadata stores JSON', () async {
      final log = await repo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime(2025, 7, 15, 8, 0),
        metadata: {'method': 'breast', 'side': 'left'},
      );

      final decoded = jsonDecode(log.metadata!);
      expect(decoded['method'], 'breast');
      expect(decoded['side'], 'left');
    });

    test('getLogsForDay returns only logs from that day', () async {
      final day = DateTime(2025, 7, 15);
      await repo.createLog(babyId: babyId, type: 'feeding', startedAt: DateTime(2025, 7, 15, 8, 0));
      await repo.createLog(babyId: babyId, type: 'sleep', startedAt: DateTime(2025, 7, 15, 20, 0));
      await repo.createLog(babyId: babyId, type: 'feeding', startedAt: DateTime(2025, 7, 16, 8, 0));

      final logs = await repo.getLogsForDay(babyId, day);
      expect(logs.length, 2);
    });

    test('getLogsForDayByType filters correctly', () async {
      await repo.createLog(babyId: babyId, type: 'feeding', startedAt: DateTime(2025, 7, 15, 8, 0));
      await repo.createLog(babyId: babyId, type: 'sleep', startedAt: DateTime(2025, 7, 15, 20, 0));

      final feedings = await repo.getLogsForDayByType(babyId, DateTime(2025, 7, 15), 'feeding');
      expect(feedings.length, 1);
      expect(feedings.first.type, 'feeding');
    });

    test('endLog sets endedAt and calculates duration', () async {
      final log = await repo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime(2025, 7, 15, 8, 0),
      );

      await repo.endLog(log.id, DateTime(2025, 7, 15, 8, 25));

      final updated = await repo.getLog(log.id);
      expect(updated?.endedAt, DateTime(2025, 7, 15, 8, 25));
      expect(updated?.durationMinutes, 25);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/repositories/daily_log_repository_test.dart`
Expected: FAIL.

**Step 3: Write the repository**

```dart
// uu/lib/repositories/daily_log_repository.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class DailyLogRepository {
  final AppDatabase _db;

  DailyLogRepository(this._db);

  Future<DailyLog> quickLog({
    required int babyId,
    required String type,
  }) {
    return createLog(
      babyId: babyId,
      type: type,
      startedAt: DateTime.now(),
    );
  }

  Future<DailyLog> createLog({
    required int babyId,
    required String type,
    required DateTime startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? metadata,
    String? notes,
  }) async {
    final durationMinutes = endedAt != null
        ? endedAt.difference(startedAt).inMinutes
        : null;

    final id = await _db.into(_db.dailyLogs).insert(DailyLogsCompanion.insert(
      babyId: babyId,
      type: type,
      startedAt: startedAt,
      endedAt: Value(endedAt),
      durationMinutes: Value(durationMinutes),
      metadata: Value(metadata != null ? jsonEncode(metadata) : null),
      notes: Value(notes),
    ));

    return (await getLog(id))!;
  }

  Future<DailyLog?> getLog(int id) {
    return (_db.select(_db.dailyLogs)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<DailyLog>> getLogsForDay(int babyId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.dailyLogs)
          ..where((l) =>
              l.babyId.equals(babyId) &
              l.startedAt.isBiggerOrEqualValue(start) &
              l.startedAt.isSmallerThanValue(end))
          ..orderBy([(l) => OrderingTerm.desc(l.startedAt)]))
        .get();
  }

  Future<List<DailyLog>> getLogsForDayByType(int babyId, DateTime day, String type) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.dailyLogs)
          ..where((l) =>
              l.babyId.equals(babyId) &
              l.type.equals(type) &
              l.startedAt.isBiggerOrEqualValue(start) &
              l.startedAt.isSmallerThanValue(end))
          ..orderBy([(l) => OrderingTerm.desc(l.startedAt)]))
        .get();
  }

  Future<void> endLog(int id, DateTime endedAt) async {
    final log = await getLog(id);
    if (log == null) return;

    final duration = endedAt.difference(log.startedAt).inMinutes;
    await (_db.update(_db.dailyLogs)..where((l) => l.id.equals(id))).write(
      DailyLogsCompanion(
        endedAt: Value(endedAt),
        durationMinutes: Value(duration),
      ),
    );
  }

  Stream<List<DailyLog>> watchLogsForDay(int babyId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.dailyLogs)
          ..where((l) =>
              l.babyId.equals(babyId) &
              l.startedAt.isBiggerOrEqualValue(start) &
              l.startedAt.isSmallerThanValue(end))
          ..orderBy([(l) => OrderingTerm.desc(l.startedAt)]))
        .watch();
  }
}
```

**Step 4: Run tests**

Run: `cd uu && flutter test test/repositories/daily_log_repository_test.dart -v`
Expected: All 5 tests PASS.

**Step 5: Commit**

```bash
git add uu/lib/repositories/daily_log_repository.dart uu/test/repositories/daily_log_repository_test.dart
git commit -m "feat: add DailyLogRepository with quick-log, CRUD, day/type filters"
```

---

### Task 9: WHO Growth Standards Data and Percentile Calculator

**Files:**
- Create: `uu/lib/services/who_growth_standards.dart`
- Test: `uu/test/services/who_growth_standards_test.dart`

This task embeds WHO Child Growth Standards LMS data (weight-for-age, length-for-age, head-circumference-for-age, 0-36 months) and implements percentile calculation using the LMS method.

**Step 1: Write the failing test**

```dart
// uu/test/services/who_growth_standards_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/who_growth_standards.dart';

void main() {
  group('WHOGrowthStandards', () {
    test('calculates weight-for-age percentile for a newborn boy', () {
      // WHO median weight for boys at birth: ~3.3 kg
      final percentile = WHOGrowthStandards.percentile(
        measurement: 3.3,
        ageMonths: 0,
        gender: Gender.male,
        type: MeasurementType.weight,
      );
      // 3.3 kg is close to 50th percentile for a newborn boy
      expect(percentile, closeTo(50, 10));
    });

    test('higher weight gives higher percentile', () {
      final p1 = WHOGrowthStandards.percentile(
        measurement: 3.0,
        ageMonths: 0,
        gender: Gender.male,
        type: MeasurementType.weight,
      );
      final p2 = WHOGrowthStandards.percentile(
        measurement: 4.0,
        ageMonths: 0,
        gender: Gender.male,
        type: MeasurementType.weight,
      );
      expect(p2, greaterThan(p1));
    });

    test('returns percentile curves for charting', () {
      final curves = WHOGrowthStandards.getCurves(
        gender: Gender.male,
        type: MeasurementType.weight,
        percentiles: [3, 15, 50, 85, 97],
      );
      expect(curves.keys, containsAll([3, 15, 50, 85, 97]));
      // Each curve should have data points for months 0-36
      expect(curves[50]!.length, greaterThanOrEqualTo(37));
    });

    test('female height-for-age at 12 months', () {
      // WHO median length for girls at 12 months: ~74 cm
      final percentile = WHOGrowthStandards.percentile(
        measurement: 74.0,
        ageMonths: 12,
        gender: Gender.female,
        type: MeasurementType.height,
      );
      expect(percentile, closeTo(50, 15));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/services/who_growth_standards_test.dart`
Expected: FAIL.

**Step 3: Write the WHO growth standards service**

This file will contain the LMS data tables from WHO and the percentile calculation. The LMS method: Z = ((measurement / M)^L - 1) / (L * S), then convert Z to percentile.

```dart
// uu/lib/services/who_growth_standards.dart
import 'dart:math';

enum Gender { male, female }
enum MeasurementType { weight, height, headCircumference }

class WHOGrowthStandards {
  WHOGrowthStandards._();

  /// Calculate percentile for a given measurement using WHO LMS method.
  /// Returns a value 0-100.
  static double percentile({
    required double measurement,
    required int ageMonths,
    required Gender gender,
    required MeasurementType type,
  }) {
    final lms = _getLMS(ageMonths, gender, type);
    if (lms == null) return -1;

    final z = _zScore(measurement, lms);
    return _zToPercentile(z);
  }

  /// Get percentile curves for charting.
  /// Returns Map<percentile, List<(month, value)>> for months 0-36.
  static Map<int, List<({int month, double value})>> getCurves({
    required Gender gender,
    required MeasurementType type,
    required List<int> percentiles,
  }) {
    final result = <int, List<({int month, double value})>>{};
    for (final p in percentiles) {
      final z = _percentileToZ(p.toDouble());
      final points = <({int month, double value})>[];
      for (var m = 0; m <= 36; m++) {
        final lms = _getLMS(m, gender, type);
        if (lms == null) continue;
        final value = _valueFromZ(z, lms);
        points.add((month: m, value: value));
      }
      result[p] = points;
    }
    return result;
  }

  static double _zScore(double x, _LMS lms) {
    if (lms.l.abs() < 0.001) {
      return log(x / lms.m) / lms.s;
    }
    return (pow(x / lms.m, lms.l) - 1) / (lms.l * lms.s);
  }

  static double _valueFromZ(double z, _LMS lms) {
    if (lms.l.abs() < 0.001) {
      return lms.m * exp(lms.s * z);
    }
    return lms.m * pow(1 + lms.l * lms.s * z, 1 / lms.l);
  }

  static double _zToPercentile(double z) {
    // Approximation of normal CDF
    return 100 * _normalCDF(z);
  }

  static double _percentileToZ(double p) {
    // Inverse normal CDF approximation (Beasley-Springer-Moro)
    final x = p / 100;
    if (x <= 0) return -4.0;
    if (x >= 1) return 4.0;

    // Rational approximation
    if (x < 0.5) {
      final t = sqrt(-2.0 * log(x));
      return -(2.515517 + t * (0.802853 + t * 0.010328)) /
          (1.0 + t * (1.432788 + t * (0.189269 + t * 0.001308)));
    } else {
      final t = sqrt(-2.0 * log(1.0 - x));
      return (2.515517 + t * (0.802853 + t * 0.010328)) /
          (1.0 + t * (1.432788 + t * (0.189269 + t * 0.001308)));
    }
  }

  static double _normalCDF(double z) {
    // Abramowitz and Stegun approximation
    const a1 = 0.254829592;
    const a2 = -0.284496736;
    const a3 = 1.421413741;
    const a4 = -1.453152027;
    const a5 = 1.061405429;
    const p = 0.3275911;

    final sign = z < 0 ? -1.0 : 1.0;
    final x = z.abs() / sqrt(2);
    final t = 1.0 / (1.0 + p * x);
    final y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-x * x);

    return 0.5 * (1.0 + sign * y);
  }

  static _LMS? _getLMS(int ageMonths, Gender gender, MeasurementType type) {
    if (ageMonths < 0 || ageMonths > 36) return null;
    switch (type) {
      case MeasurementType.weight:
        return gender == Gender.male
            ? _weightBoys[ageMonths]
            : _weightGirls[ageMonths];
      case MeasurementType.height:
        return gender == Gender.male
            ? _heightBoys[ageMonths]
            : _heightGirls[ageMonths];
      case MeasurementType.headCircumference:
        return gender == Gender.male
            ? _headBoys[ageMonths]
            : _headGirls[ageMonths];
    }
  }

  // WHO Child Growth Standards LMS values (0-36 months)
  // Source: WHO Multicentre Growth Reference Study

  // Weight-for-age BOYS (L, M, S)
  static const _weightBoys = <_LMS>[
    _LMS(0.3487, 3.3464, 0.14602), // 0 months
    _LMS(0.2297, 4.4709, 0.13395),
    _LMS(0.1970, 5.5675, 0.12385),
    _LMS(0.1738, 6.3762, 0.11727),
    _LMS(0.1553, 7.0023, 0.11316),
    _LMS(0.1395, 7.5105, 0.10980),
    _LMS(0.1257, 7.9340, 0.10728),
    _LMS(0.1134, 8.2970, 0.10535),
    _LMS(0.1021, 8.6151, 0.10391),
    _LMS(0.0917, 8.9014, 0.10285),
    _LMS(0.0820, 9.1649, 0.10212),
    _LMS(0.0730, 9.4122, 0.10165),
    _LMS(0.0644, 9.6479, 0.10142), // 12 months
    _LMS(0.0563, 9.8749, 0.10139),
    _LMS(0.0487, 10.0953, 0.10154),
    _LMS(0.0413, 10.3108, 0.10183),
    _LMS(0.0343, 10.5228, 0.10225),
    _LMS(0.0275, 10.7319, 0.10278),
    _LMS(0.0211, 10.9385, 0.10339),
    _LMS(0.0148, 11.1430, 0.10408),
    _LMS(0.0087, 11.3462, 0.10482),
    _LMS(0.0029, 11.5486, 0.10561),
    _LMS(-0.0028, 11.7504, 0.10644),
    _LMS(-0.0083, 11.9514, 0.10730),
    _LMS(-0.0137, 12.1515, 0.10819), // 24 months
    _LMS(-0.0189, 12.3502, 0.10910),
    _LMS(-0.0240, 12.5466, 0.11003),
    _LMS(-0.0289, 12.7401, 0.11098),
    _LMS(-0.0337, 12.9303, 0.11194),
    _LMS(-0.0385, 13.1169, 0.11291),
    _LMS(-0.0431, 13.2999, 0.11390),
    _LMS(-0.0476, 13.4800, 0.11490),
    _LMS(-0.0520, 13.6576, 0.11590),
    _LMS(-0.0563, 13.8330, 0.11692),
    _LMS(-0.0605, 14.0069, 0.11795),
    _LMS(-0.0646, 14.1795, 0.11899),
    _LMS(-0.0687, 14.3514, 0.12003), // 36 months
  ];

  // Weight-for-age GIRLS (L, M, S)
  static const _weightGirls = <_LMS>[
    _LMS(0.3809, 3.2322, 0.14171), // 0 months
    _LMS(0.1714, 4.1873, 0.13724),
    _LMS(0.0962, 5.1282, 0.12926),
    _LMS(0.0402, 5.8458, 0.12330),
    _LMS(-0.0050, 6.4237, 0.11872),
    _LMS(-0.0430, 6.8985, 0.11520),
    _LMS(-0.0756, 7.2970, 0.11257),
    _LMS(-0.1039, 7.6422, 0.11068),
    _LMS(-0.1288, 7.9487, 0.10937),
    _LMS(-0.1507, 8.2254, 0.10854),
    _LMS(-0.1700, 8.4800, 0.10811),
    _LMS(-0.1872, 8.7192, 0.10800),
    _LMS(-0.2024, 8.9481, 0.10817), // 12 months
    _LMS(-0.2158, 9.1699, 0.10856),
    _LMS(-0.2278, 9.3870, 0.10915),
    _LMS(-0.2384, 9.6008, 0.10989),
    _LMS(-0.2478, 9.8124, 0.11076),
    _LMS(-0.2562, 10.0226, 0.11173),
    _LMS(-0.2637, 10.2315, 0.11278),
    _LMS(-0.2703, 10.4393, 0.11390),
    _LMS(-0.2762, 10.6464, 0.11507),
    _LMS(-0.2815, 10.8534, 0.11628),
    _LMS(-0.2862, 11.0608, 0.11753),
    _LMS(-0.2903, 11.2688, 0.11880),
    _LMS(-0.2941, 11.4775, 0.12011), // 24 months
    _LMS(-0.2975, 11.6864, 0.12143),
    _LMS(-0.3005, 11.8947, 0.12278),
    _LMS(-0.3032, 12.1015, 0.12415),
    _LMS(-0.3057, 12.3059, 0.12553),
    _LMS(-0.3080, 12.5073, 0.12693),
    _LMS(-0.3101, 12.7055, 0.12834),
    _LMS(-0.3120, 12.9006, 0.12977),
    _LMS(-0.3138, 13.0930, 0.13121),
    _LMS(-0.3154, 13.2837, 0.13266),
    _LMS(-0.3170, 13.4731, 0.13413),
    _LMS(-0.3184, 13.6618, 0.13561),
    _LMS(-0.3197, 13.8503, 0.13710), // 36 months
  ];

  // Length/height-for-age BOYS (L, M, S)
  static const _heightBoys = <_LMS>[
    _LMS(1, 49.8842, 0.03795), // 0 months
    _LMS(1, 54.7244, 0.03557),
    _LMS(1, 58.4249, 0.03424),
    _LMS(1, 61.4292, 0.03328),
    _LMS(1, 63.8860, 0.03257),
    _LMS(1, 65.9026, 0.03204),
    _LMS(1, 67.6236, 0.03165),
    _LMS(1, 69.1645, 0.03139),
    _LMS(1, 70.5994, 0.03124),
    _LMS(1, 71.9687, 0.03117),
    _LMS(1, 73.2812, 0.03118),
    _LMS(1, 74.5388, 0.03126),
    _LMS(1, 75.7488, 0.03141), // 12 months
    _LMS(1, 76.9186, 0.03160),
    _LMS(1, 78.0497, 0.03183),
    _LMS(1, 79.1458, 0.03209),
    _LMS(1, 80.2113, 0.03238),
    _LMS(1, 81.2487, 0.03268),
    _LMS(1, 82.2587, 0.03300),
    _LMS(1, 83.2418, 0.03333),
    _LMS(1, 84.1996, 0.03366),
    _LMS(1, 85.1348, 0.03399),
    _LMS(1, 86.0477, 0.03432),
    _LMS(1, 86.9410, 0.03466),
    _LMS(1, 87.8161, 0.03500), // 24 months
    _LMS(1, 88.2656, 0.03524),
    _LMS(1, 89.0481, 0.03557),
    _LMS(1, 89.8140, 0.03590),
    _LMS(1, 90.5647, 0.03624),
    _LMS(1, 91.3009, 0.03657),
    _LMS(1, 92.0233, 0.03690),
    _LMS(1, 92.7321, 0.03724),
    _LMS(1, 93.4274, 0.03757),
    _LMS(1, 94.1099, 0.03791),
    _LMS(1, 94.7800, 0.03824),
    _LMS(1, 95.4385, 0.03858),
    _LMS(1, 96.0857, 0.03891), // 36 months
  ];

  // Length/height-for-age GIRLS (L, M, S)
  static const _heightGirls = <_LMS>[
    _LMS(1, 49.1477, 0.03790), // 0 months
    _LMS(1, 53.6872, 0.03610),
    _LMS(1, 57.0673, 0.03514),
    _LMS(1, 59.8029, 0.03447),
    _LMS(1, 62.0899, 0.03402),
    _LMS(1, 63.9818, 0.03371),
    _LMS(1, 65.7311, 0.03351),
    _LMS(1, 67.2873, 0.03340),
    _LMS(1, 68.7498, 0.03337),
    _LMS(1, 70.1435, 0.03340),
    _LMS(1, 71.4818, 0.03349),
    _LMS(1, 72.7710, 0.03363),
    _LMS(1, 74.0153, 0.03381), // 12 months
    _LMS(1, 75.2176, 0.03403),
    _LMS(1, 76.3817, 0.03428),
    _LMS(1, 77.5099, 0.03456),
    _LMS(1, 78.6055, 0.03487),
    _LMS(1, 79.6710, 0.03519),
    _LMS(1, 80.7079, 0.03553),
    _LMS(1, 81.7182, 0.03588),
    _LMS(1, 82.7036, 0.03624),
    _LMS(1, 83.6654, 0.03660),
    _LMS(1, 84.6040, 0.03697),
    _LMS(1, 85.5210, 0.03735),
    _LMS(1, 86.4160, 0.03773), // 24 months
    _LMS(1, 86.8536, 0.03798),
    _LMS(1, 87.6993, 0.03835),
    _LMS(1, 88.5288, 0.03873),
    _LMS(1, 89.3425, 0.03911),
    _LMS(1, 90.1411, 0.03949),
    _LMS(1, 90.9252, 0.03988),
    _LMS(1, 91.6952, 0.04027),
    _LMS(1, 92.4515, 0.04066),
    _LMS(1, 93.1944, 0.04106),
    _LMS(1, 93.9244, 0.04145),
    _LMS(1, 94.6415, 0.04185),
    _LMS(1, 95.3464, 0.04226), // 36 months
  ];

  // Head-circumference-for-age BOYS (L, M, S)
  static const _headBoys = <_LMS>[
    _LMS(1, 34.4618, 0.03686), // 0 months
    _LMS(1, 37.2759, 0.03133),
    _LMS(1, 39.1285, 0.02997),
    _LMS(1, 40.5135, 0.02918),
    _LMS(1, 41.6317, 0.02868),
    _LMS(1, 42.5576, 0.02837),
    _LMS(1, 43.3306, 0.02817),
    _LMS(1, 43.9803, 0.02804),
    _LMS(1, 44.5300, 0.02796),
    _LMS(1, 44.9998, 0.02792),
    _LMS(1, 45.4051, 0.02790),
    _LMS(1, 45.7573, 0.02790),
    _LMS(1, 46.0661, 0.02791), // 12 months
    _LMS(1, 46.3395, 0.02794),
    _LMS(1, 46.5844, 0.02797),
    _LMS(1, 46.8060, 0.02801),
    _LMS(1, 47.0088, 0.02806),
    _LMS(1, 47.1962, 0.02810),
    _LMS(1, 47.3711, 0.02815),
    _LMS(1, 47.5357, 0.02820),
    _LMS(1, 47.6919, 0.02825),
    _LMS(1, 47.8408, 0.02830),
    _LMS(1, 47.9833, 0.02835),
    _LMS(1, 48.1201, 0.02840),
    _LMS(1, 48.2515, 0.02846), // 24 months
    _LMS(1, 48.3777, 0.02851),
    _LMS(1, 48.4990, 0.02856),
    _LMS(1, 48.6155, 0.02862),
    _LMS(1, 48.7275, 0.02867),
    _LMS(1, 48.8352, 0.02872),
    _LMS(1, 48.9388, 0.02877),
    _LMS(1, 49.0385, 0.02883),
    _LMS(1, 49.1346, 0.02888),
    _LMS(1, 49.2272, 0.02893),
    _LMS(1, 49.3165, 0.02898),
    _LMS(1, 49.4027, 0.02903),
    _LMS(1, 49.4860, 0.02908), // 36 months
  ];

  // Head-circumference-for-age GIRLS (L, M, S)
  static const _headGirls = <_LMS>[
    _LMS(1, 33.8787, 0.03496), // 0 months
    _LMS(1, 36.5463, 0.03080),
    _LMS(1, 38.2521, 0.02960),
    _LMS(1, 39.5280, 0.02891),
    _LMS(1, 40.5817, 0.02847),
    _LMS(1, 41.4590, 0.02819),
    _LMS(1, 42.1995, 0.02800),
    _LMS(1, 42.8290, 0.02788),
    _LMS(1, 43.3671, 0.02781),
    _LMS(1, 43.8300, 0.02777),
    _LMS(1, 44.2319, 0.02776),
    _LMS(1, 44.5844, 0.02776),
    _LMS(1, 44.8965, 0.02778), // 12 months
    _LMS(1, 45.1752, 0.02781),
    _LMS(1, 45.4265, 0.02785),
    _LMS(1, 45.6551, 0.02789),
    _LMS(1, 45.8650, 0.02794),
    _LMS(1, 46.0598, 0.02799),
    _LMS(1, 46.2424, 0.02804),
    _LMS(1, 46.4152, 0.02809),
    _LMS(1, 46.5801, 0.02814),
    _LMS(1, 46.7384, 0.02819),
    _LMS(1, 46.8913, 0.02824),
    _LMS(1, 47.0391, 0.02829),
    _LMS(1, 47.1822, 0.02834), // 24 months
    _LMS(1, 47.3207, 0.02839),
    _LMS(1, 47.4549, 0.02844),
    _LMS(1, 47.5845, 0.02849),
    _LMS(1, 47.7098, 0.02854),
    _LMS(1, 47.8310, 0.02859),
    _LMS(1, 47.9483, 0.02864),
    _LMS(1, 48.0618, 0.02869),
    _LMS(1, 48.1717, 0.02874),
    _LMS(1, 48.2783, 0.02879),
    _LMS(1, 48.3816, 0.02884),
    _LMS(1, 48.4819, 0.02889),
    _LMS(1, 48.5793, 0.02894), // 36 months
  ];
}

class _LMS {
  final double l, m, s;
  const _LMS(this.l, this.m, this.s);
}
```

**Step 4: Run tests**

Run: `cd uu && flutter test test/services/who_growth_standards_test.dart -v`
Expected: All 4 tests PASS.

**Step 5: Commit**

```bash
git add uu/lib/services/who_growth_standards.dart uu/test/services/who_growth_standards_test.dart
git commit -m "feat: add WHO growth standards with LMS percentile calculation"
```

---

### Task 10: Timer Service for Live Tracking

**Files:**
- Create: `uu/lib/services/timer_service.dart`
- Test: `uu/test/services/timer_service_test.dart`

**Step 1: Write the failing test**

```dart
// uu/test/services/timer_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/timer_service.dart';

void main() {
  group('TimerService', () {
    late TimerService service;

    setUp(() {
      service = TimerService();
    });

    tearDown(() {
      service.dispose();
    });

    test('starts with no active timer', () {
      expect(service.isRunning, false);
      expect(service.activeTimer, isNull);
    });

    test('can start a feeding timer', () {
      service.start(TimerType.feeding, metadata: {'side': 'left'});

      expect(service.isRunning, true);
      expect(service.activeTimer?.type, TimerType.feeding);
      expect(service.activeTimer?.metadata['side'], 'left');
    });

    test('elapsed time increases', () async {
      service.start(TimerType.feeding);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(service.activeTimer!.elapsed.inMilliseconds, greaterThan(50));
    });

    test('can pause and resume', () async {
      service.start(TimerType.sleep);
      await Future.delayed(const Duration(milliseconds: 100));

      service.pause();
      expect(service.isPaused, true);
      final pausedElapsed = service.activeTimer!.elapsed;

      await Future.delayed(const Duration(milliseconds: 100));
      // Elapsed should not increase while paused
      expect(service.activeTimer!.elapsed.inMilliseconds,
          closeTo(pausedElapsed.inMilliseconds, 20));

      service.resume();
      expect(service.isPaused, false);
    });

    test('stop returns the timer result', () async {
      service.start(TimerType.feeding, metadata: {'side': 'left'});
      await Future.delayed(const Duration(milliseconds: 100));

      final result = service.stop();
      expect(result, isNotNull);
      expect(result!.type, TimerType.feeding);
      expect(result.startedAt, isNotNull);
      expect(result.endedAt, isNotNull);
      expect(result.duration.inMilliseconds, greaterThan(50));
      expect(service.isRunning, false);
    });

    test('emits state changes via stream', () async {
      expectLater(
        service.stateStream,
        emitsInOrder([
          predicate<TimerState>((s) => s.isRunning),
          predicate<TimerState>((s) => !s.isRunning),
        ]),
      );

      service.start(TimerType.feeding);
      await Future.delayed(const Duration(milliseconds: 50));
      service.stop();
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/services/timer_service_test.dart`
Expected: FAIL.

**Step 3: Write the timer service**

```dart
// uu/lib/services/timer_service.dart
import 'dart:async';

enum TimerType { feeding, sleep, tummyTime }

class ActiveTimer {
  final TimerType type;
  final DateTime startedAt;
  final Map<String, dynamic> metadata;
  DateTime? _pausedAt;
  Duration _pausedDuration = Duration.zero;

  ActiveTimer({
    required this.type,
    required this.startedAt,
    this.metadata = const {},
  });

  Duration get elapsed {
    if (_pausedAt != null) {
      return _pausedAt!.difference(startedAt) - _pausedDuration;
    }
    return DateTime.now().difference(startedAt) - _pausedDuration;
  }

  bool get isPaused => _pausedAt != null;

  void pause() {
    if (_pausedAt == null) _pausedAt = DateTime.now();
  }

  void resume() {
    if (_pausedAt != null) {
      _pausedDuration += DateTime.now().difference(_pausedAt!);
      _pausedAt = null;
    }
  }
}

class TimerResult {
  final TimerType type;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;
  final Map<String, dynamic> metadata;

  TimerResult({
    required this.type,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    required this.metadata,
  });
}

class TimerState {
  final bool isRunning;
  final bool isPaused;
  final TimerType? type;

  TimerState({this.isRunning = false, this.isPaused = false, this.type});
}

class TimerService {
  ActiveTimer? _activeTimer;
  final _stateController = StreamController<TimerState>.broadcast();

  ActiveTimer? get activeTimer => _activeTimer;
  bool get isRunning => _activeTimer != null && !(_activeTimer!.isPaused);
  bool get isPaused => _activeTimer?.isPaused ?? false;
  Stream<TimerState> get stateStream => _stateController.stream;

  void start(TimerType type, {Map<String, dynamic> metadata = const {}}) {
    _activeTimer = ActiveTimer(
      type: type,
      startedAt: DateTime.now(),
      metadata: Map.from(metadata),
    );
    _emitState();
  }

  void pause() {
    _activeTimer?.pause();
    _emitState();
  }

  void resume() {
    _activeTimer?.resume();
    _emitState();
  }

  TimerResult? stop() {
    if (_activeTimer == null) return null;

    final timer = _activeTimer!;
    if (timer.isPaused) timer.resume();

    final result = TimerResult(
      type: timer.type,
      startedAt: timer.startedAt,
      endedAt: DateTime.now(),
      duration: timer.elapsed,
      metadata: timer.metadata,
    );

    _activeTimer = null;
    _emitState();
    return result;
  }

  void _emitState() {
    _stateController.add(TimerState(
      isRunning: _activeTimer != null,
      isPaused: isPaused,
      type: _activeTimer?.type,
    ));
  }

  void dispose() {
    _stateController.close();
  }
}
```

**Step 4: Run tests**

Run: `cd uu && flutter test test/services/timer_service_test.dart -v`
Expected: All 6 tests PASS.

**Step 5: Commit**

```bash
git add uu/lib/services/timer_service.dart uu/test/services/timer_service_test.dart
git commit -m "feat: add TimerService for live feeding/sleep/tummy-time tracking"
```

---

### Task 11: Today's Summary Aggregation Service

**Files:**
- Create: `uu/lib/services/daily_summary_service.dart`
- Test: `uu/test/services/daily_summary_service_test.dart`

**Step 1: Write the failing test**

```dart
// uu/test/services/daily_summary_service_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/daily_log_repository.dart';
import 'package:uu/services/daily_summary_service.dart';

void main() {
  late AppDatabase db;
  late DailyLogRepository logRepo;
  late DailySummaryService service;
  late int babyId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    logRepo = DailyLogRepository(db);
    service = DailySummaryService(logRepo);
    babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
      name: 'Luna',
      dateOfBirth: DateTime(2025, 6, 15),
    ));
  });

  tearDown(() async => await db.close());

  group('DailySummaryService', () {
    test('empty day returns zero counts', () async {
      final summary = await service.getSummary(babyId, DateTime(2025, 7, 15));

      expect(summary.feedingCount, 0);
      expect(summary.totalSleepMinutes, 0);
      expect(summary.diaperCount, 0);
    });

    test('counts feedings correctly', () async {
      await logRepo.createLog(babyId: babyId, type: 'feeding', startedAt: DateTime(2025, 7, 15, 8, 0));
      await logRepo.createLog(babyId: babyId, type: 'feeding', startedAt: DateTime(2025, 7, 15, 11, 0));
      await logRepo.createLog(babyId: babyId, type: 'feeding', startedAt: DateTime(2025, 7, 15, 14, 0));

      final summary = await service.getSummary(babyId, DateTime(2025, 7, 15));
      expect(summary.feedingCount, 3);
    });

    test('sums sleep duration', () async {
      await logRepo.createLog(
        babyId: babyId,
        type: 'sleep',
        startedAt: DateTime(2025, 7, 15, 13, 0),
        endedAt: DateTime(2025, 7, 15, 15, 0),
      );
      await logRepo.createLog(
        babyId: babyId,
        type: 'sleep',
        startedAt: DateTime(2025, 7, 15, 20, 0),
        endedAt: DateTime(2025, 7, 15, 23, 0),
      );

      final summary = await service.getSummary(babyId, DateTime(2025, 7, 15));
      expect(summary.totalSleepMinutes, 300); // 2h + 3h = 300 min
    });

    test('counts diapers correctly', () async {
      await logRepo.createLog(babyId: babyId, type: 'diaper', startedAt: DateTime(2025, 7, 15, 8, 0));
      await logRepo.createLog(babyId: babyId, type: 'diaper', startedAt: DateTime(2025, 7, 15, 12, 0));

      final summary = await service.getSummary(babyId, DateTime(2025, 7, 15));
      expect(summary.diaperCount, 2);
    });

    test('finds last feeding time', () async {
      await logRepo.createLog(babyId: babyId, type: 'feeding', startedAt: DateTime(2025, 7, 15, 8, 0));
      await logRepo.createLog(babyId: babyId, type: 'feeding', startedAt: DateTime(2025, 7, 15, 14, 30));

      final summary = await service.getSummary(babyId, DateTime(2025, 7, 15));
      expect(summary.lastFeedingAt, DateTime(2025, 7, 15, 14, 30));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/services/daily_summary_service_test.dart`
Expected: FAIL.

**Step 3: Write the service**

```dart
// uu/lib/services/daily_summary_service.dart
import 'package:uu/repositories/daily_log_repository.dart';

class DailySummary {
  final int feedingCount;
  final int totalSleepMinutes;
  final int diaperCount;
  final int moodCount;
  final DateTime? lastFeedingAt;
  final DateTime? lastDiaperAt;

  DailySummary({
    this.feedingCount = 0,
    this.totalSleepMinutes = 0,
    this.diaperCount = 0,
    this.moodCount = 0,
    this.lastFeedingAt,
    this.lastDiaperAt,
  });
}

class DailySummaryService {
  final DailyLogRepository _logRepo;

  DailySummaryService(this._logRepo);

  Future<DailySummary> getSummary(int babyId, DateTime day) async {
    final logs = await _logRepo.getLogsForDay(babyId, day);

    final feedings = logs.where((l) => l.type == 'feeding').toList();
    final sleeps = logs.where((l) => l.type == 'sleep').toList();
    final diapers = logs.where((l) => l.type == 'diaper').toList();
    final moods = logs.where((l) => l.type == 'mood').toList();

    final totalSleep = sleeps.fold<int>(0, (sum, log) {
      if (log.endedAt != null) {
        return sum + log.endedAt!.difference(log.startedAt).inMinutes;
      }
      return sum + (log.durationMinutes ?? 0);
    });

    return DailySummary(
      feedingCount: feedings.length,
      totalSleepMinutes: totalSleep,
      diaperCount: diapers.length,
      moodCount: moods.length,
      lastFeedingAt: feedings.isNotEmpty ? feedings.first.startedAt : null,
      lastDiaperAt: diapers.isNotEmpty ? diapers.first.startedAt : null,
    );
  }
}
```

**Step 4: Run tests**

Run: `cd uu && flutter test test/services/daily_summary_service_test.dart -v`
Expected: All 5 tests PASS.

**Step 5: Commit**

```bash
git add uu/lib/services/daily_summary_service.dart uu/test/services/daily_summary_service_test.dart
git commit -m "feat: add DailySummaryService for today's feeding/sleep/diaper counts"
```

---

### Task 12: Riverpod Providers for Repositories and Services

**Files:**
- Create: `uu/lib/providers/baby_provider.dart`
- Create: `uu/lib/providers/growth_provider.dart`
- Create: `uu/lib/providers/daily_log_provider.dart`
- Create: `uu/lib/providers/timer_provider.dart`
- Modify: `uu/lib/providers/providers.dart`

**Step 1: Write the providers**

These are thin wiring — they connect repositories/services to the Riverpod dependency graph.

```dart
// uu/lib/providers/baby_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/repositories/baby_repository.dart';

final babyRepositoryProvider = Provider<BabyRepository>((ref) {
  return BabyRepository(ref.watch(databaseProvider));
});

final allBabiesProvider = FutureProvider<List<Baby>>((ref) {
  return ref.watch(babyRepositoryProvider).getAllBabies();
});

// Currently selected baby ID (set after onboarding or selection)
final selectedBabyIdProvider = StateProvider<int?>((ref) => null);
```

Note: The `Baby` type comes from Drift's generated code in `app_database.dart`.

```dart
// uu/lib/providers/growth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/repositories/growth_repository.dart';

final growthRepositoryProvider = Provider<GrowthRepository>((ref) {
  return GrowthRepository(ref.watch(databaseProvider));
});

final growthRecordsProvider = StreamProvider<List<GrowthRecord>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref.watch(growthRepositoryProvider).watchRecordsForBaby(babyId);
});
```

Note: The `GrowthRecord` type comes from Drift's generated code.

```dart
// uu/lib/providers/daily_log_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/repositories/daily_log_repository.dart';
import 'package:uu/services/daily_summary_service.dart';

final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  return DailyLogRepository(ref.watch(databaseProvider));
});

final todayLogsProvider = StreamProvider<List<DailyLog>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref.watch(dailyLogRepositoryProvider).watchLogsForDay(babyId, DateTime.now());
});

final dailySummaryServiceProvider = Provider<DailySummaryService>((ref) {
  return DailySummaryService(ref.watch(dailyLogRepositoryProvider));
});

final todaySummaryProvider = FutureProvider<DailySummary>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return DailySummary();
  // Re-compute when logs change
  ref.watch(todayLogsProvider);
  return ref.watch(dailySummaryServiceProvider).getSummary(babyId, DateTime.now());
});
```

Note: The `DailyLog` type comes from Drift's generated code.

```dart
// uu/lib/providers/timer_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/services/timer_service.dart';

final timerServiceProvider = Provider<TimerService>((ref) {
  final service = TimerService();
  ref.onDispose(() => service.dispose());
  return service;
});

final timerStateProvider = StreamProvider<TimerState>((ref) {
  return ref.watch(timerServiceProvider).stateStream;
});
```

Update barrel export:

```dart
// uu/lib/providers/providers.dart
export 'database_provider.dart';
export 'theme_provider.dart';
export 'baby_provider.dart';
export 'growth_provider.dart';
export 'daily_log_provider.dart';
export 'timer_provider.dart';
```

**Step 2: Verify build**

Run: `cd uu && flutter analyze`
Expected: No analysis errors.

**Step 3: Commit**

```bash
git add uu/lib/providers/
git commit -m "feat: add Riverpod providers for all repositories and services"
```

---

### Task 13: Home Screen with Quick-Log Buttons and Today's Summary

**Files:**
- Modify: `uu/lib/screens/home/home_screen.dart`
- Create: `uu/lib/screens/home/widgets/quick_log_buttons.dart`
- Create: `uu/lib/screens/home/widgets/today_summary_card.dart`
- Create: `uu/lib/screens/home/widgets/growth_snapshot_card.dart`
- Test: `uu/test/screens/home/home_screen_test.dart`

**Step 1: Write the failing test**

```dart
// uu/test/screens/home/home_screen_test.dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/screens/home/home_screen.dart';

void main() {
  group('HomeScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async => await db.close());

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          selectedBabyIdProvider.overrideWith((ref) => 1),
        ],
        child: const MaterialApp(home: Scaffold(body: HomeScreen())),
      );
    }

    testWidgets('shows quick-log buttons', (tester) async {
      // Create a baby first
      await db.into(db.babies).insert(BabiesCompanion.insert(
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
      ));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Fed'), findsOneWidget);
      expect(find.text('Diaper'), findsOneWidget);
      expect(find.text('Sleep'), findsOneWidget);
    });

    testWidgets('shows today summary section', (tester) async {
      await db.into(db.babies).insert(BabiesCompanion.insert(
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
      ));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text("Today's Summary"), findsOneWidget);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `cd uu && flutter test test/screens/home/home_screen_test.dart`
Expected: FAIL.

**Step 3: Build the home screen and widgets**

Create the quick-log buttons widget, today summary card, growth snapshot card, and assemble them in the home screen. The quick-log buttons should use `GestureDetector` with `onTap` for instant logging and `onLongPress` to open the full form (to be implemented later).

The home screen should be a `SingleChildScrollView` with sections:
1. Baby name + age header
2. Quick-log action buttons (Fed, Diaper, Sleep, Mood, Timer)
3. Today's summary card
4. Growth snapshot card (latest measurement + percentile)

Implementation code is provided in the widgets — use `ConsumerWidget` to read from Riverpod providers. The quick-log buttons call `dailyLogRepositoryProvider.quickLog()`. Today's summary reads from `todaySummaryProvider`. Growth snapshot reads from `growthRecordsProvider`.

**Step 4: Run tests**

Run: `cd uu && flutter test test/screens/home/home_screen_test.dart -v`
Expected: All tests PASS.

**Step 5: Commit**

```bash
git add uu/lib/screens/home/ uu/test/screens/home/
git commit -m "feat: add HomeScreen with quick-log buttons and today's summary"
```

---

### Task 14: Logs Timeline Screen with Filters

**Files:**
- Modify: `uu/lib/screens/logs/logs_screen.dart`
- Create: `uu/lib/screens/logs/widgets/log_timeline_item.dart`
- Test: `uu/test/screens/logs/logs_screen_test.dart`

Build a timeline view showing all daily logs for the selected day, with chip-based filters for type (All, Feeding, Sleep, Diaper, Mood). Each item shows: icon, type, time, duration (if applicable), and metadata summary.

Follow TDD pattern: write test expecting filter chips and timeline items → implement → verify → commit.

**Commit message:** `feat: add Logs timeline screen with type filters`

---

### Task 15: Growth Chart Screen with WHO Percentile Curves

**Files:**
- Create: `uu/lib/screens/growth/growth_chart_screen.dart`
- Create: `uu/lib/screens/growth/widgets/percentile_chart.dart`
- Create: `uu/lib/screens/growth/widgets/growth_entry_form.dart`
- Test: `uu/test/screens/growth/growth_chart_screen_test.dart`

Build a screen with three tabs (Weight, Height, Head) each showing an `fl_chart` `LineChart` with WHO percentile curves (3rd, 15th, 50th, 85th, 97th) and the baby's data points plotted. Use the `WHOGrowthStandards.getCurves()` method for curve data and `growthRecordsProvider` for baby's data.

Include a FAB to add a new measurement via a bottom sheet form.

Follow TDD pattern: write test for chart rendering and form submission → implement → verify → commit.

**Commit message:** `feat: add Growth Chart screen with WHO percentile curves`

---

## Phase 1 continued: Timer UI and Notifications (Tasks 16-18)

### Task 16: Timer Mini-Bar Widget

**Files:**
- Create: `uu/lib/widgets/timer_mini_bar.dart`
- Modify: `uu/lib/screens/shell/app_shell.dart`
- Test: `uu/test/widgets/timer_mini_bar_test.dart`

Build a persistent mini-bar (like Spotify's mini player) that appears below the app bar when a timer is active. Shows: timer type icon, elapsed time (updating every second), and pause/stop buttons. Tapping expands to a full timer view as a bottom sheet.

Integrate into `AppShell` — conditionally show the mini-bar based on `timerStateProvider`.

Follow TDD: test mini-bar visibility toggling, elapsed time display, pause/stop actions → implement → commit.

**Commit message:** `feat: add persistent timer mini-bar widget`

---

### Task 17: Baby Onboarding Flow

**Files:**
- Create: `uu/lib/screens/onboarding/onboarding_screen.dart`
- Create: `uu/lib/screens/onboarding/widgets/baby_form.dart`
- Modify: `uu/lib/config/router.dart`
- Test: `uu/test/screens/onboarding/onboarding_screen_test.dart`

Build an onboarding flow that shows when no baby exists in the database. Collects: baby name, date of birth, gender (optional), photo (optional). On submission, creates the baby via `BabyRepository` and navigates to the home screen.

Update the router to check for existing babies and redirect to onboarding if none found.

Follow TDD: test form validation, baby creation, and navigation redirect → implement → commit.

**Commit message:** `feat: add baby onboarding flow`

---

### Task 18: Local Notifications for User-Set Reminders

**Files:**
- Create: `uu/lib/services/notification_service.dart`
- Create: `uu/lib/screens/settings/notification_settings_screen.dart`
- Test: `uu/test/services/notification_service_test.dart`

Set up `flutter_local_notifications` for scheduling repeating reminders. Support feeding and diaper reminders with user-configurable intervals (e.g., every 2 hours, every 3 hours). Store settings in the Drift database using a `notification_settings` table (add to schema, bump version, run code gen).

Follow TDD: test scheduling logic, interval calculation → implement → commit.

**Commit message:** `feat: add local notification service with feeding/diaper reminders`

---

## Phase 2: Intelligence (Tasks 19-24)

### Task 19: Add Remaining Database Tables

**Files:**
- Create: `uu/lib/database/tables/milestones_table.dart`
- Create: `uu/lib/database/tables/vaccinations_table.dart`
- Create: `uu/lib/database/tables/health_events_table.dart`
- Create: `uu/lib/database/tables/food_introductions_table.dart`
- Create: `uu/lib/database/tables/teeth_records_table.dart`
- Create: `uu/lib/database/tables/chat_messages_table.dart`
- Create: `uu/lib/database/tables/media_table.dart`
- Create: `uu/lib/database/tables/notification_settings_table.dart`
- Modify: `uu/lib/database/app_database.dart` (add all tables, bump schema version, add migration)
- Test: `uu/test/database/migration_test.dart`

Add all remaining tables from the design doc. Run code generation. Write migration from schema v1 to v2. Test that migration preserves existing data.

**Commit message:** `feat: add all remaining database tables with migration`

---

### Task 20: AI Provider Interface and Gemini Implementation

**Files:**
- Create: `uu/lib/services/ai/ai_provider.dart` (abstract interface)
- Create: `uu/lib/services/ai/gemini_provider.dart`
- Create: `uu/lib/services/ai/baby_context_builder.dart`
- Test: `uu/test/services/ai/gemini_provider_test.dart`
- Test: `uu/test/services/ai/baby_context_builder_test.dart`

Define the pluggable `AIProvider` interface:
```dart
abstract class AIProvider {
  Future<String> chat(List<ChatMessage> messages, BabyContext context);
  Future<AnalysisResult> analyze(AnalysisRequest request);
}
```

Implement `GeminiProvider` using `package:google_generative_ai`. Add to `pubspec.yaml`.

Implement `BabyContextBuilder` that pulls last 7 days of logs, latest growth percentiles, recent milestones, and constructs a system prompt.

Follow TDD: test context builder with mock data, test provider interface contract → implement → commit.

**Commit message:** `feat: add pluggable AI provider interface with Gemini implementation`

---

### Task 21: AI Chat Screen

**Files:**
- Modify: `uu/lib/screens/chat/chat_screen.dart`
- Create: `uu/lib/screens/chat/widgets/chat_bubble.dart`
- Create: `uu/lib/screens/chat/widgets/quick_concern_chips.dart`
- Create: `uu/lib/repositories/chat_repository.dart`
- Create: `uu/lib/providers/chat_provider.dart`
- Test: `uu/test/screens/chat/chat_screen_test.dart`

Build the chat interface with:
- Quick-concern chips at top (Sleep, Feeding, Skin/Rash, Behavior, Growth)
- Message list with user/assistant bubbles
- Text input with send button
- Medical disclaimer on every AI response
- Messages persisted to `chat_messages` table

Follow TDD: test message display, sending, quick-concern chip interaction → implement → commit.

**Commit message:** `feat: add AI chat screen with quick-concern chips`

---

### Task 22: Growth Anomaly Detection

**Files:**
- Create: `uu/lib/services/analysis/growth_analyzer.dart`
- Test: `uu/test/services/analysis/growth_analyzer_test.dart`

Implement logic to detect:
- Measurement crossing percentile lines (e.g., dropping from 50th to below 15th)
- Deviation >1 SD from baby's own trend
- Sudden weight loss or stagnation

Returns `GrowthAlert` objects with severity and recommendation.

Follow TDD → commit.

**Commit message:** `feat: add growth anomaly detection service`

---

### Task 23: Smart Notification Engine (AI-Suggested Intervals)

**Files:**
- Create: `uu/lib/services/analysis/interval_analyzer.dart`
- Create: `uu/lib/services/smart_notification_service.dart`
- Test: `uu/test/services/analysis/interval_analyzer_test.dart`

Analyze last 7 days of feeding/diaper logs to calculate average intervals and suggest optimal reminder timing. Integrate with notification service to offer AI-suggested intervals alongside user-set ones.

Follow TDD → commit.

**Commit message:** `feat: add AI-suggested feeding/diaper interval analysis`

---

### Task 24: Milestone Tracking with Age-Based Reminders

**Files:**
- Create: `uu/lib/repositories/milestone_repository.dart`
- Create: `uu/lib/services/milestone_service.dart` (expected milestones by age)
- Create: `uu/lib/screens/milestones/milestone_screen.dart`
- Create: `uu/lib/providers/milestone_provider.dart`
- Test: `uu/test/repositories/milestone_repository_test.dart`
- Test: `uu/test/services/milestone_service_test.dart`

Implement milestone tracking with a pre-populated list of expected milestones by age (motor, language, social, cognitive). Show achieved vs pending. Generate reminders when a milestone window is approaching. Gentle alerts if significantly delayed.

Follow TDD → commit.

**Commit message:** `feat: add milestone tracking with age-based reminders`

---

## Phase 3: Full Features (Tasks 25-33)

### Task 25: Supabase Auth Integration (Google/Apple Sign-In)

Set up Supabase Auth with Google and Apple sign-in providers. Create auth flow screens (sign-in, profile). Store auth state in Riverpod. Gate cloud features behind authentication.

**Commit message:** `feat: add Supabase auth with Google/Apple sign-in`

### Task 26: Supabase Sync Engine

Implement bidirectional sync between Drift (local) and Supabase (remote). Write queue for offline changes. Realtime subscription for incoming changes from family members. Conflict resolution: last-write-wins. Create all Supabase migrations matching the Drift schema.

**Commit message:** `feat: add offline-first sync engine between Drift and Supabase`

### Task 27: Family Sharing

Implement family management: create family, invite members (by email), accept invitations. RLS policies in Supabase. Family member list screen. Attribution on all records.

**Commit message:** `feat: add family sharing with invitations and RLS`

### Task 28: Food Introduction Tracker

Repository, screen with allergen checklist, 3-day wait rule indicator, reaction logging. Visual grid of tried/untried foods by category.

**Commit message:** `feat: add food introduction tracker with allergen checklist`

### Task 29: Teething Map

Interactive SVG/Canvas diagram of 20 primary teeth. Tap to toggle erupted/pending. Repository, screen, animations.

**Commit message:** `feat: add interactive teething map`

### Task 30: Health Records and Vaccination Schedule

Vaccination repository with standard schedules by country. Health event CRUD. Combined timeline view. Due date reminders.

**Commit message:** `feat: add health records and vaccination schedule`

### Task 31: Media Gallery

Photo/video storage using Supabase Storage. Gallery screen with timeline/grid views. Thumbnail generation. Link media to any record. Image picker integration.

**Commit message:** `feat: add media gallery with Supabase Storage`

### Task 32: Knowledge Base

Bundled pediatric articles in JSON. Searchable list screen. Age-filtered content. Categories: Sleep, Feeding, Development, Health, Safety, Behavior.

**Commit message:** `feat: add searchable pediatric knowledge base`

### Task 33: Doctor Report and Caregiver Handoff

Auto-generate one-page PDF summaries for pediatrician visits. Caregiver handoff notes shareable as link or PDF. Use `pdf` package for generation.

**Commit message:** `feat: add doctor report and caregiver handoff generators`

---

## Phase 4: Polish for Public Release (Tasks 34-38)

### Task 34: "On This Day" Memories

Daily check for media from same date in previous months/years. Memory card on home screen. Push notification at 9 AM.

**Commit message:** `feat: add "On This Day" memories feature`

### Task 35: Home Screen Widget

Android/iOS home screen widget showing: time since last feed, time since last diaper, next nap estimate. Action buttons for quick logging.

**Commit message:** `feat: add home screen widget`

### Task 36: Onboarding Polish

Animated onboarding carousel for first-time users. Feature highlights, permission requests, Supabase account creation.

**Commit message:** `feat: add polished onboarding flow`

### Task 37: Dark Mode Auto-Switch

Time-based auto dark mode (configurable schedule, e.g., 8 PM - 7 AM). Brightness reduction. Minimal animations in night mode.

**Commit message:** `feat: add auto dark mode with time-based schedule`

### Task 38: Multi-Child Support (v2)

Child selector in app bar. Separate data per child. Easy switching. Per-child notification settings.

**Commit message:** `feat: add multi-child support`

---

## Running Tests

**All tests:**
```bash
cd uu && flutter test
```

**Specific test file:**
```bash
cd uu && flutter test test/path/to/test.dart -v
```

**With coverage:**
```bash
cd uu && flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

**Code generation (run after any table/model change):**
```bash
cd uu && dart run build_runner build --delete-conflicting-outputs
```
