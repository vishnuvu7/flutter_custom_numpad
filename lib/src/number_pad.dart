import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'number_pad_calculator.dart';
import 'number_pad_theme.dart';

/// An extra button shown in the number pad's bottom-left slot, typically used
/// for biometric unlock or a "Forgot PIN?" action.
@immutable
class NumberPadAction {
  /// The widget shown on the button, usually an [Icon].
  final Widget icon;

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  /// The label announced by screen readers.
  final String? semanticLabel;

  const NumberPadAction({
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
  });
}

enum _Preset { standard, phoneDialer, calculator, otp, numeric, amount, custom }

enum _Haptic { light, medium, heavy }

/// A customizable number pad widget for Flutter applications.
///
/// This widget provides a number pad with digits 0-9, decimal point,
/// backspace functionality, and optional OK button.
class NumberPad extends StatefulWidget {
  /// Key identifier for the backspace button.
  static const String backspaceKey = 'backspace';

  /// Key identifier for the OK button.
  static const String okKey = 'OK';

  /// Key identifier for the [NumberPadAction] button.
  static const String actionKey = 'action';

  /// Text shown by the calculator preset when an expression can't be
  /// evaluated.
  static const String calculatorErrorText = 'Error';

  /// The text controller to manage the input text.
  final TextEditingController controller;

  /// Maximum length of the input text. In amount mode this counts digits only.
  final int maxLength;

  /// Callback function called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback function called when the OK button is pressed.
  final VoidCallback? onOkPressed;

  /// Whether to show the OK button.
  final bool showOkButton;

  /// Whether to show the decimal point button.
  final bool showDecimalPoint;

  /// The theme configuration for the number pad.
  ///
  /// Fields left `null` fall back to the [NumberPadTheme] registered in
  /// [ThemeData.extensions], then to [NumberPadTheme.fromColorScheme].
  final NumberPadTheme? theme;

  /// The aspect ratio for the buttons.
  final double buttonAspectRatio;

  /// Custom layout configuration (for custom preset).
  final List<List<String>>? customLayout;

  /// Custom button handlers (for custom preset).
  final Map<String, VoidCallback>? customButtonHandlers;

  /// Formatters applied, in order, to every insertion. An insertion is
  /// rejected if the formatters leave the text unchanged.
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum number of digits allowed after the decimal point.
  final int? maxDecimalPlaces;

  /// Largest numeric value the input may reach.
  final num? maxValue;

  /// Whether input may start with redundant zeros such as `007`.
  final bool allowLeadingZeros;

  /// Whether the OK button is enabled for the current text. When `null` the
  /// OK button is always enabled.
  final bool Function(String text)? canSubmit;

  /// Whether the number pad responds to input.
  final bool enabled;

  /// Keys that are shown but can't be pressed.
  final Set<String> disabledKeys;

  /// Optional extra button, such as biometric unlock.
  final NumberPadAction? action;

  /// Overrides for the labels announced by screen readers, keyed by button.
  final Map<String, String>? semanticLabels;

  /// Called with the result each time the calculator evaluates successfully.
  final ValueChanged<double>? onResult;

  /// Number of fractional digits in amount mode.
  final int decimalDigits;

  /// Decimal separator shown in amount mode.
  final String decimalSeparator;

  /// Thousands separator shown in amount mode. Use an empty string to
  /// disable grouping.
  final String groupSeparator;

  /// In amount mode, whether digits fill from the right like a cash register
  /// (typing `1`, `2`, `3` gives `1.23`).
  final bool centsFirst;

  /// Called with the parsed value whenever the amount changes, or `null`
  /// when the input is empty.
  final ValueChanged<double?>? onAmountChanged;

  final _Preset _preset;

  const NumberPad({
    super.key,
    required this.controller,
    this.maxLength = 8,
    this.onChanged,
    this.onOkPressed,
    this.showOkButton = false,
    this.showDecimalPoint = true,
    this.theme,
    this.buttonAspectRatio = 1.5,
    this.inputFormatters,
    this.maxDecimalPlaces,
    this.maxValue,
    this.allowLeadingZeros = true,
    this.canSubmit,
    this.enabled = true,
    this.disabledKeys = const {},
    this.action,
    this.semanticLabels,
  }) : _preset = _Preset.standard,
       customLayout = null,
       customButtonHandlers = null,
       onResult = null,
       decimalDigits = 2,
       decimalSeparator = '.',
       groupSeparator = ',',
       centsFirst = true,
       onAmountChanged = null;

