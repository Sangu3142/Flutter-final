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
import 'package:zamwealth_quest/core/app_flags.dart';
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
import 'package:zamwealth_quest/features/hearts/screens/hearts_depleted_screen.dart';
import 'package:zamwealth_quest/features/daily_bonus/screens/daily_bonus_screen.dart';
import 'package:zamwealth_quest/features/daily_bonus/providers/daily_bonus_provider.dart';
import 'package:zamwealth_quest/features/shop/screens/shop_screen.dart';
import 'package:zamwealth_quest/features/spin/screens/spin_screen.dart';
import 'package:zamwealth_quest/features/flash_challenge/screens/flash_challenge_screen.dart';
import 'package:zamwealth_quest/features/flash_challenge/screens/challenge_expired_screen.dart';
import 'package:zamwealth_quest/features/mini_games/screens/mini_games_screen.dart';
import 'package:zamwealth_quest/features/mini_games/screens/budget_blitz_screen.dart';
import 'package:zamwealth_quest/features/mini_games/screens/investment_flip_screen.dart';
import 'package:zamwealth_quest/features/mystery_box/screens/mystery_box_screen.dart';
import '../features/boss/screens/boss_screen.dart';
import '../features/boss/screens/boss_defeated_screen.dart';
import '../features/coop/screens/coop_screen.dart';
import '../features/seasons/screens/season_screen.dart';
import '../features/family/screens/family_screen.dart';
import '../features/business/screens/business_screen.dart';
import '../features/life_events/screens/life_event_screen.dart';
import '../features/property/screens/property_screen.dart';
import '../features/portfolio/screens/portfolio_screen.dart';
import '../features/loans/screens/loans_screen.dart';
import '../features/savings/screens/savings_screen.dart';
import '../features/networth/screens/networth_screen.dart';
import '../features/news/screens/news_screen.dart';
import '../features/health/screens/health_screen.dart';
import 'package:zamwealth_quest/features/myths/screens/myth_screen.dart';
import 'package:zamwealth_quest/features/spotlights/screens/spotlights_screen.dart';
import 'package:zamwealth_quest/features/spotlights/screens/spotlight_story_screen.dart';
import 'package:zamwealth_quest/features/mentors/screens/mentors_screen.dart';
import 'package:zamwealth_quest/features/proverbs/screens/proverbs_screen.dart';
import 'package:zamwealth_quest/features/daily_routine/screens/daily_routine_screen.dart';
import '../features/recovery/screens/recovery_plan_screen.dart';
import '../features/avatar/screens/change_avatar_screen.dart';
import '../features/tutorial/tutorial_screen.dart';
import 'package:zamwealth_quest/core/theme.dart';

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

  // Hearts (full screen, outside shell)
  static const String heartsDepleted = '/hearts-depleted';

  // Daily Bonus (full screen, outside shell)
  static const String dailyBonus = '/daily-bonus';

  // Shop (full screen, outside shell)
  static const String shop = '/shop';

  // Spin the Wheel (full screen, outside shell)
  static const String spin = '/spin';

  // Flash Challenge (full screen, outside shell)
  static const String flashChallenge = '/flash-challenge';
  static const String challengeExpired = '/challenge-expired';

  // Mini-Games hub + individual games (full screen, outside shell)
  static const String miniGames  = '/mini-games';
  static const String budgetBlitz = '/mini-games/budget-blitz';
  static const String investFlip  = '/mini-games/invest-flip';

  // Mystery Box (full screen, outside shell)
  static const String mysteryBox = '/mystery-box';

  // Boss Battles (full screen, outside shell) — Wave 5
  static const String boss       = '/levels/:levelId/boss';
  static const String bossDefeat = '/levels/:levelId/boss/defeat';

  // Co-op Mode (full screen, outside shell) — Wave 5
  static const String coop = '/coop';

  // Seasons (full screen, outside shell) — Wave 5
  static const String seasons = '/seasons';

  // My Life features (full screen, outside shell)
  static const String family     = '/family';
  static const String business   = '/business';
  static const String lifeEvent  = '/life-event';

  // My Finances features (full screen, outside shell)
  static const String property  = '/property';
  static const String portfolio = '/portfolio';
  static const String loans     = '/loans';
  static const String savings   = '/savings';

  // Analytics & Visualization features (full screen, outside shell)
  static const String netWorth = '/networth';
  static const String news     = '/news';
  static const String health   = '/health';

  // Educational Content features (full screen, outside shell)
  static const String myths          = '/myths';
  static const String spotlights     = '/spotlights';
  static const String spotlightStory = '/spotlights/story';
  static const String mentors        = '/mentors';
  static const String proverbs       = '/proverbs';
  static const String dailyRoutine   = '/daily';

  // Change Avatar (full screen, outside shell)
  static const String changeAvatar = '/change-avatar';

  // Recovery Plan (full screen, outside shell)
  static const String recoveryPlan = '/recovery-plan';

  // Tutorial (full screen, outside shell)
  static const String tutorial = '/tutorial';
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

