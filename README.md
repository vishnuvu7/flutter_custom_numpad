# flutter_custom_numpad

[![pub package](https://img.shields.io/pub/v/flutter_custom_numpad.svg)](https://pub.dev/packages/flutter_custom_numpad)

A customizable number pad widget for Flutter applications.

## Features

- **Presets** for numeric input, PIN/OTP, currency amounts, a working calculator and a phone dialer, plus fully custom layouts
- **`PinDisplay`** widget that shows PIN/OTP progress as dots, boxes or underlines
- **Input validation**: max length, max value, decimal places, leading zeros, `TextInputFormatter`s, and an OK button that enables only for valid input
- **Currency amounts** with cash-register style entry and locale separators
- **Action button** for biometric unlock or "Forgot PIN?"
- **Theming** via `NumberPadTheme`, usable directly or as a `ThemeExtension`; follows light/dark mode automatically
- **Styling**: button shapes, borders, elevation, spacing, per-key colors and fonts, press animation
- **Feedback**: haptics and optional click sounds
- **Accessibility**: semantic labels for every key, large-text support and right-to-left layouts

## Installation

```yaml
dependencies:
  flutter_custom_numpad: ^0.1.0
```

## Usage

### Basic usage

```dart
final _controller = TextEditingController();

Column(
  children: [
    TextField(controller: _controller, readOnly: true),
    Expanded(
      child: NumberPad(
        controller: _controller,
        onChanged: (value) => print('Current value: $value'),
      ),
    ),
  ],
)
```

`NumberPad` fills the space it's given, so place it inside an `Expanded` or a `SizedBox` with a height.

### PIN / OTP with `PinDisplay`

Share one controller between `PinDisplay` and `NumberPad.otp()`:

```dart
Column(
  children: [
    PinDisplay(
      controller: _controller,
      length: 4,
      shape: PinDisplayShape.dot, // or .box / .underline
      hasError: _wrongPin,
      onCompleted: (pin) => _verify(pin),
    ),
    Expanded(
      child: NumberPad.otp(
        controller: _controller,
        length: 4,
        showOkButton: false,
        action: NumberPadAction(
          icon: const Icon(Icons.fingerprint),
          semanticLabel: 'Unlock with fingerprint',
          onPressed: _authenticate,
        ),
      ),
    ),
  ],
)
```

### Numeric input with validation

```dart
NumberPad.numeric(
  controller: _controller,
  maxDecimalPlaces: 2,
  maxValue: 10000,
  showOkButton: true,
  canSubmit: (text) => text.isNotEmpty, // OK is disabled until true
  onOkPressed: () => print('Submitted: ${_controller.text}'),
)
```

You can also pass any `TextInputFormatter`s through `inputFormatters`, disable keys with `disabledKeys`, or turn off the whole pad with `enabled: false`.

### Currency amounts

```dart
NumberPad.amount(
  controller: _controller,
  decimalDigits: 2,
  decimalSeparator: '.',
  groupSeparator: ',',
  centsFirst: true, // typing 1, 2, 3 shows 1.23
  maxValue: 1000000,
  onAmountChanged: (double? value) => print(value),
)
```

The controller holds the formatted text (for example `1,234.56`); `onAmountChanged` receives the parsed number. With `centsFirst: false` the pad shows a decimal key instead of `00`.

### Calculator

```dart
NumberPad.calculator(
  controller: _controller,
  onResult: (double result) => print('= $result'),
)
```

`=` evaluates the expression with standard precedence (`×`/`÷` before `+`/`-`), `%` divides the preceding number by 100, and `√` takes a square root. Invalid results such as division by zero show `Error`. The parser is also available directly via `NumberPadCalculator.evaluate('2+3×4')`.

### Phone dialer

```dart
NumberPad.phoneDialer(controller: _controller)
```

Digits plus `*` and `#`, up to 15 characters.

### Custom layout

```dart
NumberPad.custom(
  controller: _controller,
  layout: [
    ['1', '2', '3', 'A'],
    ['4', '5', '6', 'B'],
    ['7', '8', '9', 'CLEAR'],
    [NumberPad.okKey, '0', NumberPad.backspaceKey],
  ],
  customButtonHandlers: {
    'A': () => print('A pressed'),
    'B': () => print('B pressed'),
    'CLEAR': () => _controller.clear(),
  },
  onOkPressed: () => print('Submitted'),
)
```

Layouts can use digits, `.`, `C`, `NumberPad.backspaceKey`, `NumberPad.okKey`, `NumberPad.actionKey`, and any key listed in `customButtonHandlers`. Use `''` for an empty slot.

## Theming

Without a theme, the pad uses colors from the app's `ColorScheme` and follows light/dark mode.

### App-wide theme

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const [
      NumberPadTheme(
        buttonShape: NumberPadButtonShape.circle,
        buttonSpacing: 6,
        enableSoundFeedback: true,
      ),
    ],
  ),
)
```

### Per-widget theme

```dart
NumberPad(
  controller: _controller,
  theme: NumberPadTheme.dark().copyWith(
    fontSize: 28,
    buttonBorderSide: const BorderSide(color: Colors.white24),
    buttonColors: {NumberPad.okKey: Colors.green, '0': Colors.blue},
    buttonFontSizes: {'0': 30},
    buttonFontWeights: {'0': FontWeight.w900},
  ),
)
```

Fields are resolved in this order: the widget's `theme`, then the `NumberPadTheme` extension, then `NumberPadTheme.fromColorScheme()`.

| Property | Description |
| --- | --- |
| `numberColor`, `backspaceColor`, `okColor`, `actionColor` | Key colors |
| `operatorColor`, `equalsColor`, `clearColor` | Calculator symbol colors |
| `buttonBackgroundColor`, `splashColor` | Button fill and ink splash |
| `fontSize`, `fontWeight`, `iconSize` | Label sizing |
| `buttonShape`, `borderRadius`, `buttonBorderSide`, `buttonElevation`, `buttonSpacing` | Button shape and spacing |
| `enableHapticFeedback`, `enableSoundFeedback`, `enablePressAnimation` | Feedback |
| `buttonColors`, `buttonFontSizes`, `buttonFontWeights` | Per-key overrides |

## Accessibility

Every key has a screen-reader label ("Delete", "Done", "Decimal point", "Square root", …). Override them for localization:

```dart
NumberPad(
  controller: _controller,
  semanticLabels: {NumberPad.backspaceKey: 'Borrar', NumberPad.okKey: 'Listo'},
)
```

`PinDisplay` announces progress such as "PIN, 2 of 4 digits entered".

## Gestures

- **Tap**: enter a digit or perform the key's action
- **Long press on backspace**: clear all input

## Example

See the [`example`](example) directory for a complete app covering every preset, light/dark mode and `PinDisplay`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
