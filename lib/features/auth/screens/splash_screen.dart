/// splash_screen.dart
/// Purpose: Branded splash screen shown for ~2 seconds on app launch.
///          Redirects to Login (no session) or Dashboard (active session)
///          via GoRouter redirect — no manual navigation needed here.
/// Reads from: authProvider (via GoRouter redirect in router.dart)
/// Writes to: nothing
/// Navigation: GoRouter auto-redirects after ProviderScope initialises
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';

/// [SplashScreen] shows the ZamWealth Quest brand for 2 seconds,
/// then navigates to Login or Dashboard based on session state.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // Fade-in + scale-up animation for the logo
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // After 2 seconds, let GoRouter redirect logic handle navigation.
    Timer(const Duration(milliseconds: 2200), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final auth = ref.read(authProvider);

    if (!auth.isAuthenticated) {
      context.go(AppRoutes.login);
    } else if (!auth.hasCompletedOnboarding) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kZamGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Logo / Icon ──────────────────────────────────
                        Builder(builder: (ctx) {
                          final s = MediaQuery.of(ctx).size;
                          final logoSize = s.shortestSide * 0.28;
                          return Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '🇿🇲',
                                style: TextStyle(fontSize: logoSize * 0.5),
                              ),
                            ),
                          );
                        }),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),

                        // ── App Name ──────────────────────────────────────
                        Text(
                          'ZamWealth',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                        ),
                        Text(
                          'QUEST',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: kGold,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 6,
                              ),
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),

                        // ── Tagline ────────────────────────────────────────
                        Text(
                          'Level up your financial future',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color:
                                        Colors.white.withValues(alpha: 0.85),
                                    letterSpacing: 0.5,
                                  ),
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07),

                        // ── Loading Indicator ──────────────────────────────
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            color: Colors.white.withValues(alpha: 0.7),
                            strokeWidth: 2.5,
                          ),
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),

                        // ── Powered By ─────────────────────────────────────
                        Text(
                          'Powered by Zambian financial data 🏦',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color:
                                        Colors.white.withValues(alpha: 0.6),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