// TODO(wave5): uncomment when BossScreen, BossDefeatedScreen, CoopScreen, SeasonScreen are created
// Widget _slideFromRight(BuildContext context, Animation<double> animation, Animation<double> _, Widget child) =>
//     SlideTransition(
//       position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
//           .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
//       child: child,
//     );

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

      // Check if daily bonus should be shown
      if (isAuth && doneOnboarding) {
        final bonusState = ref.read(dailyBonusProvider);
        if (bonusState.shouldShow &&
            routerState.matchedLocation != AppRoutes.dailyBonus) {
          return AppRoutes.dailyBonus;
        }
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
      // SECURITY: registered only in debug/profile builds. The dev console can
      // force-unlock paid levels, dump every Hive box, and wipe all data, so a
      // release build must not contain a route to it at all — not even one
      // hidden behind the 7-tap easter egg, which any user can find.
      if (isDevSurfaceEnabled)
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

      // ── Hearts Depleted (outside shell) ────────────────────────────────────
      GoRoute(
        path: AppRoutes.heartsDepleted,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const HeartsDepletedScreen(),
        ),
      ),

      // ── Daily Bonus (outside shell) ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.dailyBonus,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const DailyBonusScreen(),
        ),
      ),

      // ── Shop (outside shell) ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.shop,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const ShopScreen(),
        ),
      ),

      // ── Spin the Wheel (outside shell) ──────────────────────────────────────
      GoRoute(
        path: AppRoutes.spin,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const SpinScreen(),
        ),
      ),

      // ── Flash Challenge (outside shell) ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.flashChallenge,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const FlashChallengeScreen(),
        ),
      ),

      // ── Challenge Expired (outside shell) ───────────────────────────────────
      GoRoute(
        path: AppRoutes.challengeExpired,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const ChallengeExpiredScreen(),
        ),
      ),

      // ── Mini-Games Hub (outside shell) ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.miniGames,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const MiniGamesScreen(),
        ),
      ),

      // ── Budget Blitz (outside shell) ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.budgetBlitz,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const BudgetBlitzScreen(),
        ),
      ),

      // ── Investment Flip (outside shell) ──────────────────────────────────────
      GoRoute(
        path: AppRoutes.investFlip,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const InvestmentFlipScreen(),
        ),
      ),

      // ── Mystery Box (outside shell) ───────────────────────────────────────────
      GoRoute(
        path: AppRoutes.mysteryBox,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MysteryBoxScreen(),
          transitionsBuilder: (context, animation, _, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                child: child,
              ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),

      // ── Boss Battle (outside shell) ────────────────────────────────────────────
      GoRoute(
        path: '/levels/:levelId/boss',
        pageBuilder: (context, state) {
          final levelId = int.parse(state.pathParameters['levelId']!);
          return CustomTransitionPage(
            key: state.pageKey,
            child: BossScreen(levelId: levelId),
            transitionsBuilder: (context, animation, _, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),

      // ── Boss Defeated (outside shell) ──────────────────────────────────────────
      GoRoute(
        path: '/levels/:levelId/boss/defeat',
        pageBuilder: (context, state) {
          final levelId = int.parse(state.pathParameters['levelId']!);
          final extra   = state.extra as Map<String, dynamic>?;
          final isReplay = extra?['isReplay'] as bool? ?? false;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BossDefeatedScreen(levelId: levelId, isReplay: isReplay),
            transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          );
        },
      ),

      // ── Co-op Mode (outside shell) ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.coop,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CoopScreen(),
          transitionsBuilder: (context, animation, _, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),

      // ── Seasons (outside shell) ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.seasons,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SeasonScreen(),
          transitionsBuilder: (context, animation, _, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),

      // ── Family (outside shell) ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.family,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const FamilyScreen(),
        ),
      ),

      // ── Business (outside shell) ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.business,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const BusinessScreen(),
        ),
      ),

      // ── Life Event (full-screen overlay, outside shell) ────────────────────────
      GoRoute(
        path: AppRoutes.lifeEvent,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LifeEventScreen(),
          transitionsBuilder: (context, animation, _, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),

      // ── Property Ladder (outside shell) ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.property,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const PropertyScreen(),
        ),
      ),

      // ── Investment Portfolio (outside shell) ────────────────────────────────────
      GoRoute(
        path: AppRoutes.portfolio,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const PortfolioScreen(),
        ),
      ),

      // ── Loans & Debt (outside shell) ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.loans,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const LoansScreen(),
        ),
      ),

      // ── Savings Goals (outside shell) ───────────────────────────────────────────
      GoRoute(
        path: AppRoutes.savings,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const SavingsScreen(),
        ),
      ),

      // ── Net Worth Dashboard (outside shell) ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.netWorth,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const NetWorthScreen(),
        ),
      ),

      // ── Financial News Feed (outside shell) ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.news,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const NewsScreen(),
        ),
      ),

      // ── Financial Health Score (outside shell) ───────────────────────────────────
      GoRoute(
        path: AppRoutes.health,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const HealthScreen(),
        ),
      ),

      // ── Myth Busting (outside shell) ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.myths,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const MythScreen(),
        ),
      ),

      // ── Entrepreneur Spotlights (outside shell) ───────────────────────────────
      GoRoute(
        path: AppRoutes.spotlights,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const SpotlightsScreen(),
        ),
      ),

      // ── Spotlight Story (outside shell) ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.spotlightStory,
        pageBuilder: (context, state) {
          final extra    = state.extra as Map<String, dynamic>;
          final storyId  = extra['storyId'] as int;
          final storyIdx = extra['storyIdx'] as int;
          return _fadeSlidePage(
            pageKey: state.pageKey,
            child: SpotlightStoryScreen(storyId: storyId, storyIdx: storyIdx),
          );
        },
      ),

      // ── Mentors (outside shell) ────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.mentors,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const MentorsScreen(),
        ),
      ),

      // ── Proverbs / Wisdom Book (outside shell) ─────────────────────────────────
      GoRoute(
        path: AppRoutes.proverbs,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const ProverbsScreen(),
        ),
      ),

      // ── Daily Routine (outside shell) ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.dailyRoutine,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const DailyRoutineScreen(),
        ),
      ),

      // ── Change Avatar (outside shell) ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.changeAvatar,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const ChangeAvatarScreen(),
        ),
      ),

      // ── Recovery Plan (outside shell) ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.recoveryPlan,
        pageBuilder: (context, state) => _fadeSlidePage(
          pageKey: state.pageKey,
          child: const RecoveryPlanScreen(),
        ),
      ),

      // ── Tutorial (full screen, outside shell) ────────────────────────────────
      GoRoute(
        path: AppRoutes.tutorial,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: TutorialScreen(),
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
      // No AnimatedSwitcher here — each tab route already supplies its own
      // CustomTransitionPage fade/slide via _fadeSlidePage. Stacking
      // AnimatedSwitcher on top caused a noticeable 200ms double-animate.
      body: child,
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        border: Border(
          top: BorderSide(color: kNeonMint.withValues(alpha: 0.25), width: 1),
        ),
      ),
      // Explicitly pad for the system gesture area so the BottomNavigationBar
      // doesn't independently add it and cause a double-inset overflow.
      padding: EdgeInsets.only(bottom: bottomInset),
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
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
      ),
    );
  }
}
