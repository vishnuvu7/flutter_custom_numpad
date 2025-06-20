<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# flutter_custom_numpad

A customizable number pad widget for Flutter applications.

## Features

- **Customizable Number Pad**: A clean and modern number pad widget
- **Theme Support**: Built-in light and dark themes with customization options
- **Flexible Configuration**: Configurable max length, decimal point, and OK button
- **Haptic Feedback**: Optional haptic feedback for better user experience
- **Responsive Design**: Adapts to different screen sizes
- **Accessibility**: Proper touch targets and visual feedback

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_custom_numpad: ^0.0.1
```

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_custom_numpad/flutter_custom_numpad.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Number Pad Example')),
      body: Column(
        children: [
          // Display the current input
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Number',
              ),
            ),
          ),
          // Number pad
          Expanded(
            child: NumberPad(
              controller: _controller,
              onChanged: (value) {
                print('Current value: $value');
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Preset Configurations

The NumberPad comes with several preset configurations for common use cases:

#### Phone Dialer
```dart
NumberPad.phoneDialer(
  controller: _controller,
  onChanged: (value) {
    print('Phone number: $value');
  },
)
```
- No decimal point
- No OK button
- Max length: 15 digits
- Includes special buttons: +, #, *, C (clear), backspace
- Optimized for phone numbers

#### Calculator
```dart
NumberPad.calculator(
  controller: _controller,
  onChanged: (value) {
    print('Calculator input: $value');
  },
)
```
- Includes decimal point
- No OK button
- Max length: 20 digits
- Includes special buttons: +, -, ×, ÷, =, %, √, C
- Optimized for calculations

#### OTP Input
```dart
NumberPad.otp(
  controller: _controller,
  onChanged: (value) {
    print('OTP input: $value');
  },
  onOkPressed: () {
    print('OTP submitted: ${_controller.text}');
  },
)
```
- No decimal point
- Includes OK button
- Max length: 6 digits
- Optimized for PIN/OTP entry

#### Numeric Input
```dart
NumberPad.numeric(
  controller: _controller,
  maxLength: 8,
  showOkButton: true,
  showDecimalPoint: true,
  onChanged: (value) {
    print('Numeric input: $value');
  },
  onOkPressed: () {
    print('Value submitted: ${_controller.text}');
  },
)
```
- Configurable decimal point and OK button
- Configurable max length (default: 10)
- General purpose numeric input

#### Custom Layout
```dart
NumberPad.custom(
  controller: _controller,
  layout: [
    ['A', 'B', 'C', 'D'],
    ['1', '2', '3', '4'],
    ['5', '6', '7', '8'],
    ['9', '0', 'CLEAR', 'SUBMIT'],
  ],
  customButtonHandlers: {
    'CLEAR': () {
      controller.clear();
      print('Custom clear button pressed!');
    },
    'SUBMIT': () {
      print('Custom submit! Value: ${controller.text}');
    },
  },
  onChanged: (value) {
    print('Custom layout input: $value');
  },
)
```
- Fully customizable button layout
- Custom button handlers for special actions
- Flexible configuration for any use case
- Regular number buttons work as expected

### Advanced Usage with Custom Theme

```dart
NumberPad(
  controller: _controller,
  maxLength: 10,
  showOkButton: true,
  showDecimalPoint: true,
  onChanged: (value) {
    print('Value changed: $value');
  },
  onOkPressed: () {
    print('OK pressed');
    Navigator.pop(context);
  },
  theme: NumberPadTheme.dark().copyWith(
    fontSize: 28.0,
    borderRadius: 12.0,
    enableHapticFeedback: false,
  ),
)
```

### Custom Theme

```dart
final customTheme = NumberPadTheme(
  numberColor: Colors.blue,
  backspaceColor: Colors.red,
  okColor: Colors.green,
  fontSize: 26.0,
  fontWeight: FontWeight.w600,
  borderRadius: 10.0,
  enableHapticFeedback: true,
);

NumberPad(
  controller: _controller,
  theme: customTheme,
)
```

### Custom Key Styling

```dart
final customTheme = NumberPadTheme.light().copyWith(
  // Custom colors for specific buttons
  buttonColors: {
    'OK': Colors.green,
    'backspace': Colors.red,
    '0': Colors.blue,
    '9': Colors.orange,
  },
  // Custom font sizes for specific buttons
  buttonFontSizes: {
    'OK': 20.0,
    'backspace': 18.0,
    '0': 28.0,
  },
  // Custom font weights for specific buttons
  buttonFontWeights: {
    'OK': FontWeight.w600,
    '0': FontWeight.w900,
    '9': FontWeight.w300,
  },
);

NumberPad(
  controller: _controller,
  theme: customTheme,
)
```

## API Reference

### NumberPad

The main number pad widget.

#### Properties

- `controller` (required): `TextEditingController` - Controls the input text
- `maxLength` (optional): `int` - Maximum length of input (default: 8)
- `onChanged` (optional): `Function(String)?` - Callback when text changes
- `onOkPressed` (optional): `VoidCallback?` - Callback when OK button is pressed
- `showOkButton` (optional): `bool` - Whether to show OK button (default: false)
- `showDecimalPoint` (optional): `bool` - Whether to show decimal point (default: true)
- `theme` (optional): `NumberPadTheme?` - Theme configuration
- `buttonAspectRatio` (optional): `double` - Aspect ratio for buttons (default: 1.5)

### NumberPadTheme

Theme configuration for the number pad.

#### Properties

- `numberColor`: `Color?` - Color of number buttons text
- `backspaceColor`: `Color?` - Color of backspace button icon
- `okColor`: `Color?` - Color of OK button icon
- `buttonBackgroundColor`: `Color?` - Background color of buttons
- `fontSize`: `double?` - Font size of number buttons
- `fontWeight`: `FontWeight?` - Font weight of number buttons
- `borderRadius`: `double?` - Border radius of buttons
- `enableHapticFeedback`: `bool` - Whether to enable haptic feedback
- `buttonColors`: `Map<String, Color>?` - Custom colors for specific buttons
- `buttonFontSizes`: `Map<String, double>?` - Custom font sizes for specific buttons
- `buttonFontWeights`: `Map<String, FontWeight>?` - Custom font weights for specific buttons

#### Factory Constructors

- `NumberPadTheme.light()`: Creates a light theme
- `NumberPadTheme.dark()`: Creates a dark theme

#### Helper Methods

- `getButtonColor(String button)`: Gets the color for a specific button
- `getButtonFontSize(String button)`: Gets the font size for a specific button
- `getButtonFontWeight(String button)`: Gets the font weight for a specific button

## Features

### Gestures

- **Tap**: Add number or perform action
- **Long Press on Backspace**: Clear all input
- **Long Press on OK**: Clear all input

### Customization

The number pad is highly customizable through the `NumberPadTheme` class. You can customize:

- Colors for different button types
- Font size and weight
- Border radius
- Haptic feedback
- Button aspect ratio

## Example

See the `example` directory for a complete working example.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
