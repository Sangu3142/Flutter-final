/// onboarding_screen.dart
/// Purpose: Three-step onboarding flow that collects the player's income
///          category, financial goals (multi-select), and risk appetite.
///          Saves preferences via AuthNotifier and routes to the dashboard.
/// Reads from: authProvider (current user)
/// Writes to: authProvider → Hive box 'users', 'settings'
/// Navigation: → /home (on completion)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Data
// ─────────────────────────────────────────────────────────────────────────────

const List<Map<String, String>> kIncomeCategories = [
  {'id': 'student',         'label': 'Student 🎓',          'desc': 'Currently studying'},
  {'id': 'informal_trader', 'label': 'Informal Trader 🛒',  'desc': 'Market / street business'},
  {'id': 'civil_servant',   'label': 'Civil Servant 🏛️',    'desc': 'Government employee'},
  {'id': 'entrepreneur',    'label': 'Entrepreneur 💼',      'desc': 'Business owner'},
];

const List<Map<String, String>> kFinancialGoals = [
  {'id': 'buy_land',       'label': 'Buy Land 🌍',          'desc': 'Invest in property'},
  {'id': 'start_business', 'label': 'Start a Business 🏪',  'desc': 'Launch my enterprise'},
  {'id': 'invest',         'label': 'Invest 📈',            'desc': 'Grow my money'},
  {'id': 'emergency_fund', 'label': 'Emergency Fund 🛡️',    'desc': 'Build a safety net'},
  {'id': 'education',      'label': 'Fund Education 📚',    'desc': 'Study costs'},
  {'id': 'retirement',     'label': 'Plan Retirement 🏖️',   'desc': 'Long-term security'},
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? _selectedIncomeCategory;
  final Set<String> _selectedGoals = {};
  double _riskSlider = 1.0;

  String get _riskLabel {
    if (_riskSlider < 0.5) return 'low';
    if (_riskSlider < 1.5) return 'medium';
    return 'high';
  }

  String get _riskDescription {
    switch (_riskLabel) {
      case 'low':
        return 'Safety first — I prefer savings accounts and bonds.';
      case 'high':
        return 'I am comfortable with stock market volatility for higher returns.';
      default:
        return 'Balanced — mix of safe and growth investments.';
    }
  }

  void _nextPage() {
    if (_currentPage == 2 && _selectedIncomeCategory == null) {
      _showError('Please select your income category.');
      return;
    }
    if (_currentPage == 3 && _selectedGoals.isEmpty) {
      _showError('Please select at least one financial goal.');
      return;
    }

    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    await ref.read(authProvider.notifier).completeOnboarding(
          incomeCategory: _selectedIncomeCategory!,
          financialGoals: _selectedGoals.toList(),
          riskAppetite: _riskLabel,
        );
    if (mounted) context.go(AppRoutes.home);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: kWarning),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Header + Progress ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? 'Player'}!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: kCharcoal,
                                letterSpacing: 0.3,
                              ),
                        ),
                        if (_currentPage < 2)
                          TextButton(
                            onPressed: () {
                              _pageController.animateToPage(
                                2,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: kNeonMint,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Skip →'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentPage < 2
                          ? 'Swipe or tap Next to continue'
                          : 'Step ${_currentPage - 1} of 3 — Tell us about yourself',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: kCharcoalLight,
                          ),
                    ),
                    const SizedBox(height: 14),
                    // Page dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final isActive = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? kNeonMint
                                : kCharcoalLight.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── PageView ──────────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: _currentPage < 2
                      ? const PageScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildSlide0(),
                    _buildSlide1(),
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),

              // ── Navigation Buttons ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _prevPage,
                          child: const Text('BACK'),
                        ),
                      ),
                    if (_currentPage > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage >= 2 ? kNeonMint : kGold,
                          foregroundColor: kCoreNavy,
                        ),
                        child: Text(
                          _currentPage < 4 ? 'NEXT →' : 'START PLAYING 🚀',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Slide 0: Welcome ──────────────────────────────────────────────────────

  Widget _buildSlide0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('🌍', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(
            'Welcome to ZamWealth Quest',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: kCharcoal,
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'The fun way to learn real financial skills — designed for Zambia.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kCharcoalLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _bulletRow('🪙', 'Earn ZamCoins as you learn'),
                const SizedBox(height: 12),
                _bulletRow('📅', 'Daily challenges keep your streak alive'),
                const SizedBox(height: 12),
                _bulletRow('🗺️', 'Unlock new levels as you grow'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Slide 1: How It Works ─────────────────────────────────────────────────

  Widget _buildSlide1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('🎮', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          Text(
            'How ZamWealth Quest Works',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: kCharcoal,
                  letterSpacing: 0.3,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Complete simulations, earn XP, and climb the ranks.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kCharcoalLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _featureRow(kNeonMint, '⚔️', 'Rank Up', 'Earn XP to rise from Novice to Legend'),
                const SizedBox(height: 14),
                _featureRow(kGold, '🪙', 'ZamCoins', 'Spend coins to unlock premium levels'),
                const SizedBox(height: 14),
                _featureRow(kGreen, '📊', 'Simulations', 'Practice budgeting, saving, investing & more'),
                const SizedBox(height: 14),
                _featureRow(kPrimaryBlue, '🏅', 'Badges', 'Collect achievements as you master each topic'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kCharcoal),
          ),
        ),
      ],
    );
  }

  Widget _featureRow(Color accent, String emoji, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.40)),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kCharcoalLight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 1: Income Category ───────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What best describes you?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: kCharcoal),
          ),
          const SizedBox(height: 4),
          Text(
            "We'll personalise your experience based on your income type.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kCharcoalLight),
          ),
          const SizedBox(height: 16),
          ...kIncomeCategories.map((cat) {
            final isSelected = _selectedIncomeCategory == cat['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedIncomeCategory = cat['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? kNeonMint.withValues(alpha: 0.10)
                      : kDeepNavy.withValues(alpha: 0.60),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? kNeonMint : Colors.white.withValues(alpha: 0.12),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? kNeonMint : kCharcoalLight,
                          width: 2,
                        ),
                        color: isSelected ? kNeonMint : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: kCoreNavy)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat['label']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isSelected ? kNeonMint : kCharcoal,
                              ),
                        ),
                        Text(
                          cat['desc']!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: kCharcoalLight,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Step 2: Financial Goals ───────────────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are your financial goals?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: kCharcoal),
          ),
          const SizedBox(height: 4),
          Text(
            "Select all that apply — we'll tailor your simulations.",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kCharcoalLight),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: kFinancialGoals.map((goal) {
              final isSelected = _selectedGoals.contains(goal['id']);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedGoals.remove(goal['id']);
                    } else {
                      _selectedGoals.add(goal['id']!);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? kNeonMint.withValues(alpha: 0.10)
                        : kDeepNavy.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? kNeonMint : Colors.white.withValues(alpha: 0.12),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              goal['label']!,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: isSelected ? kNeonMint : kCharcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, size: 16, color: kNeonMint),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal['desc']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: kCharcoalLight,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Risk Appetite ─────────────────────────────────────────────────

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your risk appetite?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: kCharcoal),
          ),
          const SizedBox(height: 4),
          Text(
            'How comfortable are you with investment risk?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kCharcoalLight),
          ),
          const SizedBox(height: 28),

          GlassCard(
            highlighted: true,
            child: Column(
              children: [
                Text(
                  _riskLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: kGold,
                        letterSpacing: 4,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _riskDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kCharcoalLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: kGold,
              inactiveTrackColor: kCharcoalLight.withValues(alpha: 0.30),
              thumbColor: kGold,
              overlayColor: kGold.withValues(alpha: 0.20),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _riskSlider,
              min: 0,
              max: 2,
              divisions: 2,
              onChanged: (v) => setState(() => _riskSlider = v),
            ),
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _riskLabelWidget('🛡️ Low', 0),
              _riskLabelWidget('⚖️ Medium', 1),
              _riskLabelWidget('🚀 High', 2),
            ],
          ),

          const SizedBox(height: 28),

          // Summary card
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Profile Summary',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: kNeonMint,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                _summaryRow(
                  'Income Type',
                  kIncomeCategories.firstWhere(
                    (c) => c['id'] == _selectedIncomeCategory,
                    orElse: () => {'label': '—'},
                  )['label']!,
                ),
                _summaryRow('Goals', '${_selectedGoals.length} selected'),
                _summaryRow('Risk', _riskLabel.toUpperCase()),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _riskLabelWidget(String label, double value) {
    final isActive = (_riskSlider - value).abs() < 0.1;
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isActive ? kGold : kCharcoalLight,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
    );
  }

  Widget _summaryRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$key: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kCharcoalLight),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kCharcoal,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
