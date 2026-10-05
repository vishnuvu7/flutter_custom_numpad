import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The outline shape used for number pad buttons.
enum NumberPadButtonShape {
  /// Square corners.
  rectangle,

  /// Rounded corners using [NumberPadTheme.borderRadius].
  roundedRectangle,

  /// A circle inscribed in the button's area.
  circle,
}

/// Theme configuration for the number pad widget.
///
/// Can be passed directly to `NumberPad.theme`, or registered app-wide with
/// `ThemeData(extensions: [NumberPadTheme(...)])`. Any field left `null`
/// falls back to a value derived from the ambient [ColorScheme].
@immutable
class NumberPadTheme extends ThemeExtension<NumberPadTheme> {
  /// The color of the number buttons text.
  final Color? numberColor;

  /// The color of the backspace button icon.
  final Color? backspaceColor;

  /// The color of the OK button icon.
  final Color? okColor;

  /// The color of operator buttons (`+`, `-`, `×`, `÷`, `%`, `√`).
  final Color? operatorColor;

  /// The color of the `=` button.
  final Color? equalsColor;

  /// The color of the `C` (clear) button.
  final Color? clearColor;

  /// The color of the action button icon (e.g. biometric).
  final Color? actionColor;

  /// The background color of the buttons.
  final Color? buttonBackgroundColor;

  /// The ink splash color shown when a button is pressed.
  final Color? splashColor;

  /// The font size of the number buttons.
  final double? fontSize;

  /// The font weight of the number buttons.
  final FontWeight? fontWeight;

  /// The size of icon buttons (backspace, OK, action).
  final double? iconSize;

  /// The border radius of the buttons.
  final double? borderRadius;

  /// The outline shape of the buttons.
  final NumberPadButtonShape? buttonShape;

  /// An optional border drawn around each button.
  final BorderSide? buttonBorderSide;

  /// The elevation (shadow) of each button.
  final double? buttonElevation;

  /// The empty space around each button.
  final double? buttonSpacing;

  /// Whether to enable haptic feedback.
  final bool enableHapticFeedback;

  /// Whether to play the system click sound on key press.
  final bool enableSoundFeedback;

