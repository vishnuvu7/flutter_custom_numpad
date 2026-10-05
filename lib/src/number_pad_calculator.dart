import 'dart:math' as math;

/// Evaluates expressions produced by `NumberPad.calculator()`.
///
/// Supports `+`, `-`, `×` (or `*`), `÷` (or `/`), postfix `%` (divides the
/// preceding number by 100) and prefix `√`. Multiplication and division bind
/// tighter than addition and subtraction, and `√` binds tighter than both.
class NumberPadCalculator {
  NumberPadCalculator._();

  /// Characters treated as binary operators.
  static const Set<String> binaryOperators = {'+', '-', '×', '÷'};

  /// Evaluates [expression] and returns the result, or `null` if the
  /// expression is malformed or the result is undefined (for example
  /// division by zero or the square root of a negative number).
  static double? evaluate(String expression) {
    final tokens = _tokenize(expression);
    if (tokens == null || tokens.isEmpty) return null;
    final parser = _Parser(tokens);
    final result = parser.parseExpression();
    if (result == null || !parser.isAtEnd || !result.isFinite) return null;
    return result;
  }

  /// Formats [value] for display, dropping a trailing `.0` and limiting
  /// floating-point noise to 12 significant digits.
  static String format(double value) {
    if (value == 0) return '0';
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    final text = value.toStringAsPrecision(12);
    if (text.contains('e')) return text;
    return text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static List<String>? _tokenize(String input) {
    final tokens = <String>[];
    var i = 0;
    while (i < input.length) {
      final char = input[i];
      if (char == ' ') {
        i++;
      } else if (_isNumberChar(char)) {
        final start = i;
        while (i < input.length && _isNumberChar(input[i])) {
          i++;
        }
        tokens.add(input.substring(start, i));
      } else if (char == '*') {
        tokens.add('×');
        i++;
      } else if (char == '/') {
        tokens.add('÷');
        i++;
      } else if (binaryOperators.contains(char) || char == '%' || char == '√') {
        tokens.add(char);
        i++;
      } else {
        return null;
      }
    }
    return tokens;
  }

  static bool _isNumberChar(String char) =>
      char == '.' || (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57);
}

class _Parser {
  _Parser(this._tokens);

  final List<String> _tokens;
  int _position = 0;

  bool get isAtEnd => _position >= _tokens.length;

  String? get _peek => isAtEnd ? null : _tokens[_position];

  double? parseExpression() {
    var left = _parseTerm();
    while (left != null && (_peek == '+' || _peek == '-')) {
      final op = _tokens[_position++];
      final right = _parseTerm();
      if (right == null) return null;
      left = op == '+' ? left + right : left - right;
    }
    return left;
  }

  double? _parseTerm() {
    var left = _parseUnary();
    while (left != null) {
      final op = _peek;
      if (op == '×' || op == '÷') {
        _position++;
      } else if (op != '√') {
        break;
      }
      final right = _parseUnary();
      if (right == null) return null;
      if (op == '÷') {
        if (right == 0) return null;
        left = left / right;
      } else {
        // `×`, or implicit multiplication such as `2√9`.
        left = left * right;
      }
    }
    return left;
  }

  double? _parseUnary() {
    final token = _peek;
    if (token == '-' || token == '+') {
      _position++;
      final operand = _parseUnary();
      if (operand == null) return null;
      return token == '-' ? -operand : operand;
    }
    if (token == '√') {
      _position++;
      final operand = _parseUnary();
      if (operand == null || operand < 0) return null;
      return math.sqrt(operand);
    }
    return _parsePostfix();
  }

  double? _parsePostfix() {
    final token = _peek;
    if (token == null || token == '.') return null;
    var text = token;
    if (text.endsWith('.')) text = '${text}0';
    final parsed = double.tryParse(text);
    if (parsed == null) return null;
    var value = parsed;
    _position++;
    while (_peek == '%') {
      _position++;
      value /= 100;
    }
    return value;
  }
}
