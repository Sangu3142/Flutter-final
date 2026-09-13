import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../services/streak_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../streak/providers/streak_provider.dart';
import '../../hearts/providers/hearts_provider.dart';
import '../../hearts/widgets/hearts_hud.dart';
import '../../shop/providers/inventory_provider.dart';
import '../providers/boss_provider.dart';
import '../widgets/boss_character_painter.dart';
import '../widgets/boss_health_bar.dart';

class BossScreen extends ConsumerStatefulWidget {
  final int levelId;
  const BossScreen({super.key, required this.levelId});

  @override
  ConsumerState<BossScreen> createState() => _BossScreenState();
}

class _BossScreenState extends ConsumerState<BossScreen>
    with TickerProviderStateMixin {
  late final AnimationController _flinchCtrl;
  late final Animation<double> _flinchAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _correctFlashCtrl;
  late final Animation<double> _correctFlashAnim;
  late final Animation<double> _checkmarkAnim;
  late final AnimationController _wrongShakeCtrl;
  late final Animation<double> _wrongShakeAnim;
  late final Animation<double> _wrongFlashAnim;

  late final List<_BossQuestion> _questions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _bossHp = kBossMaxHp;
  bool _answered  = false;
  int? _chosenIdx;
  bool _isReplay  = false;
  bool _showCheckmark = false;

  @override
  void initState() {
    super.initState();
    _flinchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flinchAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _flinchCtrl, curve: Curves.elasticIn),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Correct-answer green flash + checkmark bounce
    _correctFlashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _correctFlashAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.30), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.30, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _correctFlashCtrl, curve: Curves.easeOut),
    );
    _checkmarkAnim = CurvedAnimation(
      parent: _correctFlashCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
    );

    // Wrong-answer screen shake + red flash
    _wrongShakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _wrongShakeAnim = Tween<double>(begin: 0, end: 1).animate(_wrongShakeCtrl);
    _wrongFlashAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.25), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.0), weight: 3),
    ]).animate(_wrongShakeCtrl);

    _questions = _buildQuestions(widget.levelId);
    _isReplay = ref.read(bossProvider(widget.levelId)).defeated;
  }

  @override
  void dispose() {
    _flinchCtrl.dispose();
    _pulseCtrl.dispose();
    _correctFlashCtrl.dispose();
    _wrongShakeCtrl.dispose();
    super.dispose();
  }

  List<_BossQuestion> _buildQuestions(int levelId) {
    return switch (levelId) {
      1 => _level1Questions,
      2 => _level2Questions,
      3 => _level3Questions,
      4 => _level4Questions,
      _ => _level1Questions,
    };
  }

  Future<void> _answer(int choiceIdx) async {
    if (_answered) return;
    setState(() {
      _answered  = true;
      _chosenIdx = choiceIdx;
    });

    final q = _questions[_currentIndex];
    final correct = (choiceIdx == q.correctIndex);

    if (correct) {
      _correctCount++;
      setState(() {
        _bossHp--;
        _showCheckmark = true;
      });
      _correctFlashCtrl.forward(from: 0);
      await _flinchCtrl.forward(from: 0);
    } else {
      _wrongShakeCtrl.forward(from: 0);
      final hearts = ref.read(heartsProvider);
      if (hearts.heartsCount > 0) {
        await ref.read(heartsProvider.notifier).loseHeart(
          inventory: ref.read(inventoryProvider.notifier),
        );
      }
      if (ref.read(heartsProvider).heartsCount <= 0) {
        if (mounted) context.go('/');
        return;
      }
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    if (_bossHp <= 0 || _currentIndex >= _questions.length - 1) {
      _endBattle();
      return;
    }

    setState(() {
      _currentIndex++;
      _answered  = false;
      _chosenIdx = null;
      _showCheckmark = false;
    });
  }

  Future<void> _endBattle() async {
    await ref.read(bossProvider(widget.levelId).notifier).recordDefeat(
          score: _correctCount,
          isReplay: _isReplay,
        );
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid != null) {
      await StreakService.recordActivity(uid);
      if (mounted) ref.read(globalStreakProvider.notifier).refresh();
    }
    if (mounted) {
      context.go(
        '/levels/${widget.levelId}/boss/defeat',
        extra: {'isReplay': _isReplay},
      );
    }
  }

  BossType get _bossType => switch (widget.levelId) {
        1 => BossType.debtCollector,
        2 => BossType.loanShark,
        3 => BossType.gambler,
        4 => BossType.taxEvader,
        _ => BossType.debtCollector,
      };

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('No questions available')));
    }
    final q = _questions[_currentIndex];
    final config = kBossConfigs.firstWhere(
      (c) => c.levelId == widget.levelId,
      orElse: () => kBossConfigs.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: Text(config.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
        actions: const [HeartsHUD()],
      ),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: AnimatedBuilder(
              animation: _wrongShakeCtrl,
              builder: (_, child) {
                final t = _wrongShakeAnim.value;
                final dx = t == 0
                    ? 0.0
                    : sin(t * pi * 10) * 8 * (1 - t);
                return Transform.translate(
                  offset: Offset(dx, 0),
                  child: child,
                );
              },
              child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 8,
          bottom: MediaQuery.paddingOf(context).bottom + 16,
        ),
        child: Column(
          children: [
            BossHealthBar(currentHp: _bossHp, maxHp: kBossMaxHp),
            const SizedBox(height: 16),
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: _pulseAnim.value),
                        blurRadius: 48,
                        spreadRadius: 16,
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: AnimatedBuilder(
                  animation: _flinchAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                        _flinchAnim.value * sin(_flinchCtrl.value * 10), 0),
                    child: child,
                  ),
                  child: SizedBox(
                    height: 180,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: BossCharacterPainter(bossType: _bossType),
                        size: const Size(160, 180),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${_currentIndex + 1} / ${_questions.length}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1B2D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E3A5F)),
              ),
              child: Text(
                q.question,
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(q.choices.length, (i) {
              Color borderColor = Colors.white24;
              if (_answered) {
                if (i == q.correctIndex) {
                  borderColor = kNeonMint;
                } else if (i == _chosenIdx) {
                  borderColor = const Color(0xFFE74C3C);
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => _answer(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2A44),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Text(
                      q.choices[i],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
            ),
          ),
          // Full-screen green flash on correct answer
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _correctFlashAnim,
                builder: (_, __) => Container(
                  color: const Color(0xFF2BC48A)
                      .withValues(alpha: _correctFlashAnim.value),
                ),
              ),
            ),
          ),
          // Full-screen red flash on wrong answer
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _wrongFlashAnim,
                builder: (_, __) => Container(
                  color: const Color(0xFFE53935)
                      .withValues(alpha: _wrongFlashAnim.value),
                ),
              ),
            ),
          ),
          // Checkmark bounce on correct
          if (_showCheckmark)
            Center(
              child: IgnorePointer(
                child: ScaleTransition(
                  scale: _checkmarkAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2BC48A),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 72,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BossQuestion {
  final String question;
  final List<String> choices;
  final int correctIndex;

  const _BossQuestion({
    required this.question,
    required this.choices,
    required this.correctIndex,
  });
}

const _level1Questions = [
  _BossQuestion(
    question: 'What is compound interest?',
    choices: ['Interest on the principal only', 'Interest on principal plus previously earned interest', 'A type of bank fee', 'Interest paid annually'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'What does a budget do?',
    choices: ['Increases your income', 'Plans how to spend and save income', 'Reduces taxes', 'Tracks investments'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'A "need" is best described as:',
    choices: ['Something you want to buy', 'Something required for survival or basic living', 'A luxury item', 'An investment'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'If you earn ZMW 3,000 and spend ZMW 2,500, your surplus is:',
    choices: ['ZMW 500', 'ZMW 5,500', 'ZMW 3,000', 'ZMW 2,500'],
    correctIndex: 0,
  ),
  _BossQuestion(
    question: 'What is an emergency fund for?',
    choices: ['Buying luxury goods', 'Covering unexpected expenses', 'Paying regular bills', 'Investing in shares'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'Which is the safest place to keep savings in Zambia?',
    choices: ['Under the mattress', 'In a regulated bank account', 'In a pyramid scheme', 'In foreign currency only'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'What does ZCCM-IH stand for?',
    choices: ['Zambia Credit Corporation', 'Zambia Consolidated Copper Mines Investments Holdings', 'Zambia Commercial Currency Market', 'Zambia Consumer Credit Management'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'A credit score measures:',
    choices: ['How much money you have saved', 'Your creditworthiness based on repayment history', 'The interest rate on loans', 'Your annual income'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'Inflation means:',
    choices: ['Prices are falling', 'The economy is growing fast', 'General price levels are rising over time', 'Interest rates are increasing'],
    correctIndex: 2,
  ),
  _BossQuestion(
    question: 'What is the Kwacha (ZMW)?',
    choices: ['Zambia\'s national currency', 'A type of investment fund', 'A bank in Lusaka', 'A mobile money platform'],
    correctIndex: 0,
  ),
];

const _level2Questions = [
  _BossQuestion(
    question: 'Debt consolidation means:',
    choices: ['Taking a new loan to pay off multiple existing debts', 'Increasing your total debt', 'Hiding your debt from the bank', 'Defaulting on all loans'],
    correctIndex: 0,
  ),
  _BossQuestion(
    question: 'A collateral is:',
    choices: ['A type of savings account', 'An asset pledged to secure a loan', 'Monthly bank fees', 'The loan interest rate'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'What does APR stand for?',
    choices: ['Annual Percentage Rate', 'Asset Protection Ratio', 'Annual Payment Requirement', 'Accrued Principal Return'],
    correctIndex: 0,
  ),
  _BossQuestion(
    question: 'Good debt typically:',
    choices: ['Funds consumption with no return', 'Finances assets that grow in value', 'Charges the highest interest', 'Is never repaid'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'Credit utilisation ratio is:',
    choices: ['Your income vs expenses ratio', 'The percentage of available credit you are using', 'The number of credit cards you own', 'Your total loan amount'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'Defaulting on a loan means:',
    choices: ['Paying it early', 'Failing to meet repayment obligations', 'Refinancing at a lower rate', 'Transferring the loan to another person'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'A guarantor on a loan:',
    choices: ['Receives interest from the loan', 'Agrees to repay if the borrower defaults', 'Sets the loan interest rate', 'Owns the collateral'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'Which Zambian institution regulates commercial banks?',
    choices: ['ZRA', 'ZCCM', 'Bank of Zambia (BoZ)', 'PACRA'],
    correctIndex: 2,
  ),
  _BossQuestion(
    question: 'Paying only the minimum on a credit card each month:',
    choices: ['Eliminates the debt quickly', 'Results in paying more interest over time', 'Improves your credit score instantly', 'Has no effect on interest'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'A grace period on a loan is:',
    choices: ['A period of higher interest', 'Time allowed before repayments begin', 'A fee waiver period', 'The loan application window'],
    correctIndex: 1,
  ),
];

const _level3Questions = [
  _BossQuestion(
    question: 'Diversification in investing means:',
    choices: ['Putting all money into one asset', 'Spreading investments across different assets to reduce risk', 'Investing only in foreign currencies', 'Maximising returns regardless of risk'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'The Lusaka Securities Exchange (LUSE) is:',
    choices: ['A foreign exchange market', 'Zambia\'s stock exchange', 'A commodity trading floor', 'A government bond issuer only'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'A bull market is characterised by:',
    choices: ['Falling asset prices', 'Rising asset prices and investor optimism', 'High inflation', 'Government intervention'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'A dividend is:',
    choices: ['A company\'s total revenue', 'A portion of company profits paid to shareholders', 'The price of a share', 'A type of bond'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'Liquidity refers to:',
    choices: ['The stability of an investment', 'How easily an asset can be converted to cash', 'The volatility of a share price', 'The annual return on investment'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'Net Worth is calculated as:',
    choices: ['Total income minus taxes', 'Total assets minus total liabilities', 'Monthly savings times 12', 'Annual salary plus bonuses'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'A bear market is:',
    choices: ['A market with rising prices', 'A market with declining prices (>=20% drop)', 'A market with no movement', 'A market for agricultural commodities'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'Dollar-cost averaging means:',
    choices: ['Investing a lump sum at the market peak', 'Investing a fixed amount regularly regardless of price', 'Converting all savings to USD', 'Averaging your portfolio returns'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'A portfolio\'s return of 15% and inflation of 8% gives a real return of:',
    choices: ['23%', '15%', '7%', '8%'],
    correctIndex: 2,
  ),
  _BossQuestion(
    question: 'Zambeef Products is listed on:',
    choices: ['London Stock Exchange only', 'LUSE (Lusaka Securities Exchange)', 'Johannesburg Stock Exchange only', 'New York Stock Exchange'],
    correctIndex: 1,
  ),
];

const _level4Questions = [
  _BossQuestion(
    question: 'VAT in Zambia is currently:',
    choices: ['10%', '15%', '16%', '20%'],
    correctIndex: 2,
  ),
  _BossQuestion(
    question: 'PAYE stands for:',
    choices: ['Pay As You Earn', 'Personal Annual Yield Estimate', 'Payment Against Year End', 'Public Annual Year Expense'],
    correctIndex: 0,
  ),
  _BossQuestion(
    question: 'ZRA stands for:',
    choices: ['Zambia Revenue Authority', 'Zambia Regulatory Agency', 'Zambia Revenue Allocation', 'Zambia Retail Association'],
    correctIndex: 0,
  ),
  _BossQuestion(
    question: 'A sole trader\'s business liability is:',
    choices: ['Limited to business assets only', 'Unlimited — personal assets can be used to pay business debts', 'Zero — the government covers losses', 'Limited to ZMW 100,000'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'A limited company\'s owners are called:',
    choices: ['Partners', 'Shareholders', 'Trustees', 'Directors only'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'PACRA registers:',
    choices: ['Zambia\'s tax records', 'Companies, businesses, and intellectual property in Zambia', 'Land titles in Zambia', 'Import/export permits'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'Break-even point is when:',
    choices: ['Total revenue equals total costs', 'The business makes maximum profit', 'All debts are repaid', 'Revenue exceeds costs by 10%'],
    correctIndex: 0,
  ),
  _BossQuestion(
    question: 'Working capital is:',
    choices: ['Total assets minus long-term liabilities', 'Current assets minus current liabilities', 'Annual revenue minus annual costs', 'Equity minus retained earnings'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'A business plan primarily helps to:',
    choices: ['Register a trademark', 'Define goals, strategies, and financial projections', 'File tax returns', 'Hire employees'],
    correctIndex: 1,
  ),
  _BossQuestion(
    question: 'Retained earnings are:',
    choices: ['Dividends paid to shareholders', 'Profits reinvested back into the business', 'Bank loans taken by the company', 'Government grants received'],
    correctIndex: 1,
  ),
];
