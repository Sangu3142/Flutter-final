/// loans_screen.dart
/// Purpose: Loan & Debt Simulator — take loans, pay instalments, track credit.
/// Palette: cool blue (#0077B6) + danger red (#E63946)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/loans/models/loan_record.dart';
import 'package:zamwealth_quest/features/wallet/providers/wallet_provider.dart';
import 'package:zamwealth_quest/features/loans/providers/loans_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const _kBlue = Color(0xFF0077B6);
const _kSky = Color(0xFF00B4D8);
const _kRed = Color(0xFFE63946);
const _kDark = Color(0xFF080D18);
const _kCard = Color(0xFF0F1A2E);
const _kText = Color(0xFFE0F0FF);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class LoansScreen extends ConsumerWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansState = ref.watch(loansProvider);
    final wallet = ref.watch(walletProvider);
    final record = loansState.record;

    return Scaffold(
      backgroundColor: _kDark,
      appBar: AppBar(
        backgroundColor: _kDark,
        foregroundColor: _kText,
        title: const Text('Loans & Debt',
            style: TextStyle(
                color: _kText, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTakeLoanDialog(context, ref, record),
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Take Loan'),
      ),
      body: record == null
          ? const Center(child: CircularProgressIndicator(color: _kBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreditMeter(record.creditScore),
                  const SizedBox(height: 16),
                  _buildSummaryRow(record, wallet),
                  const SizedBox(height: 20),
                  _buildLoansList(context, ref, record, wallet),
                  const SizedBox(height: 16),
                  _buildEventsCard(record),
                  const SizedBox(height: 16),
                  _buildEducationCard(),
                ],
              ),
            ),
    );
  }

  // ── Credit score meter (Debt-O-Meter) ─────────────────────────────────────

  Widget _buildCreditMeter(int score) {
    final pct = score / 850;
    Color barColor;
    String label;
    if (score >= 750) {
      barColor = const Color(0xFF2BC48A);
      label = 'Excellent';
    } else if (score >= 700) {
      barColor = const Color(0xFF90E0EF);
      label = 'Good';
    } else if (score >= 600) {
      barColor = const Color(0xFFFFB703);
      label = 'Fair';
    } else {
      barColor = _kRed;
      label = 'Poor';
    }

    return Container(
      decoration: BoxDecoration(
          color: _kCard, borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Credit Score',
                  style: TextStyle(
                      color: _kText, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: barColor.withValues(alpha: 0.5)),
                ),
                child: Text(label,
                    style: TextStyle(
                        color: barColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('$score',
                  style: TextStyle(
                      color: barColor,
                      fontSize: 36,
                      fontWeight: FontWeight.bold)),
              const Text(' / 850',
                  style: TextStyle(color: Colors.white38, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white12,
              color: barColor,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('300', style: TextStyle(color: Colors.white30, fontSize: 10)),
              Text('Business loan: 700+',
                  style: TextStyle(color: Colors.white38, fontSize: 10)),
              Text('850', style: TextStyle(color: Colors.white30, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Summary row ───────────────────────────────────────────────────────────

  Widget _buildSummaryRow(LoanRecord record, int wallet) {
    final activeLoans = record.loans.where((l) => !l.isPaidOff).toList();
    final overdueCount = activeLoans.where((l) => l.isOverdue).length;
    return Row(
      children: [
        Expanded(
            child: _statCard('Active Loans', '${activeLoans.length}', _kSky)),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard(
                'Monthly Due',
                '${record.totalMonthlyPayments} ZC',
                _kBlue)),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard(
                'Overdue',
                '$overdueCount',
                overdueCount > 0 ? _kRed : const Color(0xFF2BC48A))),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label,
              style: TextStyle(
                  color: _kText.withValues(alpha: 0.6), fontSize: 11)),
        ],
      ),
    );
  }

  // ── Loans list ────────────────────────────────────────────────────────────

  Widget _buildLoansList(BuildContext context, WidgetRef ref,
      LoanRecord record, int wallet) {
    final loans = record.loans;
    if (loans.isEmpty) {
      return Container(
        decoration: BoxDecoration(
            color: _kCard, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Text('🏦', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text('No loans yet',
                  style: TextStyle(color: _kText.withValues(alpha: 0.6))),
              const SizedBox(height: 4),
              Text('Tap "Take Loan" to borrow ZamCoins',
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.4), fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Loans',
            style: TextStyle(
                color: _kSky, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        ...loans.map((loan) => _buildLoanCard(context, ref, loan, wallet)),
      ],
    );
  }

  Widget _buildLoanCard(
      BuildContext context, WidgetRef ref, LoanModel loan, int wallet) {
    final isPaid = loan.isPaidOff;
    final emoji = LoanModel.loanEmojis[loan.loanType] ?? '💳';
    final borderColor =
        loan.isOverdue ? _kRed : (isPaid ? Colors.white12 : _kBlue);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${loan.loanType[0].toUpperCase()}${loan.loanType.substring(1)} Loan',
                      style: TextStyle(
                          color: isPaid
                              ? Colors.white38
                              : _kText,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Text(
                      '${(loan.interestRateAnnual * 100).round()}% pa · ${loan.monthsRemaining} months left',
                      style: TextStyle(
                          color: _kText.withValues(alpha: 0.5), fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (loan.isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _kRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('OVERDUE',
                      style: TextStyle(
                          color: _kRed,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              if (isPaid)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('PAID',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          if (!isPaid) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 1 -
                    (loan.remainingBalanceZamCoins /
                        loan.principalZamCoins),
                backgroundColor: Colors.white12,
                color: loan.isOverdue ? _kRed : _kBlue,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance: ${loan.remainingBalanceZamCoins} ZC',
                  style:
                      TextStyle(color: _kText.withValues(alpha: 0.6), fontSize: 12),
                ),
                ElevatedButton(
                  onPressed:
                      wallet >= loan.monthlyPaymentZamCoins
                          ? () => _payInstalment(context, ref, loan.loanId)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        loan.isOverdue ? _kRed : _kBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    minimumSize: const Size(80, 30),
                  ),
                  child: Text('Pay ${loan.monthlyPaymentZamCoins} ZC',
                      style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _payInstalment(
      BuildContext context, WidgetRef ref, String loanId) async {
    final ok = await ref.read(loansProvider.notifier).payInstalment(loanId);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough ZamCoins!')),
      );
    }
  }

  // ── Take loan dialog ──────────────────────────────────────────────────────

  void _showTakeLoanDialog(
      BuildContext context, WidgetRef ref, LoanRecord? record) {
    String selectedType = 'personal';
    final amountCtrl = TextEditingController();
    final creditScore = record?.creditScore ?? kCreditScoreDefault;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          final maxAmt = LoanModel.loanMaxAmounts[selectedType] ?? 200;
          final rate = LoanModel.loanRates[selectedType] ?? 0.25;
          final term = LoanModel.loanTermMonths[selectedType] ?? 12;
          final isBusinessLocked = selectedType == 'business' &&
              creditScore < kBusinessLoanMinCreditScore;

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: _kCard,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text('Take a Loan',
                        style: TextStyle(
                            color: _kSky,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Credit Score: $creditScore / 850',
                        style: TextStyle(
                            color: _kText.withValues(alpha: 0.6),
                            fontSize: 12)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      dropdownColor: _kCard,
                      style: const TextStyle(color: _kText),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _kDark,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                      ),
                      items: LoanModel.loanRates.keys.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(
                            '${LoanModel.loanEmojis[t]} ${t[0].toUpperCase()}${t.substring(1)}'
                            ' (${(LoanModel.loanRates[t]! * 100).round()}% pa)',
                            style:
                                const TextStyle(color: _kText, fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDlgState(() => selectedType = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                        'Max: $maxAmt ZC  ·  Term: $term months  ·  Rate: ${(rate * 100).round()}% pa',
                        style: TextStyle(
                            color: _kText.withValues(alpha: 0.5),
                            fontSize: 11)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(color: _kText),
                      decoration: InputDecoration(
                        hintText: 'Amount (1–$maxAmt ZC)',
                        hintStyle:
                            TextStyle(color: _kText.withValues(alpha: 0.4)),
                        filled: true,
                        fillColor: _kDark,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _kSky)),
                      ),
                    ),
                    if (isBusinessLocked)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '⚠️ Business loan requires credit score >= $kBusinessLoanMinCreditScore',
                          style: TextStyle(
                              color: _kRed.withValues(alpha: 0.8),
                              fontSize: 11),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: _kText.withValues(alpha: 0.5))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isBusinessLocked ? Colors.grey : _kBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: isBusinessLocked
                                ? null
                                : () async {
                                    final amt =
                                        int.tryParse(amountCtrl.text.trim()) ??
                                            0;
                                    Navigator.pop(ctx);
                                    final ok = await ref
                                        .read(loansProvider.notifier)
                                        .takeLoan(
                                            loanType: selectedType,
                                            amountZamCoins: amt);
                                    if (!ok && ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Invalid amount or loan limit reached.')),
                                      );
                                    }
                                  },
                            child: const Text('Borrow'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Events + education ────────────────────────────────────────────────────

  Widget _buildEventsCard(LoanRecord record) {
    if (record.recentEvents.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration:
          BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity',
              style: TextStyle(
                  color: _kSky, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ...record.recentEvents.take(6).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(e,
                    style: TextStyle(
                        color: _kText.withValues(alpha: 0.7), fontSize: 12)),
              )),
        ],
      ),
    );
  }

  Widget _buildEducationCard() {
    return Container(
      decoration: BoxDecoration(
        color: _kBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: _kBlue.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school, color: _kSky, size: 18),
              SizedBox(width: 6),
              Text('Debt Wisdom',
                  style: TextStyle(
                      color: _kSky, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          _tip('Home loans have the lowest interest — great for long-term wealth building.'),
          _tip('Overdue payments damage your credit score by $kOverdueCreditPenalty points.'),
          _tip('A good credit score (700+) unlocks business loans for your enterprise.'),
          _tip('Pay on time for +$kOnTimeCreditReward credit score per payment.'),
        ],
      ),
    );
  }

  Widget _tip(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ',
                style: TextStyle(
                    color: _kSky.withValues(alpha: 0.7), fontSize: 13)),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.65), fontSize: 12)),
            ),
          ],
        ),
      );
}
