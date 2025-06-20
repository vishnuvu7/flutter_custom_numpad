import 'package:flutter/material.dart';

/// Theme configuration for the number pad widget.
class NumberPadTheme {
  /// The color of the number buttons text.
  final Color? numberColor;

  /// The color of the backspace button icon.
  final Color? backspaceColor;

  /// The color of the OK button icon.
  final Color? okColor;

  /// The background color of the buttons.
  final Color? buttonBackgroundColor;

  /// The font size of the number buttons.
  final double? fontSize;

  /// The font weight of the number buttons.
  final FontWeight? fontWeight;

  /// The border radius of the buttons.
  final double? borderRadius;

  /// Whether to enable haptic feedback.
  final bool enableHapticFeedback;

  /// Custom colors for specific buttons.
  final Map<String, Color>? buttonColors;

  /// Custom font sizes for specific buttons.
  final Map<String, double>? buttonFontSizes;

  /// Custom font weights for specific buttons.
  final Map<String, FontWeight>? buttonFontWeights;

  const NumberPadTheme({
    this.numberColor,
    this.backspaceColor,
    this.okColor,
    this.buttonBackgroundColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.enableHapticFeedback = true,
    this.buttonColors,
    this.buttonFontSizes,
    this.buttonFontWeights,
  });

  /// Creates a light theme for the number pad.
  factory NumberPadTheme.light() {
    return const NumberPadTheme(
      numberColor: Colors.black87,
      backspaceColor: Colors.black87,
      okColor: Colors.black87,
      buttonBackgroundColor: Colors.transparent,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      borderRadius: 8.0,
    );
  }

  /// Creates a dark theme for the number pad.
  factory NumberPadTheme.dark() {
    return const NumberPadTheme(
      numberColor: Colors.white,
      backspaceColor: Colors.white,
      okColor: Colors.white,
      buttonBackgroundColor: Colors.transparent,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      borderRadius: 8.0,
    );
  }

  /// Creates a copy of this theme with the given fields replaced by new values.
  NumberPadTheme copyWith({
    Color? numberColor,
    Color? backspaceColor,
    Color? okColor,
    Color? buttonBackgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    double? borderRadius,
    bool? enableHapticFeedback,
    Map<String, Color>? buttonColors,
    Map<String, double>? buttonFontSizes,
    Map<String, FontWeight>? buttonFontWeights,
  }) {
    return NumberPadTheme(
      numberColor: numberColor ?? this.numberColor,
      backspaceColor: backspaceColor ?? this.backspaceColor,
      okColor: okColor ?? this.okColor,
      buttonBackgroundColor:
          buttonBackgroundColor ?? this.buttonBackgroundColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      borderRadius: borderRadius ?? this.borderRadius,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      buttonColors: buttonColors ?? this.buttonColors,
      buttonFontSizes: buttonFontSizes ?? this.buttonFontSizes,
      buttonFontWeights: buttonFontWeights ?? this.buttonFontWeights,
    );
  }

  /// Gets the color for a specific button.
  Color? getButtonColor(String button) {
    return buttonColors?[button] ?? numberColor;
  }

  /// Gets the font size for a specific button.
  double? getButtonFontSize(String button) {
    return buttonFontSizes?[button] ?? fontSize;
  }

  /// Gets the font weight for a specific button.
  FontWeight? getButtonFontWeight(String button) {
    return buttonFontWeights?[button] ?? fontWeight;
  }
}
