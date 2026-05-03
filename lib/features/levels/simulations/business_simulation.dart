/// business_simulation.dart
/// Purpose: Level 4 business simulations in four modes:
///   • pacra — PACRA Business Registration step-through
///   • revenue — Revenue vs. Profit Calculator
///   • payroll — Payroll Simulator with NAPSA/PAYE deductions
///   • taxQuiz — Tax Fundamentals Quiz (Zambia ZRA tax concepts)
/// Reads from: nothing (self-contained)
/// Writes to: nothing directly (onComplete callback)
/// Navigation: closed via onComplete
library;

import 'package:flutter/material.dart';
import 'package:zamwealth_quest/core/theme.dart';

/// Which business simulation mode to render.
enum BusinessMode { pacra, revenue, payroll, taxQuiz }

/// [BusinessSimulation] covers four Level 4 entrepreneurship exercises.
class BusinessSimulation extends StatefulWidget {
  const BusinessSimulation({
    super.key,
    required this.mode,
    required this.onComplete,
  });

  final BusinessMode mode;
  final VoidCallback onComplete;

  @override
  State<BusinessSimulation> createState() => _BusinessSimulationState();
}

class _BusinessSimulationState extends State<BusinessSimulation> {
  // ── PACRA state ──────────────────────────────────────────────────────────
  int _pacraStep = 0;
  final List<bool> _pacraStepsDone = List.filled(6, false);

  static const _pacraSteps = [
    {
      'title': 'Choose Business Structure',
      'desc': 'Decide: Sole Trader, Partnership, or Limited Company (Ltd)?\n\n'
          '• Sole Trader: ZMW 100 registration, full personal liability\n'
          '• Partnership: ZMW 200, shared liability\n'
          '• Limited Company: ZMW 400–1,200, limited liability, most credible',
      'action': 'Select: Sole Trader (cheapest & simplest)',
      'emoji': '🏢',
      'cost': 'ZMW 100',
    },
    {
      'title': 'Reserve Business Name',
      'desc': 'Submit 3 proposed names to PACRA. They check uniqueness in '
          'the register. Approval takes 1–2 business days.\n\n'
          'Fee: ZMW 50 per name search.',
      'action': 'Reserve: "CopperRise Traders"',
      'emoji': '📛',
      'cost': 'ZMW 50',
    },
    {
      'title': 'Prepare Registration Documents',
      'desc': 'Required documents:\n'
          '• National Registration Card (NRC) or passport\n'
          '• Proof of address (utility bill, max 3 months old)\n'
          '• Completed PACRA Form 1 (Business Registration Form)\n'
          '• Passport-size photos (2)',
      'action': 'Documents gathered ✓',
      'emoji': '📋',
      'cost': 'ZMW 0',
    },
    {
      'title': 'Submit to PACRA Office',
      'desc': 'Submit at the nearest PACRA office (Lusaka, Ndola, Kitwe, '
          'Livingstone, or online via pacra.org.zm).\n\n'
          'Registration takes 3–5 business days. You receive a:\n'
          '• Certificate of Registration\n'
          '• Business Licence (from local council)',
      'action': 'Application submitted',
      'emoji': '🏛️',
      'cost': 'ZMW 100',
    },
    {
      'title': 'Register for TPIN (ZRA)',
      'desc': 'Obtain a Taxpayer Identification Number from Zambia Revenue '
          'Authority (ZRA). Required for:\n'
          '• Filing tax returns\n'
          '• Opening a business bank account\n'
          '• Invoicing other businesses\n\n'
          'Free registration at zra.org.zm',
      'action': 'TPIN Obtained ✓',
      'emoji': '🔢',
      'cost': 'FREE',
    },
    {
      'title': 'Open Business Bank Account',
      'desc': 'Required documents:\n'
          '• PACRA Certificate of Registration\n'
          '• TPIN Certificate\n'
          '• NRC/Passport\n'
          '• Minimum deposit (varies: ZMW 200–2,000)\n\n'
          'Recommended: Zanaco Business, FNB Zambia, or Atlas Mara.',
      'action': 'Account opened — you\'re in business! 🎉',
      'emoji': '🏦',
      'cost': 'ZMW 200+',
    },
  ];

  // ── Revenue / Profit state ───────────────────────────────────────────────
  double _revenue = 15000.0;
  double _cogs = 8000.0; // Cost of Goods Sold
  double _opex = 3000.0; // Operating Expenses (rent, utilities, salaries)
  final double _tax = 0.35; // Zambia corporate tax rate 35%

