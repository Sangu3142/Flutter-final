import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/widgets/tutorial_overlay.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;

  static const _steps = [
    (
      emoji: '🤖',
      title: 'Mwaiseni, champion!',
      body: "I'm Zamu, your money mentor. I'll show you around "
          "ZamWealth Quest — Lusaka style. Swipe or tap Next!",
    ),
    (
      emoji: '💰',
      title: 'Your Stats HUD',
      body: 'At the top of Home you see ZamCoins, Net Worth and '
          'Badges. These are your core stats — keep them growing!',
    ),
    (
      emoji: '⭐',
      title: 'XP & Ranks',
      body: 'Every quiz and simulation earns XP. Climb from '
          'Kwacha Starter to Lusaka Legend. Bambo, the journey '
          'is long but sweet!',
    ),
    (
      emoji: '📅',
      title: 'Daily Challenge',
      body: 'One money question every day. Answer right, build '
          'your streak, and stack the Kwacha. Miss a day and '
          'the streak resets — yebo!',
    ),
    (
      emoji: '🌟',
      title: 'Season Progress',
      body: 'Each season is a new chapter. Earn season XP, '
          'claim rewards, and see how far you have travelled. '
          'Twende!',
    ),
    (
      emoji: '🗺️',
      title: 'The Adventure Map',
      body: 'Tap the Levels tab to explore Lusaka! Each zone — '
          'Kabulonga, Woodlands, Ibex Hill — has simulations '
          'to build your money skills. Complete a zone to '
          'unlock the next!',
    ),
    (
      emoji: '📖',
      title: 'Kwacha Chronicles',
      body: "Follow Mwansa's Journey — a 20-chapter story where "
          "YOUR choices shape the outcome. Read it in the "
          "Chronicles section and learn real money lessons "
          "through Zambian life. Earn ZamCoins as you go!",
    ),
    (
      emoji: '👨‍👩‍👧',
      title: 'My Life — Family',
      body: 'Build your virtual Zambian family! Get married, '
          'have children, manage housing and keep your family '
          'happiness high. Your family affects your monthly '
          'expenses — plan wisely, bambo!',
    ),
    (
      emoji: '🏢',
      title: 'My Life — Business',
      body: 'Launch and grow your own virtual business — from '
          'a roadside stall in Kalingalinga to a Lusaka CBD '
          'enterprise. Each stage earns weekly profit and '
          'builds your Net Worth!',
    ),
    (
      emoji: '🏠',
      title: 'My Finances — Property',
      body: 'Climb the property ladder from a single room in '
          'Mandevu to a house in Kabulonga! Buy property with '
          'ZamCoins, build equity, and watch your Net Worth '
          'grow with every upgrade.',
    ),
    (
      emoji: '📊',
      title: 'My Finances — Investments',
      body: 'Invest in LUSE shares, Government Bonds and Money '
          'Market funds right inside the app. Watch your '
          'portfolio grow and learn how real Zambian '
          'investments work — without risking real Kwacha!',
    ),
    (
      emoji: '🏦',
      title: 'My Finances — Credit Score',
      body: 'Your credit score tracks how well you manage '
          'loans and debt. Pay loans on time to build it up. '
          'A high score unlocks better loan terms — just like '
          'in real Zambian banking!',
    ),
    (
      emoji: '🎯',
      title: 'My Finances — Savings Goals',
      body: 'Set savings goals — school fees, a new phone, '
          'starting a business. Contribute ZamCoins regularly '
          'and watch the progress bar fill up. Small amounts '
          'every day build big wealth, yebo!',
    ),
    (
      emoji: '👤',
      title: 'Your Profile',
      body: 'Find your avatar, streak, XP and earned badges in '
          'the Profile tab. Every quiz and simulation adds to '
          'your story — written in Kwacha!',
    ),
    (
      emoji: '🏆',
      title: 'The Global Ranks',
      body: 'Check the Ranks tab to see where you stand among '
          'Zambian players. Climb from Bronze to Gold League — '
          'can you reach the top, bambo?',
    ),
    (
      emoji: '🚀',
      title: "You're Ready!",
      body: 'Let the quest begin! Every Kwacha saved today is '
          'wealth built for tomorrow. Twende! 💪',
    ),
  ];

  Future<void> _finish() async {
    await markTutorialComplete();
    if (mounted) context.go(AppRoutes.home);
  }

  void _next() {
    if (_page < _steps.length - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isLandscape = mq.size.width > mq.size.height;
    final isLast = _page == _steps.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button top right
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),

            // Page content — LayoutBuilder + scroll allows landscape to work
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _steps.length,
                itemBuilder: (_, i) {
                  final s = _steps[i];
                  return LayoutBuilder(
                    builder: (_, constraints) => SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.emoji,
                              style: TextStyle(
                                fontSize: isLandscape ? 48 : 72,
                              ),
                            ),
                            SizedBox(height: isLandscape ? 12 : 32),
                            Text(
                              s.title,
                              style: TextStyle(
                                fontSize: isLandscape ? 20 : 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.teal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isLandscape ? 8 : 16),
                            Text(
                              s.body,
                              style: TextStyle(
                                fontSize: isLandscape ? 13 : 16,
                                color: Colors.white,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Step dots — smaller in landscape
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _page
                      ? (isLandscape ? 14 : 20)
                      : (isLandscape ? 6 : 8),
                  height: isLandscape ? 6 : 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _page
                        ? Colors.teal
                        : Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            SizedBox(height: isLandscape ? 10 : 24),

            // Back / Next / Begin Quest buttons
            Padding(
              padding: EdgeInsets.fromLTRB(
                32,
                0,
                32,
                isLandscape ? mq.padding.bottom + 8 : 32,
              ),
              child: Row(
                children: [
                  // Back button — hidden on first page
                  if (_page > 0)
                    SizedBox(
                      height: isLandscape ? 42 : 54,
                      child: OutlinedButton(
                        onPressed: () {
                          _ctrl.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.teal, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLandscape ? 14 : 20,
                          ),
                        ),
                        child: Text(
                          '← Back',
                          style: TextStyle(
                            fontSize: isLandscape ? 13 : 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ),
                  if (_page > 0) const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: isLandscape ? 42 : 54,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isLast ? 'Begin Quest! 🚀' : 'Next →',
                          style: TextStyle(
                            fontSize: isLandscape ? 14 : 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFFB703),
                          ),
                        ),
                      ),
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
}