  /// Whether buttons shrink slightly while pressed.
  final bool enablePressAnimation;

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
    this.operatorColor,
    this.equalsColor,
    this.clearColor,
    this.actionColor,
    this.buttonBackgroundColor,
    this.splashColor,
    this.fontSize,
    this.fontWeight,
    this.iconSize,
    this.borderRadius,
    this.buttonShape,
    this.buttonBorderSide,
    this.buttonElevation,
    this.buttonSpacing,
    this.enableHapticFeedback = true,
    this.enableSoundFeedback = false,
    this.enablePressAnimation = true,
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
      operatorColor: Colors.blue,
      equalsColor: Colors.green,
      clearColor: Colors.red,
      actionColor: Colors.black87,
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
      operatorColor: Colors.lightBlueAccent,
      equalsColor: Colors.lightGreenAccent,
      clearColor: Colors.redAccent,
      actionColor: Colors.white,
      buttonBackgroundColor: Colors.transparent,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      borderRadius: 8.0,
    );
  }

  /// Creates a theme whose colors follow [colorScheme], so the number pad
  /// matches the app in both light and dark mode.
  factory NumberPadTheme.fromColorScheme(ColorScheme colorScheme) {
    return NumberPadTheme(
      numberColor: colorScheme.onSurface,
      backspaceColor: colorScheme.onSurface,
      okColor: colorScheme.primary,
      operatorColor: colorScheme.primary,
      equalsColor: colorScheme.tertiary,
      clearColor: colorScheme.error,
      actionColor: colorScheme.primary,
      buttonBackgroundColor: Colors.transparent,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      borderRadius: 8.0,
    );
  }

  /// Returns a copy of this theme where every non-null field of [other]
  /// replaces the corresponding field here. Boolean flags always come from
  /// [other].
  NumberPadTheme merge(NumberPadTheme? other) {
    if (other == null) return this;
    return NumberPadTheme(
      numberColor: other.numberColor ?? numberColor,
      backspaceColor: other.backspaceColor ?? backspaceColor,
      okColor: other.okColor ?? okColor,
      operatorColor: other.operatorColor ?? operatorColor,
      equalsColor: other.equalsColor ?? equalsColor,
      clearColor: other.clearColor ?? clearColor,
      actionColor: other.actionColor ?? actionColor,
      buttonBackgroundColor:
          other.buttonBackgroundColor ?? buttonBackgroundColor,
      splashColor: other.splashColor ?? splashColor,
      fontSize: other.fontSize ?? fontSize,
      fontWeight: other.fontWeight ?? fontWeight,
      iconSize: other.iconSize ?? iconSize,
      borderRadius: other.borderRadius ?? borderRadius,
      buttonShape: other.buttonShape ?? buttonShape,
      buttonBorderSide: other.buttonBorderSide ?? buttonBorderSide,
      buttonElevation: other.buttonElevation ?? buttonElevation,
      buttonSpacing: other.buttonSpacing ?? buttonSpacing,
      enableHapticFeedback: other.enableHapticFeedback,
      enableSoundFeedback: other.enableSoundFeedback,
      enablePressAnimation: other.enablePressAnimation,
      buttonColors: other.buttonColors ?? buttonColors,
      buttonFontSizes: other.buttonFontSizes ?? buttonFontSizes,
      buttonFontWeights: other.buttonFontWeights ?? buttonFontWeights,
    );
  }

  /// Creates a copy of this theme with the given fields replaced by new values.
  @override
  NumberPadTheme copyWith({
    Color? numberColor,
    Color? backspaceColor,
    Color? okColor,
    Color? operatorColor,
    Color? equalsColor,
    Color? clearColor,
    Color? actionColor,
    Color? buttonBackgroundColor,
    Color? splashColor,
    double? fontSize,
    FontWeight? fontWeight,
    double? iconSize,
    double? borderRadius,
    NumberPadButtonShape? buttonShape,
    BorderSide? buttonBorderSide,
    double? buttonElevation,
    double? buttonSpacing,
    bool? enableHapticFeedback,
    bool? enableSoundFeedback,
    bool? enablePressAnimation,
    Map<String, Color>? buttonColors,
    Map<String, double>? buttonFontSizes,
    Map<String, FontWeight>? buttonFontWeights,
  }) {
    return NumberPadTheme(
      numberColor: numberColor ?? this.numberColor,
      backspaceColor: backspaceColor ?? this.backspaceColor,
      okColor: okColor ?? this.okColor,
      operatorColor: operatorColor ?? this.operatorColor,
      equalsColor: equalsColor ?? this.equalsColor,
      clearColor: clearColor ?? this.clearColor,
      actionColor: actionColor ?? this.actionColor,
      buttonBackgroundColor:
          buttonBackgroundColor ?? this.buttonBackgroundColor,
      splashColor: splashColor ?? this.splashColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      iconSize: iconSize ?? this.iconSize,
      borderRadius: borderRadius ?? this.borderRadius,
      buttonShape: buttonShape ?? this.buttonShape,
      buttonBorderSide: buttonBorderSide ?? this.buttonBorderSide,
      buttonElevation: buttonElevation ?? this.buttonElevation,
      buttonSpacing: buttonSpacing ?? this.buttonSpacing,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableSoundFeedback: enableSoundFeedback ?? this.enableSoundFeedback,
      enablePressAnimation: enablePressAnimation ?? this.enablePressAnimation,
      buttonColors: buttonColors ?? this.buttonColors,
      buttonFontSizes: buttonFontSizes ?? this.buttonFontSizes,
      buttonFontWeights: buttonFontWeights ?? this.buttonFontWeights,
    );
  }

  @override
  NumberPadTheme lerp(covariant NumberPadTheme? other, double t) {
    if (other == null) return this;
    final pickOther = t >= 0.5;
    BorderSide? side;
    if (buttonBorderSide != null && other.buttonBorderSide != null) {
      side = BorderSide.lerp(buttonBorderSide!, other.buttonBorderSide!, t);
    } else {
      side = pickOther ? other.buttonBorderSide : buttonBorderSide;
    }
    return NumberPadTheme(
      numberColor: Color.lerp(numberColor, other.numberColor, t),
      backspaceColor: Color.lerp(backspaceColor, other.backspaceColor, t),
      okColor: Color.lerp(okColor, other.okColor, t),
      operatorColor: Color.lerp(operatorColor, other.operatorColor, t),
      equalsColor: Color.lerp(equalsColor, other.equalsColor, t),
      clearColor: Color.lerp(clearColor, other.clearColor, t),
      actionColor: Color.lerp(actionColor, other.actionColor, t),
      buttonBackgroundColor: Color.lerp(
        buttonBackgroundColor,
        other.buttonBackgroundColor,
        t,
      ),
      splashColor: Color.lerp(splashColor, other.splashColor, t),
      fontSize: lerpDouble(fontSize, other.fontSize, t),
      fontWeight: FontWeight.lerp(fontWeight, other.fontWeight, t),
      iconSize: lerpDouble(iconSize, other.iconSize, t),
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t),
      buttonShape: pickOther ? other.buttonShape : buttonShape,
      buttonBorderSide: side,
      buttonElevation: lerpDouble(buttonElevation, other.buttonElevation, t),
      buttonSpacing: lerpDouble(buttonSpacing, other.buttonSpacing, t),
      enableHapticFeedback: pickOther
          ? other.enableHapticFeedback
          : enableHapticFeedback,
      enableSoundFeedback: pickOther
          ? other.enableSoundFeedback
          : enableSoundFeedback,
      enablePressAnimation: pickOther
          ? other.enablePressAnimation
          : enablePressAnimation,
      buttonColors: pickOther ? other.buttonColors : buttonColors,
      buttonFontSizes: pickOther ? other.buttonFontSizes : buttonFontSizes,
      buttonFontWeights: pickOther
          ? other.buttonFontWeights
          : buttonFontWeights,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NumberPadTheme &&
        other.numberColor == numberColor &&
        other.backspaceColor == backspaceColor &&
        other.okColor == okColor &&
        other.operatorColor == operatorColor &&
        other.equalsColor == equalsColor &&
        other.clearColor == clearColor &&
        other.actionColor == actionColor &&
        other.buttonBackgroundColor == buttonBackgroundColor &&
        other.splashColor == splashColor &&
        other.fontSize == fontSize &&
        other.fontWeight == fontWeight &&
        other.iconSize == iconSize &&
        other.borderRadius == borderRadius &&
        other.buttonShape == buttonShape &&
        other.buttonBorderSide == buttonBorderSide &&
        other.buttonElevation == buttonElevation &&
        other.buttonSpacing == buttonSpacing &&
        other.enableHapticFeedback == enableHapticFeedback &&
        other.enableSoundFeedback == enableSoundFeedback &&
        other.enablePressAnimation == enablePressAnimation &&
        mapEquals(other.buttonColors, buttonColors) &&
        mapEquals(other.buttonFontSizes, buttonFontSizes) &&
        mapEquals(other.buttonFontWeights, buttonFontWeights);
  }

  @override
  int get hashCode => Object.hashAll([
    numberColor,
    backspaceColor,
    okColor,
    operatorColor,
    equalsColor,
    clearColor,
    actionColor,
    buttonBackgroundColor,
    splashColor,
    fontSize,
    fontWeight,
    iconSize,
    borderRadius,
    buttonShape,
    buttonBorderSide,
    buttonElevation,
    buttonSpacing,
    enableHapticFeedback,
    enableSoundFeedback,
    enablePressAnimation,
    _mapHash(buttonColors),
    _mapHash(buttonFontSizes),
    _mapHash(buttonFontWeights),
  ]);

  static int? _mapHash(Map<String, Object>? map) {
    if (map == null) return null;
    return Object.hashAllUnordered(
      map.entries.map((e) => Object.hash(e.key, e.value)),
    );
  }
}
