/// router.dart
/// Purpose: Defines the entire GoRouter navigation graph — routes, redirects,
///          and the shell (bottom navigation scaffold).
/// Reads from: authProvider (for redirect logic)
/// Writes to: nothing
/// Navigation: ALL screen routes are declared here
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/auth/screens/splash_screen.dart';
import 'package:zamwealth_quest/features/daily_challenge/screens/daily_challenge_screen.dart';
import 'package:zamwealth_quest/features/auth/screens/login_screen.dart';
import 'package:zamwealth_quest/features/auth/screens/register_screen.dart';
import 'package:zamwealth_quest/features/onboarding/screens/onboarding_screen.dart';
import 'package:zamwealth_quest/features/dashboard/screens/dashboard_screen.dart';
import 'package:zamwealth_quest/features/levels/screens/level_map_screen.dart';
import 'package:zamwealth_quest/features/levels/screens/level_screen.dart';
import 'package:zamwealth_quest/features/payments/screens/payment_screen.dart';
import 'package:zamwealth_quest/features/profile/screens/profile_screen.dart';
import 'package:zamwealth_quest/features/profile/screens/dev_screen.dart';
import 'package:zamwealth_quest/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:zamwealth_quest/features/badges/screens/badges_screen.dart';
import 'package:zamwealth_quest/features/stats/screens/stats_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route Paths
// ─────────────────────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';

  // Shell tabs
  static const String home = '/home';
  static const String levels = '/levels';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';

  // Nested under levels
  static const String levelDetail = '/levels/:levelId';
  static const String payment = '/payment/:levelId';

  // Nested under profile
  static const String dev = '/profile/dev';
  static const String badges = '/badges';

  // Daily Challenge (full screen, outside shell)
  static const String dailyChallenge = '/daily-challenge';

  // Stats screen (full screen, outside shell)
  static const String stats = '/stats';
}

// ─────────────────────────────────────────────────────────────────────────────
// Router Notifier — tells GoRouter to re-evaluate redirects on auth changes
// ─────────────────────────────────────────────────────────────────────────────

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}

final _routerNotifierProvider = ChangeNotifierProvider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

// ─────────────────────────────────────────────────────────────────────────────
// Router Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the [GoRouter] instance, wired to [authProvider] for redirects.
/// Uses [refreshListenable] so the router is created once and never recreated —
/// only the redirect is re-evaluated when auth state changes.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(_routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    debugLogDiagnostics: false,

    // ── Global Redirect Logic ──────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState routerState) {
      final location = routerState.matchedLocation;
      final authState = ref.read(authProvider);
      final isAuth = authState.isAuthenticated;
      final doneOnboarding = authState.hasCompletedOnboarding;

      // Allow splash through unconditionally
      if (location == AppRoutes.splash) return null;

      // Allow register screen without auth
      if (location == AppRoutes.register) return null;

      // If not authenticated, only allow login
      if (!isAuth) {
        if (location == AppRoutes.login) return null;
        return AppRoutes.login;
      }

      // Authenticated but onboarding not done → send to onboarding
      if (!doneOnboarding) {
        if (location == AppRoutes.onboarding) return null;
        return AppRoutes.onboarding;
      }

      // Authenticated + onboarding done: redirect login/onboarding → home
      if (location == AppRoutes.login || location == AppRoutes.onboarding) {
        return AppRoutes.home;
      }

      return null; // allow navigation
    },

    routes: [
      // ── Splash ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),

      // ── Login ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),

      // ── Register ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Onboarding ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ── Level Detail (outside shell — full screen) ─────────────────────
      GoRoute(
        path: '/levels/:levelId',
        builder: (context, state) {
          final levelId =
              int.tryParse(state.pathParameters['levelId'] ?? '1') ?? 1;
          return LevelScreen(levelId: levelId);
        },
      ),

      // ── Payment (outside shell — full screen) ─────────────────────────
      GoRoute(
        path: '/payment/:levelId',
        builder: (context, state) {
          final levelId =
              int.tryParse(state.pathParameters['levelId'] ?? '2') ?? 2;
          return PaymentScreen(levelId: levelId);
        },
      ),

      // ── Dev Screen (outside shell — full screen) ───────────────────────
      GoRoute(
        path: AppRoutes.dev,
        builder: (_, __) => const DevScreen(),
      ),

      // ── Badges Screen (outside shell — full screen) ────────────────────
      GoRoute(
        path: AppRoutes.badges,
        builder: (_, __) => const BadgesScreen(),
      ),

      // ── Daily Challenge (outside shell — full screen) ──────────────────
      GoRoute(
        path: AppRoutes.dailyChallenge,
        builder: (_, __) => const DailyChallengeScreen(),
      ),

      // ── Stats (outside shell — full screen) ────────────────────────────
      GoRoute(
        path: AppRoutes.stats,
        builder: (_, __) => const StatsScreen(),
      ),

      // ── Shell — Bottom Navigation Scaffold ─────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          return _MainScaffold(location: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.levels,
            builder: (_, __) => const LevelMapScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.leaderboard,
            builder: (_, __) => const LeaderboardScreen(),
          ),
        ],
      ),
    ],
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Main Scaffold (Shell)
// ─────────────────────────────────────────────────────────────────────────────

/// The persistent shell widget that wraps all bottom-nav tabs.
/// Manages which tab is selected based on the current route location.
class _MainScaffold extends StatelessWidget {
  const _MainScaffold({required this.child, required this.location});

  final Widget child;
  final String location;

  /// Returns the index of the currently active bottom-nav tab.
  int get _currentIndex {
    if (location.startsWith('/levels')) return 1;
    if (location.startsWith('/profile')) return 2;
    if (location.startsWith('/leaderboard')) return 3;
    return 0; // home
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.levels);
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
      case 3:
        context.go(AppRoutes.leaderboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Levels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: 'Ranks',
          ),
        ],
      ),
    );
  }
}