  /// Creates a number pad configured for phone dialer.
  ///
  /// Features:
  /// - No decimal point
  /// - No OK button
  /// - Max length of 15 characters
  /// - Includes `*` and `#` buttons
  factory NumberPad.phoneDialer({
    Key? key,
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
    bool enabled = true,
    Map<String, String>? semanticLabels,
  }) {
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: 15,
      onChanged: onChanged,
      showOkButton: false,
      showDecimalPoint: false,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      enabled: enabled,
      semanticLabels: semanticLabels,
      preset: _Preset.phoneDialer,
    );
  }

  /// Creates a number pad configured as a calculator.
  ///
  /// Features:
  /// - Includes decimal point
  /// - No OK button
  /// - Max input length of 20 characters
  /// - `+`, `-`, `×`, `÷`, `%` and `√` buttons; `=` evaluates the expression
  ///   (see [NumberPadCalculator]) and `C` clears it
  factory NumberPad.calculator({
    Key? key,
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
    ValueChanged<double>? onResult,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
    bool enabled = true,
    Map<String, String>? semanticLabels,
  }) {
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: 20,
      onChanged: onChanged,
      onResult: onResult,
      showOkButton: false,
      showDecimalPoint: true,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      enabled: enabled,
      semanticLabels: semanticLabels,
      preset: _Preset.calculator,
    );
  }

  /// Creates a number pad configured for OTP input.
  ///
  /// Features:
  /// - No decimal point
  /// - OK button
  /// - Limited to [length] digits (6 by default)
  /// - Optional [action] button, e.g. for biometric unlock
  factory NumberPad.otp({
    Key? key,
    required TextEditingController controller,
    int length = 6,
    ValueChanged<String>? onChanged,
    VoidCallback? onOkPressed,
    bool showOkButton = true,
    bool Function(String text)? canSubmit,
    NumberPadAction? action,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
    bool enabled = true,
    Map<String, String>? semanticLabels,
  }) {
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: length,
      onChanged: onChanged,
      onOkPressed: onOkPressed,
      showOkButton: showOkButton,
      showDecimalPoint: false,
      canSubmit: canSubmit,
      action: action,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      enabled: enabled,
      semanticLabels: semanticLabels,
      preset: _Preset.otp,
    );
  }

  /// Creates a number pad configured for general numeric input.
  ///
  /// Features:
  /// - Includes decimal point
  /// - Optional OK button
  /// - Configurable max length, decimal places and max value
  factory NumberPad.numeric({
    Key? key,
    required TextEditingController controller,
    int maxLength = 10,
    ValueChanged<String>? onChanged,
    VoidCallback? onOkPressed,
    bool showOkButton = false,
    bool showDecimalPoint = true,
    int? maxDecimalPlaces,
    num? maxValue,
    bool allowLeadingZeros = false,
    List<TextInputFormatter>? inputFormatters,
    bool Function(String text)? canSubmit,
    NumberPadAction? action,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
    bool enabled = true,
    Set<String> disabledKeys = const {},
    Map<String, String>? semanticLabels,
  }) {
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      onOkPressed: onOkPressed,
      showOkButton: showOkButton,
      showDecimalPoint: showDecimalPoint,
      maxDecimalPlaces: maxDecimalPlaces,
      maxValue: maxValue,
      allowLeadingZeros: allowLeadingZeros,
      inputFormatters: inputFormatters,
      canSubmit: canSubmit,
      action: action,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      enabled: enabled,
      disabledKeys: disabledKeys,
      semanticLabels: semanticLabels,
      preset: _Preset.numeric,
    );
  }

  /// Creates a number pad for entering money amounts.
  ///
  /// The controller holds the formatted text (for example `1,234.56`);
  /// [onAmountChanged] receives the parsed value. With [centsFirst] the
  /// bottom-left key is `00`; otherwise it's the [decimalSeparator].
  factory NumberPad.amount({
    Key? key,
    required TextEditingController controller,
    int maxLength = 12,
    int decimalDigits = 2,
    String decimalSeparator = '.',
    String groupSeparator = ',',
    bool centsFirst = true,
    num? maxValue,
    ValueChanged<String>? onChanged,
    ValueChanged<double?>? onAmountChanged,
    VoidCallback? onOkPressed,
    bool showOkButton = false,
    bool Function(String text)? canSubmit,
    NumberPadAction? action,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
    bool enabled = true,
    Map<String, String>? semanticLabels,
  }) {
    assert(decimalDigits >= 0);
    assert(decimalSeparator.isNotEmpty && decimalSeparator != groupSeparator);
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: maxLength,
      decimalDigits: decimalDigits,
      decimalSeparator: decimalSeparator,
      groupSeparator: groupSeparator,
      centsFirst: centsFirst,
      maxValue: maxValue,
      onChanged: onChanged,
      onAmountChanged: onAmountChanged,
      onOkPressed: onOkPressed,
      showOkButton: showOkButton,
      showDecimalPoint: !centsFirst && decimalDigits > 0,
      canSubmit: canSubmit,
      action: action,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      enabled: enabled,
      semanticLabels: semanticLabels,
      preset: _Preset.amount,
    );
  }

  /// Creates a number pad with custom layout.
  ///
  /// Besides digits, the layout may contain [backspaceKey], [okKey],
  /// [actionKey], `.`, `C`, and any key listed in [customButtonHandlers].
  factory NumberPad.custom({
    Key? key,
    required TextEditingController controller,
    required List<List<String>> layout,
    Map<String, VoidCallback>? customButtonHandlers,
    int maxLength = 10,
    ValueChanged<String>? onChanged,
    VoidCallback? onOkPressed,
    bool Function(String text)? canSubmit,
    NumberPadAction? action,
    List<TextInputFormatter>? inputFormatters,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
    bool enabled = true,
    Set<String> disabledKeys = const {},
    Map<String, String>? semanticLabels,
  }) {
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      onOkPressed: onOkPressed,
      canSubmit: canSubmit,
      action: action,
      inputFormatters: inputFormatters,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      enabled: enabled,
      disabledKeys: disabledKeys,
      semanticLabels: semanticLabels,
      preset: _Preset.custom,
      customLayout: layout,
      customButtonHandlers: customButtonHandlers,
    );
  }

  const NumberPad._({
    super.key,
    required this.controller,
    this.maxLength = 8,
    this.onChanged,
    this.onOkPressed,
    this.showOkButton = false,
    this.showDecimalPoint = true,
    this.theme,
    this.buttonAspectRatio = 1.5,
    this.inputFormatters,
    this.maxDecimalPlaces,
    this.maxValue,
    this.allowLeadingZeros = true,
    this.canSubmit,
    this.enabled = true,
    this.disabledKeys = const {},
    this.action,
    this.semanticLabels,
    this.onResult,
    this.decimalDigits = 2,
    this.decimalSeparator = '.',
    this.groupSeparator = ',',
    this.centsFirst = true,
    this.onAmountChanged,
    required _Preset preset,
    this.customLayout,
    this.customButtonHandlers,
  }) : _preset = preset;

  @override
  State<NumberPad> createState() => _NumberPadState();
}

