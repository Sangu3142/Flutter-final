/// formatters_test.dart
/// Characterization tests for [compactNumber].
///
/// Every expectation below is the output the three former private `_fmt` /
/// inline implementations produced before they were merged. These values must
/// not change — they are the contract, not a suggestion.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:zamwealth_quest/core/formatters.dart';

void main() {
  group('compactNumber — plain integer branch', () {
    test('zero renders as "0"', () {
      expect(compactNumber(0), '0');
    });

    test('values below 1000 render unabbreviated', () {
      expect(compactNumber(1), '1');
      expect(compactNumber(42), '42');
      expect(compactNumber(999), '999');
    });

    test('negative values fall through to the plain branch, not to K/M', () {
      // Both threshold comparisons are `>=`, so negatives never abbreviate.
      // The Dashboard HUD relies on this by passing .abs() and prefixing '-'.
      expect(compactNumber(-1), '-1');
      expect(compactNumber(-5000), '-5000');
      expect(compactNumber(-2500000), '-2500000');
    });
  });

  group('compactNumber — K branch', () {
    test('1000 is the inclusive lower bound', () {
      expect(compactNumber(1000), '1K');
    });

    test('K uses zero decimal places and rounds half away from zero', () {
      expect(compactNumber(1400), '1K');
      expect(compactNumber(1500), '2K');
      expect(compactNumber(2500), '3K');
      expect(compactNumber(12345), '12K');
    });

    test('999999 is the inclusive upper bound of the K branch', () {
      expect(compactNumber(999999), '1000K');
    });
  });

  group('compactNumber — M branch', () {
    test('1000000 is the inclusive lower bound', () {
      expect(compactNumber(1000000), '1.0M');
    });

    test('M uses exactly one decimal place', () {
      expect(compactNumber(1500000), '1.5M');
      expect(compactNumber(2340000), '2.3M');
      expect(compactNumber(999000000), '999.0M');
    });
  });
}