  // ── Payroll state ────────────────────────────────────────────────────────
  double _grossSalary = 5000.0;
  int _numEmployees = 1;

  // ── Quiz state ───────────────────────────────────────────────────────────
  int _quizIndex = 0;
  int _quizScore = 0;
  int? _selectedAnswer;
  bool _quizComplete = false;

  static const _quizQuestions = [
    {
      'question': 'What is the standard corporate tax rate in Zambia?',
      'options': ['25%', '30%', '35%', '40%'],
      'correct': 2,
      'explanation':
          'Zambia\'s standard corporate tax rate is 35% (as of 2024). Mining companies pay 30%.',
    },
    {
      'question': 'NAPSA employee contribution rate is:',
      'options': ['3%', '5%', '10%', '15%'],
      'correct': 1,
      'explanation':
          'Employees contribute 5% of gross salary to NAPSA (National Pension Scheme). Employers also contribute 5%.',
    },
    {
      'question': 'What does TPIN stand for?',
      'options': [
        'Tax Payment Index Number',
        'Taxpayer Identification Number',
        'Trade Payment Invoice Number',
        'Treasury Payment Invoice Note'
      ],
      'correct': 1,
      'explanation':
          'TPIN = Taxpayer Identification Number, issued free by ZRA (Zambia Revenue Authority).',
    },
    {
      'question':
          'For ZMW income between ZMW 57,601 and ZMW 82,800/year, PAYE rate is:',
      'options': ['20%', '25%', '30%', '37.5%'],
      'correct': 2,
      'explanation':
          'PAYE (Pay As You Earn) is 30% on annual income ZMW 57,601–82,800.',
    },
    {
      'question': 'VAT in Zambia is currently charged at:',
      'options': ['12%', '15%', '16%', '20%'],
      'correct': 2,
      'explanation':
          'Zambia\'s VAT rate is 16% on taxable supplies. Zero-rated: exports, basic foodstuffs.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: kCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _handle(),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  children: [
                    ..._buildContent(context),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _handle() => Center(
        child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 6),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: kCopperLight.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  List<Widget> _buildContent(BuildContext context) {
    switch (widget.mode) {
      case BusinessMode.pacra:
        return _pacraContent(context);
      case BusinessMode.revenue:
        return _revenueContent(context);
      case BusinessMode.payroll:
        return _payrollContent(context);
      case BusinessMode.taxQuiz:
        return _taxQuizContent(context);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 1: PACRA Business Registration Step-Through
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _pacraContent(BuildContext context) {
    final allDone = _pacraStepsDone.every((d) => d);
    final completedSteps = _pacraStepsDone.where((d) => d).length;
    final totalCost = ['ZMW 100', 'ZMW 50', 'ZMW 0', 'ZMW 100', 'FREE', '']
        .asMap()
        .entries
        .where((e) => _pacraStepsDone[e.key])
        .fold(0.0, (sum, e) {
      final s = e.value;
      if (s == 'FREE' || s == '') return sum;
      return sum + double.tryParse(s.replaceAll('ZMW ', ''))!;
    });

    return [
      _header(
          context,
          '🏛️ PACRA Business Registration',
          'Walk through every step to register your Zambian business. '
              'Complete each step by tapping the action button.'),
      const SizedBox(height: 8),

      // Progress bar
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: zamCard(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$completedSteps / ${_pacraSteps.length} steps',
                    style: Theme.of(context).textTheme.labelMedium),
                Text('Est. cost so far: ZMW ${totalCost.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: kCopper, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completedSteps / _pacraSteps.length,
                backgroundColor: kCopperLight.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      // Step cards
      ..._pacraSteps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isDone = _pacraStepsDone[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: zamCard(highlighted: !isDone && i == _pacraStep),
          child: Column(
            children: [
              // Step header
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDone
                      ? kGreen
                      : (i == _pacraStep ? kCopper : kCopperSurface),
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: i == _pacraStep ? Colors.white : kCharcoal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                title: Text(
                  step['title'] as String,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isDone ? kCharcoalLight : kCharcoal,
                      ),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    step['cost'] as String,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: kCopper, fontWeight: FontWeight.w700),
                  ),
                ),
                onTap: () =>
                    setState(() => _pacraStep = isDone ? _pacraStep : i),
              ),

              // Expanded detail (only for current step)
              if (i == _pacraStep || isDone)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['desc'] as String,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: kCharcoalLight, height: 1.5),
                      ),
                      const SizedBox(height: 10),
                      if (!isDone)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _pacraStepsDone[i] = true;
                                if (i < _pacraSteps.length - 1) {
                                  _pacraStep = i + 1;
                                }
                              });
                            },
                            icon: Text(step['emoji'] as String),
                            label: Text(step['action'] as String),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kCopper,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        )
                      else
                        Text('✅ ${step['action']}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: kGreen)),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),

      if (allDone) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [kGreen, kGreenLight]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Business Registered!',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                    Text(
                      'You\'ve completed all PACRA steps. '
                      'Total cost: ZMW ${totalCost.toStringAsFixed(0)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: widget.onComplete,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Complete Simulation ✓'),
        ),
      ],
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 2: Revenue vs. Profit Calculator
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _revenueContent(BuildContext context) {
    final grossProfit = _revenue - _cogs;
    final operatingProfit = grossProfit - _opex;
    final taxPayable = operatingProfit > 0 ? operatingProfit * _tax : 0.0;
    final netProfit = operatingProfit - taxPayable;
    final grossMargin = _revenue > 0 ? (grossProfit / _revenue * 100) : 0.0;
    final netMargin = _revenue > 0 ? (netProfit / _revenue * 100) : 0.0;

    return [
      _header(
          context,
          '💹 Revenue vs. Profit Calculator',
          'Understand the difference between revenue, gross profit, '
              'operating profit, and net profit after Zambian taxes.'),
      const SizedBox(height: 16),

      _sliderTile(context,
          label: '📦 Monthly Revenue',
          value: _revenue,
          min: 1000,
          max: 200000,
          divisions: 199,
          display: 'ZMW ${_revenue.toStringAsFixed(0)}',
          color: kGreen,
          onChanged: (v) => setState(() => _revenue = v)),

      _sliderTile(context,
          label: '🏭 Cost of Goods Sold (COGS)',
          value: _cogs,
          min: 0,
          max: _revenue,
          divisions: 100,
          display: 'ZMW ${_cogs.toStringAsFixed(0)}',
          color: kError,
          onChanged: (v) => setState(() => _cogs = v)),

      _sliderTile(context,
          label: '🏢 Operating Expenses (Rent, Staff, Utilities)',
          value: _opex,
          min: 0,
          max: grossProfit > 0 ? grossProfit : 1,
          divisions: 100,
          display: 'ZMW ${_opex.toStringAsFixed(0)}',
          color: kWarning,
          onChanged: (v) => setState(() => _opex = v)),

      const SizedBox(height: 12),

      // P&L Waterfall
      Container(
        padding: const EdgeInsets.all(16),
        decoration: zamCard(highlighted: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 P&L Statement',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _plRow(context, '📦 Revenue', _revenue, kGreen, bold: true),
            _plRow(context, '  - COGS', -_cogs, kError),
            Divider(color: kCopperLight.withValues(alpha: 0.3), height: 16),
            _plRow(context, '  = Gross Profit', grossProfit,
                grossProfit >= 0 ? kGreen : kError,
                bold: true),
            Text(
              '  Gross Margin: ${grossMargin.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kCharcoalLight, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 4),
            _plRow(context, '  - Operating Expenses', -_opex, kWarning),
            Divider(color: kCopperLight.withValues(alpha: 0.3), height: 16),
            _plRow(context, '  = Operating Profit', operatingProfit,
                operatingProfit >= 0 ? kGreen : kError,
                bold: true),
            _plRow(context, '  - Corporate Tax (35%)', -taxPayable, kError),
            Divider(color: kCopperLight.withValues(alpha: 0.3), height: 16),
            _plRow(context, '  = Net Profit', netProfit,
                netProfit >= 0 ? kGreen : kError,
                bold: true),
            Text(
              '  Net Margin: ${netMargin.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kCharcoalLight, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),

      const SizedBox(height: 12),
      _tipBox(
          context,
          '💡 A healthy business aims for a net profit margin of 10–20%. '
          'ZMW 100K revenue with 15% margin = ZMW 15K net profit per month.'),

      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: widget.onComplete,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Complete Simulation ✓'),
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 3: Payroll Simulator
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _payrollContent(BuildContext context) {
    // Zambia PAYE brackets (annual income)
    double paye(double annualGross) {
      if (annualGross <= 57600) return 0;
      if (annualGross <= 82800) return (annualGross - 57600) * 0.20;
      if (annualGross <= 110400) return 5040 + (annualGross - 82800) * 0.30;
      return 5040 + 8280 + (annualGross - 110400) * 0.375;
    }

    final annualGross = _grossSalary * 12;
    final annualPaye = paye(annualGross);
    final monthlyPaye = annualPaye / 12;

    // NAPSA: employee 5%, employer 5%, capped at ZMW 1,221.80/month (2024 cap)
    final employeeNapsa = (_grossSalary * 0.05).clamp(0, 1221.80);
    final employerNapsa = (_grossSalary * 0.05).clamp(0, 1221.80);

    final netSalary = _grossSalary - monthlyPaye - employeeNapsa;
    final employerTotalCost = _grossSalary + employerNapsa;

    return [
      _header(
          context,
          '👥 Payroll Simulator',
          'See how PAYE and NAPSA deductions work in Zambia. '
              'Useful for pricing staff costs and understanding your take-home pay.'),
      const SizedBox(height: 16),

      _sliderTile(context,
          label: '💵 Monthly Gross Salary per Employee',
          value: _grossSalary,
          min: 1000,
          max: 50000,
          divisions: 98,
          display: 'ZMW ${_grossSalary.toStringAsFixed(0)}',
          color: kCopper,
          onChanged: (v) => setState(() => _grossSalary = v)),

      _sliderTile(context,
          label: '👤 Number of Employees',
          value: _numEmployees.toDouble(),
          min: 1,
          max: 20,
          divisions: 19,
          display: '$_numEmployees employees',
          color: kGreen,
          onChanged: (v) => setState(() => _numEmployees = v.round())),

      const SizedBox(height: 12),

      // Single employee payslip
      Container(
        padding: const EdgeInsets.all(16),
        decoration: zamCard(highlighted: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📄 Payslip (per employee)',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _row(context, '💰 Gross Salary',
                'ZMW ${_grossSalary.toStringAsFixed(2)}',
                valueColor: kGreen),
            _row(context, '  - PAYE (income tax)',
                '-ZMW ${monthlyPaye.toStringAsFixed(2)}',
                valueColor: kError),
            _row(context, '  - NAPSA (5% employee)',
                '-ZMW ${employeeNapsa.toStringAsFixed(2)}',
                valueColor: kError),
            Divider(height: 16, color: kCopperLight.withValues(alpha: 0.3)),
            _row(context, '✅ Net Take-Home Pay',
                'ZMW ${netSalary.toStringAsFixed(2)}',
                valueColor: kGreen),
            const SizedBox(height: 8),
            _row(context, '🏢 NAPSA (5% employer)',
                '+ZMW ${employerNapsa.toStringAsFixed(2)}',
                valueColor: kWarning),
            _row(context, '🏢 Total Employer Cost',
                'ZMW ${employerTotalCost.toStringAsFixed(2)}',
                valueColor: kCopper),
          ],
        ),
      ),

      const SizedBox(height: 12),

      // Total payroll cost for all employees
      if (_numEmployees > 1)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kGreen.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGreen.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _row(context, '👥 Total Payroll Cost (${_numEmployees}x)',
                  'ZMW ${(employerTotalCost * _numEmployees).toStringAsFixed(2)}',
                  valueColor: kGreen),
              _row(context, '💰 Total Net Pay Out',
                  'ZMW ${(netSalary * _numEmployees).toStringAsFixed(2)}'),
            ],
          ),
        ),

      const SizedBox(height: 12),
      _tipBox(
          context,
          '💡 Zambia NAPSA caps employer+employee contributions at ZMW 2,443.60/month '
          'combined. High earners save significantly on NAPSA vs. low earners proportionally.'),

      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: widget.onComplete,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Complete Simulation ✓'),
      ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mode 4: Tax Fundamentals Quiz
  // ─────────────────────────────────────────────────────────────────────────

  List<Widget> _taxQuizContent(BuildContext context) {
    if (_quizComplete) {
      return [
        _header(context, '🎓 Tax Fundamentals Quiz', 'Results'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _quizScore >= 4
                  ? [kGreen, kGreenLight]
                  : [kCopper, kCopperLight],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(_quizScore >= 4 ? '🏆' : '📚',
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                '$_quizScore / ${_quizQuestions.length}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
              Text(
                _quizScore >= 4
                    ? 'Tax Expert!'
                    : 'Keep studying — retake the quiz!',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: widget.onComplete,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Complete Simulation ✓'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _quizIndex = 0;
            _quizScore = 0;
            _selectedAnswer = null;
            _quizComplete = false;
          }),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry Quiz'),
        ),
      ];
    }

    final q = _quizQuestions[_quizIndex];
    final options = q['options'] as List<String>;
    final correct = q['correct'] as int;
    final answered = _selectedAnswer != null;

    return [
      _header(
          context,
          '📋 Tax Fundamentals Quiz',
          'Test your knowledge of Zambian tax law. '
              '${_quizIndex + 1} of ${_quizQuestions.length}'),
      const SizedBox(height: 16),

      // Progress chips
      Row(
        children: List.generate(_quizQuestions.length, (i) {
          Color color;
          if (i < _quizIndex) {
            color = kGreen;
          } else if (i == _quizIndex) {
            color = kCopper;
          } else {
            color = kCopperLight.withValues(alpha: 0.3);
          }
          return Expanded(
            child: Container(
              margin:
                  EdgeInsets.only(right: i < _quizQuestions.length - 1 ? 4 : 0),
              height: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),

      const SizedBox(height: 16),

      // Question
      Container(
        padding: const EdgeInsets.all(16),
        decoration: zamCard(),
        child: Text(
          q['question'] as String,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),

      const SizedBox(height: 16),

      // Answer options
      ...List.generate(options.length, (i) {
        Color borderColor = kCopperLight.withValues(alpha: 0.3);
        Color bgColor = Colors.white;
        Widget? trailingIcon;

        if (answered) {
          if (i == correct) {
            borderColor = kGreen;
            bgColor = kGreen.withValues(alpha: 0.07);
            trailingIcon = const Icon(Icons.check_circle, color: kGreen);
          } else if (i == _selectedAnswer && i != correct) {
            borderColor = kError;
            bgColor = kError.withValues(alpha: 0.07);
            trailingIcon = const Icon(Icons.cancel, color: kError);
          }
        }

        return GestureDetector(
          onTap: answered ? null : () => setState(() => _selectedAnswer = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      _selectedAnswer == i && !answered ? kCopper : borderColor,
                  width: _selectedAnswer == i && !answered ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedAnswer == i && !answered
                        ? kCopper
                        : kCopperSurface,
                  ),
                  child: Center(
                    child: Text(
                      ['A', 'B', 'C', 'D'][i],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _selectedAnswer == i && !answered
                            ? Colors.white
                            : kCharcoal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(options[i],
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                if (trailingIcon != null) trailingIcon,
              ],
            ),
          ),
        );
      }),

      // Explanation (shown after answer)
      if (answered) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGold.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(q['explanation'] as String,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: kCharcoal, height: 1.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (_selectedAnswer == correct) _quizScore++;
              if (_quizIndex < _quizQuestions.length - 1) {
                _quizIndex++;
                _selectedAnswer = null;
              } else {
                if (_selectedAnswer == correct) {}
                _quizComplete = true;
              }
            });
          },
          child: Text(_quizIndex < _quizQuestions.length - 1
              ? 'Next Question →'
              : 'See Results 🎓'),
        ),
      ] else ...[
        const SizedBox(height: 4),
        if (_selectedAnswer == null)
          Text(
            'Select an answer above',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: kCharcoalLight, fontStyle: FontStyle.italic),
          ),
      ],
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _header(BuildContext context, String title, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(sub,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: kCharcoalLight, height: 1.4)),
        ],
      );

  Widget _sliderTile(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String display,
    required Color color,
    required ValueChanged<double> onChanged,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: zamCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(label,
                        style: Theme.of(context).textTheme.titleSmall)),
                Text(display,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
            Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              activeColor: color,
              inactiveColor: color.withValues(alpha: 0.2),
              onChanged: onChanged,
            ),
          ],
        ),
      );

  Widget _row(BuildContext context, String label, String value,
          {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: kCharcoalLight)),
            ),
            Text(value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: valueColor ?? kCopper, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _plRow(BuildContext context, String label, double value, Color color,
          {bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kCharcoal,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
            Text(
              'ZMW ${value.abs().toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600),
            ),
          ],
        ),
      );

  Widget _tipBox(BuildContext context, String tip) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kGold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kGold.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(tip,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: kCharcoal, height: 1.5)),
            ),
          ],
        ),
      );
}
