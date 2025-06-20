# Changelog

## 0.0.1

* Initial release of flutter_numpad package
* Added NumberPad widget with customizable themes
* Added NumberPadTheme class with light and dark presets
* Support for decimal point input
* Support for backspace functionality with long press to clear all
* Optional OK button with callback
* Configurable max length for input
* Haptic feedback support
* Added preset configurations:
  - NumberPad.phoneDialer() - Optimized for phone number input (includes +, #, *, C, backspace buttons)
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
