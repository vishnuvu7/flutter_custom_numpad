import 'package:flutter/material.dart';
import 'package:flutter_custom_numpad/flutter_custom_numpad.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Number Pad Example',
      themeMode: _themeMode,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: NumberPadExample(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: () => setState(() {
          _themeMode = _themeMode == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.dark;
        }),
      ),
    );
  }
}

enum Preset {
  numeric('Numeric'),
  amount('Amount'),
  pin('PIN with display'),
  calculator('Calculator'),
  phoneDialer('Phone Dialer'),
  custom('Custom Layout');

  const Preset(this.label);
  final String label;
}

class NumberPadExample extends StatefulWidget {
  const NumberPadExample({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<NumberPadExample> createState() => _NumberPadExampleState();
}

class _NumberPadExampleState extends State<NumberPadExample> {
  static const _pinLength = 4;
  static const _correctPin = '1234';

  final TextEditingController _controller = TextEditingController();
  Preset _preset = Preset.numeric;
  bool _pinError = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  void _checkPin(String pin) {
    if (pin == _correctPin) {
      _showMessage('PIN accepted');
      _controller.clear();
    } else {
      setState(() => _pinError = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => _pinError = false);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Pad Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Light mode' : 'Dark mode',
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<Preset>(
                initialValue: _preset,
                decoration: const InputDecoration(
                  labelText: 'Preset',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final preset in Preset.values)
                    DropdownMenuItem(value: preset, child: Text(preset.label)),
                ],
                onChanged: (value) => setState(() {
                  _preset = value!;
                  _controller.clear();
                }),
              ),
              const SizedBox(height: 16),
              _buildDisplay(),
              const SizedBox(height: 16),
              Expanded(child: _buildNumberPad()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    if (_preset == Preset.pin) {
      return Column(
        children: [
          Text(
            'Enter PIN (hint: $_correctPin)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          PinDisplay(
            controller: _controller,
            length: _pinLength,
            hasError: _pinError,
            onCompleted: _checkPin,
          ),
        ],
      );
    }
    return TextField(
      controller: _controller,
      readOnly: true,
      showCursor: false,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixText: _preset == Preset.amount ? '\$ ' : null,
        hintText: _preset == Preset.amount ? '0.00' : 'Enter number',
      ),
    );
  }

  Widget _buildNumberPad() {
    switch (_preset) {
      case Preset.numeric:
        return NumberPad.numeric(
          controller: _controller,
          maxDecimalPlaces: 2,
          maxValue: 10000,
          showOkButton: true,
          canSubmit: (text) => text.isNotEmpty,
          onOkPressed: () => _showMessage('Submitted: ${_controller.text}'),
        );
      case Preset.amount:
        return NumberPad.amount(
          controller: _controller,
          maxValue: 1000000,
          showOkButton: true,
          canSubmit: (text) => text.isNotEmpty,
          onAmountChanged: (value) => debugPrint('Amount: $value'),
          onOkPressed: () => _showMessage('Pay \$${_controller.text}'),
          theme: const NumberPadTheme(
            buttonShape: NumberPadButtonShape.circle,
            buttonSpacing: 4,
            enableSoundFeedback: true,
          ),
        );
      case Preset.pin:
        return NumberPad.otp(
          controller: _controller,
          length: _pinLength,
          showOkButton: false,
          action: NumberPadAction(
            icon: const Icon(Icons.fingerprint),
            semanticLabel: 'Unlock with fingerprint',
            onPressed: () => _showMessage('Biometric unlock requested'),
          ),
          theme: const NumberPadTheme(
            buttonShape: NumberPadButtonShape.circle,
            buttonSpacing: 6,
            buttonBorderSide: BorderSide(color: Colors.grey),
          ),
        );
      case Preset.calculator:
        return NumberPad.calculator(
          controller: _controller,
          onResult: (value) => debugPrint('Result: $value'),
        );
      case Preset.phoneDialer:
        return NumberPad.phoneDialer(controller: _controller);
      case Preset.custom:
        return NumberPad.custom(
          controller: _controller,
          layout: const [
            ['2', '4', '9'],
            ['1', '6', '5'],
            ['7', '3', '8'],
            [NumberPad.okKey, '0', NumberPad.backspaceKey],
          ],
          onOkPressed: () => _showMessage('Custom OK: ${_controller.text}'),
          theme: const NumberPadTheme(
            buttonColors: {
              NumberPad.okKey: Colors.green,
              NumberPad.backspaceKey: Colors.red,
              '0': Colors.blue,
              '9': Colors.orange,
            },
            buttonFontSizes: {'0': 28.0},
            buttonFontWeights: {'0': FontWeight.w900, '9': FontWeight.w300},
          ),
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