class _NumberPadState extends State<NumberPad> {
  static const Set<String> _operatorKeys = {'+', '-', '×', '÷', '%', '√'};
  static const Set<String> _symbolKeys = {..._operatorKeys, '=', 'C', '*', '#'};
  static const Map<String, String> _defaultSemanticLabels = {
    NumberPad.backspaceKey: 'Delete',
    NumberPad.okKey: 'Done',
    '.': 'Decimal point',
    '00': 'Double zero',
    '+': 'Plus',
    '-': 'Minus',
    '×': 'Multiply',
    '÷': 'Divide',
    '=': 'Equals',
    '%': 'Percent',
    '√': 'Square root',
    'C': 'Clear',
    '*': 'Star',
    '#': 'Pound',
  };

  bool _justEvaluated = false;

  TextEditingController get _controller => widget.controller;
  String get _text => _controller.text;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(NumberPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.canSubmit != null && mounted) setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Input handling
  // ---------------------------------------------------------------------------

  void _setText(String text) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    widget.onChanged?.call(text);
    if (widget._preset == _Preset.amount) {
      widget.onAmountChanged?.call(_parseAmount(_amountRaw(text)));
    }
  }

  void _feedback(_Haptic type, NumberPadTheme theme) {
    if (theme.enableHapticFeedback) {
      switch (type) {
        case _Haptic.light:
          HapticFeedback.lightImpact();
        case _Haptic.medium:
          HapticFeedback.mediumImpact();
        case _Haptic.heavy:
          HapticFeedback.heavyImpact();
      }
    }
    if (theme.enableSoundFeedback) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void _onKeyTap(String key, NumberPadTheme theme) {
    final customHandler = widget.customButtonHandlers?[key];
    if (customHandler != null) {
      _feedback(_Haptic.light, theme);
      customHandler();
      return;
    }
    switch (key) {
      case NumberPad.okKey:
        _feedback(_Haptic.medium, theme);
        widget.onOkPressed?.call();
      case NumberPad.actionKey:
        _feedback(_Haptic.medium, theme);
        widget.action?.onPressed();
      case 'C':
        _feedback(_Haptic.heavy, theme);
        _clearAll();
      case NumberPad.backspaceKey:
        _feedback(_Haptic.light, theme);
        _backspace();
      default:
        _feedback(_Haptic.light, theme);
        switch (widget._preset) {
          case _Preset.calculator:
            _calculatorInput(key);
          case _Preset.amount:
            _amountInput(key);
          default:
            _insert(key);
        }
    }
  }

  void _onBackspaceLongPress(NumberPadTheme theme) {
    _feedback(_Haptic.heavy, theme);
    _clearAll();
  }

  void _clearAll() {
    _justEvaluated = false;
    _setText('');
  }

  void _backspace() {
    final text = _text;
    if (text.isEmpty) return;
    if (widget._preset == _Preset.calculator &&
        text == NumberPad.calculatorErrorText) {
      _clearAll();
      return;
    }
    _justEvaluated = false;
    if (widget._preset == _Preset.amount) {
      final raw = _amountRaw(text);
      _setText(
        raw.isEmpty ? '' : _formatAmount(raw.substring(0, raw.length - 1)),
      );
      return;
    }
    _setText(text.substring(0, text.length - 1));
  }

  void _insert(String key) {
    final text = _text;
    if (text.length + key.length > widget.maxLength) return;

    var newText = text + key;
    if (key == '.') {
      if (text.contains('.')) return;
    } else if (_isDigits(key)) {
      final dot = text.indexOf('.');
      final maxDecimals = widget.maxDecimalPlaces;
      if (dot >= 0 &&
          maxDecimals != null &&
          text.length - dot - 1 + key.length > maxDecimals) {
        return;
      }
      if (!widget.allowLeadingZeros && (text.isEmpty || text == '0')) {
        final trimmed = key.replaceFirst(RegExp(r'^0+'), '');
        newText = trimmed.isEmpty ? '0' : trimmed;
        if (newText == text) return;
      }
    }

    final maxValue = widget.maxValue;
    if (maxValue != null) {
      final value = double.tryParse(newText);
      if (value != null && value > maxValue) return;
    }

    final formatters = widget.inputFormatters;
    if (formatters != null && formatters.isNotEmpty) {
      final oldValue = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      var value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
      for (final formatter in formatters) {
        value = formatter.formatEditUpdate(oldValue, value);
      }
      newText = value.text;
    }

    if (newText != text) _setText(newText);
  }

  // ---------------------------------------------------------------------------
  // Calculator
  // ---------------------------------------------------------------------------

  void _calculatorInput(String key) {
    var text = _text;
    final continuesResult =
        NumberPadCalculator.binaryOperators.contains(key) || key == '%';
    if (text == NumberPad.calculatorErrorText ||
        (_justEvaluated && !continuesResult)) {
      text = '';
    }
    _justEvaluated = false;

    if (key == '=') {
      _evaluate(text);
      return;
    }

    final last = text.isEmpty ? null : text[text.length - 1];
    var insertion = key;

    if (NumberPadCalculator.binaryOperators.contains(key)) {
      if (last == null) {
        if (key != '-') return;
      } else if (NumberPadCalculator.binaryOperators.contains(last)) {
        text = text.substring(0, text.length - 1);
        if (text.isEmpty && key != '-') {
          _setText('');
          return;
        }
      } else if (last == '√') {
        return;
      }
    } else if (key == '.') {
      final number = RegExp(r'[0-9.]*$').stringMatch(text) ?? '';
      if (number.contains('.')) return;
      if (number.isEmpty) insertion = '0.';
    } else if (key == '%') {
      if (last == null || !(_isDigits(last) || last == '.' || last == '%')) {
        return;
      }
    } else if (key != '√' && last == '%') {
      return;
    }

    if (text.length + insertion.length > widget.maxLength) return;
    _setText(text + insertion);
  }

  void _evaluate(String text) {
    final expression = text.replaceFirst(RegExp(r'[+\-×÷√]+$'), '');
    if (expression.isEmpty) {
      if (text != _text) _setText(text);
      return;
    }
    final result = NumberPadCalculator.evaluate(expression);
    _justEvaluated = true;
    if (result == null) {
      _setText(NumberPad.calculatorErrorText);
      return;
    }
    _setText(NumberPadCalculator.format(result));
    widget.onResult?.call(result);
  }

  // ---------------------------------------------------------------------------
  // Amount
  // ---------------------------------------------------------------------------

  /// Converts formatted amount text into a plain string such as `1234.5`.
  String _amountRaw(String text) {
    var raw = text;
    if (widget.groupSeparator.isNotEmpty) {
      raw = raw.replaceAll(widget.groupSeparator, '');
    }
    raw = raw.replaceAll(widget.decimalSeparator, '.');
    if (widget.centsFirst) {
      raw = raw.replaceAll('.', '').replaceFirst(RegExp(r'^0+'), '');
    }
    return raw;
  }

  double? _parseAmount(String raw) {
    if (raw.isEmpty) return null;
    if (widget.centsFirst) {
      final digits = int.tryParse(raw);
      if (digits == null) return null;
      return digits / math.pow(10, widget.decimalDigits);
    }
    return double.tryParse(raw.endsWith('.') ? '${raw}0' : raw);
  }

  String _formatAmount(String raw) {
    if (raw.isEmpty) return '';
    final decimals = widget.decimalDigits;
    String integerPart;
    String? fractionPart;
    if (widget.centsFirst) {
      final padded = raw.padLeft(decimals + 1, '0');
      integerPart = padded.substring(0, padded.length - decimals);
      fractionPart = decimals > 0
          ? padded.substring(padded.length - decimals)
          : null;
    } else {
      final dot = raw.indexOf('.');
      integerPart = dot >= 0 ? raw.substring(0, dot) : raw;
      fractionPart = dot >= 0 ? raw.substring(dot + 1) : null;
    }
    final grouped = _group(integerPart.isEmpty ? '0' : integerPart);
    return fractionPart == null
        ? grouped
        : '$grouped${widget.decimalSeparator}$fractionPart';
  }

  String _group(String digits) {
    final separator = widget.groupSeparator;
    if (separator.isEmpty || digits.length <= 3) return digits;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(separator);
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  void _amountInput(String key) {
    final raw = _amountRaw(_text);
    String newRaw;
    if (widget.centsFirst) {
      if (!_isDigits(key)) return;
      newRaw = (raw + key).replaceFirst(RegExp(r'^0+'), '');
      if (newRaw == raw || newRaw.length > widget.maxLength) return;
    } else if (key == '.') {
      if (raw.contains('.') || widget.decimalDigits == 0) return;
      newRaw = raw.isEmpty ? '0.' : '$raw.';
    } else if (_isDigits(key)) {
      final dot = raw.indexOf('.');
      if (dot >= 0 &&
          raw.length - dot - 1 + key.length > widget.decimalDigits) {
        return;
      }
      if (raw.replaceAll('.', '').length + key.length > widget.maxLength) {
        return;
      }
      newRaw = raw == '0' ? key : raw + key;
      if (dot < 0) newRaw = newRaw.replaceFirst(RegExp(r'^0+(?=\d)'), '');
      if (newRaw == raw) return;
    } else {
      return;
    }

    final maxValue = widget.maxValue;
    final value = _parseAmount(newRaw);
    if (maxValue != null && value != null && value > maxValue) return;

    _setText(_formatAmount(newRaw));
  }

  // ---------------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------------

  List<List<String>> _layout() {
    switch (widget._preset) {
      case _Preset.phoneDialer:
        return const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['*', '0', '#'],
          ['', '', NumberPad.backspaceKey],
        ];
      case _Preset.calculator:
        return const [
          ['7', '8', '9', '÷'],
          ['4', '5', '6', '×'],
          ['1', '2', '3', '-'],
          ['0', '.', '=', '+'],
          ['√', '%', 'C', NumberPad.backspaceKey],
        ];
      case _Preset.custom:
        return widget.customLayout!;
      default:
        final String? decimalKey;
        if (widget._preset == _Preset.amount && widget.centsFirst) {
          decimalKey = '00';
        } else {
          decimalKey = widget.showDecimalPoint ? '.' : null;
        }
        final hasAction = widget.action != null;
        final extras = [
          ?decimalKey,
          if (hasAction) NumberPad.actionKey,
          if (widget.showOkButton) NumberPad.okKey,
        ];
        final bottomLeft = extras.isEmpty ? '' : extras.removeAt(0);
        return [
          const ['1', '2', '3'],
          const ['4', '5', '6'],
          const ['7', '8', '9'],
          [bottomLeft, '0', NumberPad.backspaceKey],
          if (extras.isNotEmpty)
            [
              extras.contains(NumberPad.actionKey) ? NumberPad.actionKey : '',
              '',
              extras.contains(NumberPad.okKey) ? NumberPad.okKey : '',
            ],
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final materialTheme = Theme.of(context);
    final theme = NumberPadTheme.fromColorScheme(
      materialTheme.colorScheme,
    ).merge(materialTheme.extension<NumberPadTheme>()).merge(widget.theme);

    return Column(
      children: [
        for (final row in _layout())
          Expanded(
            child: Row(
              // Keypads keep 1-2-3 ordering even in right-to-left locales.
              textDirection: TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [for (final key in row) _buildKey(key, theme)],
            ),
          ),
      ],
    );
  }

  Widget _buildKey(String key, NumberPadTheme theme) {
    final Widget content;
    if (key.isEmpty) {
      content = const SizedBox.shrink();
    } else {
      final hasCustomHandler =
          widget.customButtonHandlers?.containsKey(key) ?? false;
      final isBackspace = key == NumberPad.backspaceKey && !hasCustomHandler;
      content = Padding(
        padding: EdgeInsets.all(theme.buttonSpacing ?? 0),
        child: _NumberPadKey(
          theme: theme,
          enabled: _isKeyEnabled(key),
          semanticLabel: _semanticLabel(key),
          onTap: () => _onKeyTap(key, theme),
          onLongPress: isBackspace ? () => _onBackspaceLongPress(theme) : null,
          child: _buildKeyLabel(key, theme, hasCustomHandler),
        ),
      );
    }
    return Expanded(
      child: AspectRatio(aspectRatio: widget.buttonAspectRatio, child: content),
    );
  }

  bool _isKeyEnabled(String key) {
    if (!widget.enabled || widget.disabledKeys.contains(key)) return false;
    if (key == NumberPad.okKey &&
        !(widget.customButtonHandlers?.containsKey(key) ?? false)) {
      return widget.canSubmit?.call(_text) ?? true;
    }
    if (key == NumberPad.actionKey) return widget.action != null;
    return true;
  }

  String _displayText(String key) {
    if (key == '.' && widget._preset == _Preset.amount) {
      return widget.decimalSeparator;
    }
    return key;
  }

  String _semanticLabel(String key) {
    final override = widget.semanticLabels?[key];
    if (override != null) return override;
    if (key == NumberPad.actionKey) {
      return widget.action?.semanticLabel ?? 'Action';
    }
    return _defaultSemanticLabels[key] ?? _displayText(key);
  }

  Color? _keyColor(String key, NumberPadTheme theme) {
    final override = theme.buttonColors?[key];
    if (override != null) return override;
    switch (key) {
      case NumberPad.backspaceKey:
        return theme.backspaceColor ?? theme.numberColor;
      case NumberPad.okKey:
        return theme.okColor ?? theme.numberColor;
      case NumberPad.actionKey:
        return theme.actionColor ?? theme.numberColor;
      case '=':
        return theme.equalsColor ?? theme.numberColor;
      case 'C':
        return theme.clearColor ?? theme.numberColor;
      default:
        if (_operatorKeys.contains(key)) {
          return theme.operatorColor ?? theme.numberColor;
        }
        return theme.numberColor;
    }
  }

  Widget _buildKeyLabel(
    String key,
    NumberPadTheme theme,
    bool hasCustomHandler,
  ) {
    final color = _keyColor(key, theme);
    final iconSize = theme.buttonFontSizes?[key] ?? theme.iconSize;
    if (!hasCustomHandler) {
      switch (key) {
        case NumberPad.backspaceKey:
          return Icon(Icons.backspace, color: color, size: iconSize);
        case NumberPad.okKey:
          return Icon(Icons.done, color: color, size: iconSize);
        case NumberPad.actionKey:
          return IconTheme.merge(
            data: IconThemeData(color: color, size: iconSize),
            child: widget.action?.icon ?? const SizedBox.shrink(),
          );
      }
    }
    final baseSize = theme.fontSize ?? 24;
    return Text(
      _displayText(key),
      style: TextStyle(
        fontSize:
            theme.buttonFontSizes?[key] ??
            (_symbolKeys.contains(key) ? baseSize * 0.9 : baseSize),
        fontWeight:
            theme.buttonFontWeights?[key] ??
            theme.fontWeight ??
            FontWeight.bold,
        color: color,
      ),
    );
  }

  static bool _isDigits(String key) => RegExp(r'^[0-9]+$').hasMatch(key);
}

/// A single number pad button: handles ink, press animation, disabled state
/// and accessibility.
class _NumberPadKey extends StatefulWidget {
  const _NumberPadKey({
    required this.theme,
    required this.enabled,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
    this.onLongPress,
  });

  final NumberPadTheme theme;
  final bool enabled;
  final String semanticLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  @override
  State<_NumberPadKey> createState() => _NumberPadKeyState();
}

class _NumberPadKeyState extends State<_NumberPadKey> {
  bool _pressed = false;

  ShapeBorder _shape() {
    final theme = widget.theme;
    final side = theme.buttonBorderSide ?? BorderSide.none;
    switch (theme.buttonShape ?? NumberPadButtonShape.roundedRectangle) {
      case NumberPadButtonShape.rectangle:
        return RoundedRectangleBorder(side: side);
      case NumberPadButtonShape.circle:
        return CircleBorder(side: side);
      case NumberPadButtonShape.roundedRectangle:
        return RoundedRectangleBorder(
          side: side,
          borderRadius: BorderRadius.circular(theme.borderRadius ?? 8),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final shape = _shape();
    final enabled = widget.enabled;
    final scale = theme.enablePressAnimation && _pressed ? 0.92 : 1.0;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      excludeSemantics: true,
      onTap: enabled ? widget.onTap : null,
      onLongPress: enabled ? widget.onLongPress : null,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 90),
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.38,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: theme.buttonBackgroundColor ?? Colors.transparent,
            shape: shape,
            elevation: theme.buttonElevation ?? 0,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: shape,
              splashColor: theme.splashColor,
              enableFeedback: false,
              onTap: enabled ? widget.onTap : null,
              onLongPress: enabled ? widget.onLongPress : null,
              onHighlightChanged: (value) => setState(() => _pressed = value),
              child: Center(
                child: FittedBox(fit: BoxFit.scaleDown, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
