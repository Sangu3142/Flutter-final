/// debt_math_test.dart
/// Characterization tests for the loan arithmetic extracted out of
/// `_DebtSimulationState`. Values pin the behaviour that shipped, so the
/// extraction is proven output-identical.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zamwealth_quest/features/levels/simulations/logic/debt_math.dart';

void main() {
  group('emi', () {
    test('matches the annuity formula at the screen defaults', () {
      // Defaults shipped by the simulation: ZMW 5000 @ 28% p.a. over 12 months.
      const p = 5000.0, rate = 0.28, n = 12;
      const r = rate / 12;
      final expected = p * (r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
      expect(
        emi(principal: p, annualRate: rate, termMonths: n),
        closeTo(expected, 1e-9),
      );
    });

    test('zero interest repays as a flat split, not NaN', () {
      // Guard branch: the annuity formula divides by zero when r == 0.
      expect(emi(principal: 1200, annualRate: 0, termMonths: 12), 100.0);
    });

    test('a one-month term repays principal plus one month of interest', () {
      final v = emi(principal: 1000, annualRate: 0.12, termMonths: 1);
      expect(v, closeTo(1010.0, 1e-9));
    });
  });

  group('totalRepayment / totalInterest', () {
    test('total repayment is emi times the term', () {
      final e = emi(principal: 5000, annualRate: 0.28, termMonths: 12);
      expect(
        totalRepayment(principal: 5000, annualRate: 0.28, termMonths: 12),
        closeTo(e * 12, 1e-9),
      );
    });

    test('interest is repayment minus principal', () {
      final t = totalRepayment(principal: 5000, annualRate: 0.28, termMonths: 12);
      expect(
        totalInterest(principal: 5000, annualRate: 0.28, termMonths: 12),
        closeTo(t - 5000, 1e-9),
      );
    });

    test('a zero-rate loan costs no interest', () {
      expect(
        totalInterest(principal: 1200, annualRate: 0, termMonths: 12),
        closeTo(0, 1e-9),
      );
    });
  });

  group('amortizationSchedule', () {
    test('emits one row per month with the documented keys', () {
      final rows =
          amortizationSchedule(principal: 5000, annualRate: 0.28, termMonths: 12);
      expect(rows, hasLength(12));
      expect(
        rows.first.keys.toSet(),
        {'month', 'payment', 'interest', 'principal', 'balance'},
      );
      expect(rows.first['month'], 1.0);
      expect(rows.last['month'], 12.0);
    });

    test('interest across all rows sums to totalInterest', () {
      final rows =
          amortizationSchedule(principal: 5000, annualRate: 0.28, termMonths: 12);
      final summed =
          rows.fold<double>(0, (a, r) => a + (r['interest'] as double));
      expect(
        summed,
        closeTo(
          totalInterest(principal: 5000, annualRate: 0.28, termMonths: 12),
          1e-6,
        ),
      );
    });

    test('closing balance is floored at zero', () {
      final rows =
          amortizationSchedule(principal: 5000, annualRate: 0.28, termMonths: 12);
      for (final r in rows) {
        expect(r['balance'], greaterThanOrEqualTo(0));
      }
      expect(rows.last['balance'], closeTo(0, 1e-6));
    });
  });

  group('aggressive payoff', () {
    test('clears the loan sooner than the full term', () {
      final months = aggressivePayoffMonths(
          principal: 5000, annualRate: 0.28, termMonths: 12);
      expect(months, lessThan(12));
      expect(months, greaterThan(0));
    });

    test('never exceeds the 2x term safety bound', () {
      // At a rate this high the 1.8x payment barely dents the balance; the
      // bound is what stops the loop.
      final months = aggressivePayoffMonths(
          principal: 50000, annualRate: 5.0, termMonths: 6);
      expect(months, lessThanOrEqualTo(12));
    });

    test('saves a positive amount of interest at the defaults', () {
      final saved = aggressiveInterestSaved(
          principal: 5000, annualRate: 0.28, termMonths: 12);
      expect(saved, greaterThan(0));
      expect(
        saved,
        lessThan(totalInterest(
            principal: 5000, annualRate: 0.28, termMonths: 12)),
      );
    });
  });
}
