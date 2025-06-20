import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'number_pad_theme.dart';

/// A customizable number pad widget for Flutter applications.
///
/// This widget provides a number pad with digits 0-9, decimal point,
/// backspace functionality, and optional OK button.
class NumberPad extends StatelessWidget {
  /// The text controller to manage the input text.
  final TextEditingController controller;

  /// Maximum length of the input text.
  final int maxLength;

  /// Callback function called when the text changes.
  final Function(String)? onChanged;

  /// Callback function called when the OK button is pressed.
  final VoidCallback? onOkPressed;

  /// Whether to show the OK button.
  final bool showOkButton;

  /// Whether to show the decimal point button.
  final bool showDecimalPoint;

  /// The theme configuration for the number pad.
  final NumberPadTheme? theme;

  /// The aspect ratio for the buttons.
  final double buttonAspectRatio;

  /// The type of number pad preset (for internal use).
  final String? _presetType;

  /// Custom layout configuration (for custom preset).
  final List<List<String>>? customLayout;

  /// Custom button handlers (for custom preset).
  final Map<String, VoidCallback>? customButtonHandlers;

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
  }) : _presetType = null,
       customLayout = null,
       customButtonHandlers = null;

  /// Creates a number pad configured for phone dialer.
  ///
  /// Features:
  /// - No decimal point
  /// - No OK button
  /// - No max length limit
  /// - Optimized for phone numbers
  /// - Includes +, #, * buttons
  factory NumberPad.phoneDialer({
    Key? key,
    required TextEditingController controller,
    Function(String)? onChanged,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
  }) {
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: 15, // Standard phone number length
      onChanged: onChanged,
      showOkButton: false,
      showDecimalPoint: false,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      presetType: 'phoneDialer',
    );
  }

  /// Creates a number pad configured for calculator.
  ///
  /// Features:
  /// - Includes decimal point
  /// - No OK button
  /// - No max length limit
  /// - Optimized for calculations
  /// - Includes +, -, ×, ÷, =, %, √ buttons
  factory NumberPad.calculator({
    Key? key,
    required TextEditingController controller,
    Function(String)? onChanged,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
  }) {
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: 20, // Allow longer numbers for calculations
      onChanged: onChanged,
      showOkButton: false,
      showDecimalPoint: true,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      presetType: 'calculator',
    );
  }

  /// Creates a number pad configured for OTP input.
  ///
  /// Features:
  /// - No decimal point
  /// - No OK button
  /// - Limited to 6 digits (standard OTP length)
  /// - Optimized for PIN/OTP entry
  factory NumberPad.otp({
    Key? key,
    required TextEditingController controller,
    Function(String)? onChanged,
    VoidCallback? onOkPressed,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
  }) {
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: 6, // Standard OTP length
      onChanged: onChanged,
      onOkPressed: onOkPressed,
      showOkButton: true,
      showDecimalPoint: false,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      presetType: 'otp',
    );
  }

  /// Creates a number pad configured for general numeric input.
  ///
  /// Features:
  /// - Includes decimal point
  /// - Optional OK button
  /// - Configurable max length
  /// - General purpose numeric input
  factory NumberPad.numeric({
    Key? key,
    required TextEditingController controller,
    int maxLength = 10,
    Function(String)? onChanged,
    VoidCallback? onOkPressed,
    bool showOkButton = false,
    bool showDecimalPoint = true,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
  }) {
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      onOkPressed: onOkPressed,
      showOkButton: showOkButton,
      showDecimalPoint: showDecimalPoint,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      presetType: 'numeric',
    );
  }

  /// Creates a number pad with custom layout.
  ///
  /// Features:
  /// - Fully customizable button layout
  /// - Custom button handlers
  /// - Flexible configuration
  factory NumberPad.custom({
    Key? key,
    required TextEditingController controller,
    required List<List<String>> layout,
    Map<String, VoidCallback>? customButtonHandlers,
    int maxLength = 10,
    Function(String)? onChanged,
    NumberPadTheme? theme,
    double buttonAspectRatio = 1.5,
  }) {
    return NumberPad._(
      key: key,
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      theme: theme,
      buttonAspectRatio: buttonAspectRatio,
      presetType: 'custom',
      customLayout: layout,
      customButtonHandlers: customButtonHandlers,
    );
  }

  /// Private constructor for preset configurations
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
    required String presetType,
    this.customLayout,
    this.customButtonHandlers,
  }) : _presetType = presetType;

  void _addNumber(String number) {
    if (controller.text.length < maxLength) {
      if (theme?.enableHapticFeedback ?? true) {
        HapticFeedback.lightImpact();
      }
      controller.text += number;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
      onChanged?.call(controller.text);
    }
  }

  void _backspace() {
    if (controller.text.isNotEmpty) {
      if (theme?.enableHapticFeedback ?? true) {
        HapticFeedback.lightImpact();
      }
      controller.text = controller.text.substring(
        0,
        controller.text.length - 1,
      );
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
      onChanged?.call(controller.text);
    }
  }

  void _clearAll() {
    if (theme?.enableHapticFeedback ?? true) {
      HapticFeedback.heavyImpact();
    }
    controller.clear();
    onChanged?.call('');
  }

  void _okPressed() {
    if (theme?.enableHapticFeedback ?? true) {
      HapticFeedback.mediumImpact();
    }
    onOkPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = theme ?? NumberPadTheme.light();

    switch (_presetType) {
      case 'phoneDialer':
        return Column(
          children: [
            _buildRow(['1', '2', '3'], currentTheme),
            _buildRow(['4', '5', '6'], currentTheme),
            _buildRow(['7', '8', '9'], currentTheme),
            _buildRow(['*', '0', '#'], currentTheme),
            _buildRow(['', '', 'backspace'], currentTheme),
          ],
        );
      case 'calculator':
        return Column(
          children: [
            _buildRow(['7', '8', '9', '÷'], currentTheme),
            _buildRow(['4', '5', '6', '×'], currentTheme),
            _buildRow(['1', '2', '3', '-'], currentTheme),
            _buildRow(['0', '.', '=', '+'], currentTheme),
            _buildRow(['√', '%', 'C', 'backspace'], currentTheme),
          ],
        );
      case 'custom':
        return Column(
          children: customLayout!
              .map((row) => _buildCustomRow(row, currentTheme))
              .toList(),
        );
      default:
        return Column(
          children: [
            _buildRow(['1', '2', '3'], currentTheme),
            _buildRow(['4', '5', '6'], currentTheme),
            _buildRow(['7', '8', '9'], currentTheme),
            _buildRow([
              showDecimalPoint
                  ? '.'
                  : showOkButton
                  ? 'OK'
                  : '',
              '0',
              'backspace',
            ], currentTheme),
            // if (showOkButton) _buildRow(['', '', 'OK'], currentTheme),
          ],
        );
    }
  }

  Widget _buildRow(List<String> buttons, NumberPadTheme theme) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons.map((button) => _buildButton(button, theme)).toList(),
      ),
    );
  }

  Widget _buildButton(String button, NumberPadTheme theme) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: buttonAspectRatio,
        child: button.isEmpty
            ? Container()
            : button == 'backspace'
            ? GestureDetector(
                onTap: _backspace,
                onLongPress: _clearAll,
                child: Container(
                  color: theme.buttonBackgroundColor ?? Colors.transparent,
                  child: Center(
                    child: Icon(
                      Icons.backspace,
                      color:
                          theme.getButtonColor('backspace') ??
                          theme.backspaceColor ??
                          Colors.black87,
                    ),
                  ),
                ),
              )
            : button == "OK"
            ? GestureDetector(
                onTap: _okPressed,
                onLongPress: _clearAll,
                child: Container(
                  color: theme.buttonBackgroundColor ?? Colors.transparent,
                  child: Center(
                    child: Icon(
                      Icons.done,
                      color:
                          theme.getButtonColor('OK') ??
                          theme.okColor ??
                          Colors.black87,
                    ),
                  ),
                ),
              )
            : _isSpecialButton(button)
            ? _buildSpecialButton(button, theme)
            : TextButton(
                onPressed: () => _addNumber(button),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      theme.borderRadius ?? 8,
                    ),
                  ),
                ),
                child: Text(
                  button,
                  style: TextStyle(
                    fontSize:
                        theme.getButtonFontSize(button) ?? theme.fontSize ?? 24,
                    fontWeight:
                        theme.getButtonFontWeight(button) ??
                        theme.fontWeight ??
                        FontWeight.bold,
                    color:
                        theme.getButtonColor(button) ??
                        theme.numberColor ??
                        Colors.black87,
                  ),
                ),
              ),
      ),
    );
  }

  bool _isSpecialButton(String button) {
    return ['+', '-', '×', '÷', '=', '%', '√', 'C', '*', '#'].contains(button);
  }

  Widget _buildSpecialButton(String button, NumberPadTheme theme) {
    return GestureDetector(
      onTap: () => _handleSpecialButton(button),
      child: Container(
        color: theme.buttonBackgroundColor ?? Colors.transparent,
        child: Center(
          child: Text(
            button,
            style: TextStyle(
              fontSize:
                  theme.getButtonFontSize(button) ??
                  (theme.fontSize ?? 24) * 0.9,
              fontWeight:
                  theme.getButtonFontWeight(button) ??
                  theme.fontWeight ??
                  FontWeight.bold,
              color: _getSpecialButtonColor(button, theme),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSpecialButtonColor(String button, NumberPadTheme theme) {
    // First check if there's a custom color for this button
    final customColor = theme.getButtonColor(button);
    if (customColor != null) {
      return customColor;
    }

    // Fall back to default special button colors
    switch (button) {
      case '=':
        return Colors.green;
      case 'C':
        return Colors.red;
      case '+':
      case '-':
      case '×':
      case '÷':
      case '%':
      case '√':
        return Colors.blue;
      case '*':
      case '#':
        return theme.numberColor ?? Colors.black87;
      default:
        return theme.numberColor ?? Colors.black87;
    }
  }

  void _handleSpecialButton(String button) {
    if (theme?.enableHapticFeedback ?? true) {
      HapticFeedback.lightImpact();
    }

    switch (button) {
      case 'C':
        _clearAll();
        break;
      case '*':
      case '#':
        _addNumber(button);
        break;
      default:
        // For calculator operations, you might want to handle them differently
        // For now, just add them to the text
        _addNumber(button);
        break;
    }
  }

  Widget _buildCustomRow(List<String> buttons, NumberPadTheme theme) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons
            .map((button) => _buildCustomButton(button, theme))
            .toList(),
      ),
    );
  }

  Widget _buildCustomButton(String button, NumberPadTheme theme) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: buttonAspectRatio,
        child: button.isEmpty
            ? Container()
            : customButtonHandlers?.containsKey(button) == true
            ? _buildCustomHandlerButton(button, theme)
            : _buildButton(button, theme),
      ),
    );
  }

  Widget _buildCustomHandlerButton(String button, NumberPadTheme theme) {
    return GestureDetector(
      onTap: () {
        if (theme.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        customButtonHandlers![button]!();
      },
      child: Container(
        color: theme.buttonBackgroundColor ?? Colors.transparent,
        child: Center(
          child: Text(
            button,
            style: TextStyle(
              fontSize: theme.getButtonFontSize(button) ?? theme.fontSize ?? 24,
              fontWeight:
                  theme.getButtonFontWeight(button) ??
                  theme.fontWeight ??
                  FontWeight.bold,
              color:
                  theme.getButtonColor(button) ??
                  theme.numberColor ??
                  Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
