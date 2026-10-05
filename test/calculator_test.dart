import 'package:flutter_custom_numpad/flutter_custom_numpad.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberPadCalculator.evaluate', () {
    test('respects operator precedence', () {
      expect(NumberPadCalculator.evaluate('2+3×4'), 14);
      expect(NumberPadCalculator.evaluate('10-4÷2'), 8);
    });

    test('handles decimals, negatives, percent and square root', () {
      expect(NumberPadCalculator.evaluate('10÷4'), 2.5);
      expect(NumberPadCalculator.evaluate('-5+2'), -3);
      expect(NumberPadCalculator.evaluate('50%'), 0.5);
      expect(NumberPadCalculator.evaluate('√9+1'), 4);
      expect(NumberPadCalculator.evaluate('2√9'), 6);
      expect(NumberPadCalculator.evaluate('5.'), 5);
    });

    test('accepts * and / as aliases', () {
      expect(NumberPadCalculator.evaluate('6*7'), 42);
      expect(NumberPadCalculator.evaluate('9/3'), 3);
    });

    test('returns null for undefined or malformed input', () {
      expect(NumberPadCalculator.evaluate('1÷0'), isNull);
      expect(NumberPadCalculator.evaluate('√-4'), isNull);
      expect(NumberPadCalculator.evaluate('1+'), isNull);
      expect(NumberPadCalculator.evaluate('.'), isNull);
      expect(NumberPadCalculator.evaluate('1.2.3'), isNull);
      expect(NumberPadCalculator.evaluate('abc'), isNull);
      expect(NumberPadCalculator.evaluate(''), isNull);
    });
  });

  group('NumberPadCalculator.format', () {
    test('drops trailing zeros and float noise', () {
      expect(NumberPadCalculator.format(2.0), '2');
      expect(NumberPadCalculator.format(0.1 + 0.2), '0.3');
      expect(NumberPadCalculator.format(-2.5), '-2.5');
      expect(NumberPadCalculator.format(-0.0), '0');
    });
  });
}
