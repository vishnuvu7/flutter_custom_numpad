# Changelog

## 0.1.0

### New features
* `PinDisplay` widget: dot, box or underline cells that track a PIN/OTP,
  with error state, `onCompleted` and screen-reader progress.
* `NumberPad.calculator()` now evaluates expressions with operator
  precedence, `%` and `√`. Added `onResult` and the public
  `NumberPadCalculator.evaluate()` / `format()` helpers.
* `NumberPad.amount()`: currency entry with cents-first ("cash register")
  or decimal mode, configurable decimal/group separators, a `00` key,
  `maxValue` and `onAmountChanged`.
* Input validation: `inputFormatters`, `maxDecimalPlaces`, `maxValue`,
  `allowLeadingZeros`, `canSubmit` (enables OK only for valid input),
  `enabled` and `disabledKeys`.
* `NumberPadAction` for an extra button such as biometric unlock.
* `NumberPadTheme` is now a `ThemeExtension` and defaults to the app's
  `ColorScheme`, so the pad follows light/dark mode automatically. Added
  `NumberPadTheme.fromColorScheme()`, `merge()`, `lerp()` and value equality.
* New styling options: `buttonShape` (rectangle, rounded, circle),
  `buttonBorderSide`, `buttonElevation`, `buttonSpacing`, `splashColor`,
  `iconSize`, `operatorColor`, `equalsColor`, `clearColor`, `actionColor`,
  `enablePressAnimation` and `enableSoundFeedback`.
* Accessibility: every key has a semantic label (overridable with
  `semanticLabels`), labels scale down instead of overflowing at large text
  sizes, and the keypad keeps 1-2-3 order in right-to-left locales.

### Bug fixes
* `backspaceColor`, `okColor` and the calculator's colored symbols were
  ignored whenever `numberColor` was set.
* The OK button was hidden when the decimal point was also shown.
* Multiple decimal points could be entered.
* Special keys triggered haptic feedback twice.
* Long-pressing OK cleared the input.

### Breaking changes
* Without an explicit `theme`, colors now come from the app's `ColorScheme`
  instead of `NumberPadTheme.light()`. Pass `theme: NumberPadTheme.light()`
  to keep the old look.
* The calculator's `=` evaluates instead of appending `=`, and invalid
  operator sequences are rejected.
* `NumberPad.numeric()` strips redundant leading zeros by default
  (`allowLeadingZeros: false`).
* `onChanged` is now typed `ValueChanged<String>?`.
* Minimum Flutter version is 3.32.

## 0.0.1

* Initial release of flutter_custom_numpad package
* Added NumberPad widget with customizable themes
* Added NumberPadTheme class with light and dark presets
* Support for decimal point input
* Support for backspace functionality with long press to clear all
* Optional OK button with callback
* Configurable max length for input
* Haptic feedback support
* Added preset configurations:
  - NumberPad.phoneDialer() - Optimized for phone number input (includes #, *, backspace buttons)
  - NumberPad.calculator() - Optimized for calculator input (includes +, -, ×, ÷, =, %, √, C buttons)
  - NumberPad.otp() - Optimized for OTP/PIN input
  - NumberPad.numeric() - General purpose numeric input
  - NumberPad.custom() - Fully customizable layout with custom button handlers
* Enhanced theme customization:
  - Individual button colors
  - Individual button font sizes
  - Individual button font weights
  - Helper methods for button-specific styling
* Comprehensive test coverage
* Example app demonstrating all features
