/// router.dart
/// Purpose: Defines the entire GoRouter navigation graph — routes, redirects,
///          transitions, and the shell (bottom navigation scaffold).
/// Reads from: authProvider (for redirect logic)
/// Writes to: nothing
/// Navigation: ALL screen routes are declared here
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/theme.dart';
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
import 'package:zamwealth_quest/features/quiz/screens/quiz_screen.dart';
import 'package:zamwealth_quest/features/seasonal/screens/seasonal_event_screen.dart';
import 'package:zamwealth_quest/features/stats/screens/stats_screen.dart';
import 'package:zamwealth_quest/features/story/screens/story_chapter_screen.dart';
import 'package:zamwealth_quest/features/story/screens/story_map_screen.dart';

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

  // Engagement layer (full screen, outside shell)
  static const String quiz           = '/quiz';
  static const String story          = '/story';
  static const String storyChapter   = '/story/chapter/:chapterId';
  static const String seasonalEvent  = '/seasonal-event';
}

// ─────────────────────────────────────────────────────────────────────────────
// Transition Helper
// ─────────────────────────────────────────────────────────────────────────────

/// Builds a [CustomTransitionPage] that fades and slides the new screen up
/// from a 5 % offset over 350 ms with an ease-out curve.
CustomTransitionPage<void> _fadeSlidePage({
  required LocalKey pageKey,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0.0, 0.05),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Router Notifier
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

      if (location == AppRoutes.splash) return null;
      if (location == AppRoutes.register) return null;

      if (!isAuth) {
        if (location == AppRoutes.login) return null;
        return AppRoutes.login;
      }

      if (!doneOnboarding) {
        if (location == AppRoutes.onboarding) return null;
        return AppRoutes.onboarding;
      }

      if (location == AppRoutes.login || location == AppRoutes.onboarding) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // ── Splash ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const SplashScreen(),
        ),
      ),

      // ── Login ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const LoginScreen(),
        ),
      ),

      // ── Register ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),

      // ── Onboarding ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),

      // ── Level Detail (outside shell) ───────────────────────────────────────
      GoRoute(
        path: '/levels/:levelId',
        pageBuilder: (context, state) {
          final levelId =
              int.tryParse(state.pathParameters['levelId'] ?? '1') ?? 1;
          return _fadeSlidePage(
            pageKey: state.pageKey,
            child: LevelScreen(levelId: levelId),
          );
        },
      ),

      // ── Payment (outside shell) ────────────────────────────────────────────
      GoRoute(
        path: '/payment/:levelId',
        pageBuilder: (context, state) {
          final levelId =
              int.tryParse(state.pathParameters['levelId'] ?? '2') ?? 2;
          return _fadeSlidePage(
            pageKey: state.pageKey,
            child: PaymentScreen(levelId: levelId),
          );
        },
      ),

      // ── Dev Screen (outside shell) ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.dev,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const DevScreen(),
        ),
      ),

      // ── Badges Screen (outside shell) ──────────────────────────────────────
      GoRoute(
        path: AppRoutes.badges,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const BadgesScreen(),
        ),
      ),

      // ── Daily Challenge (outside shell) ────────────────────────────────────
      GoRoute(
        path: AppRoutes.dailyChallenge,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const DailyChallengeScreen(),
        ),
      ),

      // ── Stats (outside shell) ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.stats,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const StatsScreen(),
        ),
      ),

      // ── Quiz (outside shell) ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.quiz,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const QuizScreen(),
        ),
      ),

      // ── Story Map (outside shell) ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.story,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const StoryMapScreen(),
        ),
      ),

      // ── Story Chapter (outside shell) ──────────────────────────────────────
      GoRoute(
        path: '/story/chapter/:chapterId',
        pageBuilder: (context, state) {
          final chapterId =
              int.tryParse(state.pathParameters['chapterId'] ?? '1') ?? 1;
          return _fadeSlidePage(
            pageKey: state.pageKey,
            child: StoryChapterScreen(chapterId: chapterId),
          );
        },
      ),

      // ── Seasonal Event (outside shell) ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.seasonalEvent,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const SeasonalEventScreen(),
        ),
      ),

      // ── Shell — Bottom Navigation Scaffold ─────────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          return _MainScaffold(location: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => _fadeSlidePage(
              pageKey: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.levels,
            pageBuilder: (context, state) => _fadeSlidePage(
              pageKey: state.pageKey,
              child: const LevelMapScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => _fadeSlidePage(
              pageKey: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.leaderboard,
            pageBuilder: (context, state) => _fadeSlidePage(
              pageKey: state.pageKey,
              child: const LeaderboardScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Main Scaffold (Shell)
// ─────────────────────────────────────────────────────────────────────────────

class _MainScaffold extends StatelessWidget {
  const _MainScaffold({required this.child, required this.location});

  final Widget child;
  final String location;

  int get _currentIndex {
    if (location.startsWith('/levels')) return 1;
    if (location.startsWith('/profile')) return 2;
    if (location.startsWith('/leaderboard')) return 3;
    return 0;
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
      backgroundColor: Colors.transparent,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(key: ValueKey(location), child: child),
      ),
      bottomNavigationBar: _NavBar(
        currentIndex: _currentIndex,
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav Bar
// ─────────────────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        border: Border(
          top: BorderSide(color: kNeonMint.withValues(alpha: 0.25), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
