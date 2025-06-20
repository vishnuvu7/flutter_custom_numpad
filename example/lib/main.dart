import 'package:flutter/material.dart';
import 'package:flutter_numpad/flutter_numpad.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Number Pad Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const NumberPadExample(),
    );
  }
}

class NumberPadExample extends StatefulWidget {
  const NumberPadExample({super.key});

  @override
  State<NumberPadExample> createState() => _NumberPadExampleState();
}

class _NumberPadExampleState extends State<NumberPadExample> {
  final TextEditingController _controller = TextEditingController();
  // bool _isDarkTheme = false;
  // bool _showOkButton = false;
  // bool _showDecimalPoint = true;
  String _selectedPreset = 'Numeric';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Pad Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Settings panel
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Display the current input
                TextField(
                  controller: _controller,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Enter Number',
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                // Preset selector
                DropdownButtonFormField<String>(
                  value: _selectedPreset,
                  decoration: const InputDecoration(
                    labelText: 'Preset Configuration',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    // DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                    DropdownMenuItem(
                      value: 'Phone Dialer',
                      child: Text('Phone Dialer'),
                    ),
                    DropdownMenuItem(
                      value: 'Calculator',
                      child: Text('Calculator'),
                    ),
                    DropdownMenuItem(value: 'OTP', child: Text('OTP')),
                    DropdownMenuItem(value: 'Numeric', child: Text('Numeric')),
                    DropdownMenuItem(
                      value: 'Custom Layout',
                      child: Text('Custom Layout'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPreset = value!;
                      _controller.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Number pad
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: _buildNumberPad(),
            ),
          ),
          // Button to show NumberPad in a bottom sheet modal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (context) {
                    final TextEditingController modalController =
                        TextEditingController(text: _controller.text);
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        left: 16,
                        right: 16,
                        top: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Enter Number (Modal)',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: modalController,
                            readOnly: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 320,
                            child: NumberPad(
                              controller: modalController,
                              maxLength: 10,
                              showOkButton: true,
                              showDecimalPoint: true,
                              onChanged: (value) {
                                // Optionally update the main controller as well
                              },
                              onOkPressed: () {
                                _controller.text = modalController.text;
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'OK pressed in modal! Value: \\${modalController.text}',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              theme: NumberPadTheme.light(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Text('Show NumberPad in Bottom Sheet'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    final theme = NumberPadTheme.light();

    switch (_selectedPreset) {
      case 'Phone Dialer':
        return NumberPad.phoneDialer(
          controller: _controller,
          onChanged: (value) {
            debugPrint('Phone number: $value');
          },
          theme: theme,
        );
      case 'Calculator':
        return NumberPad.calculator(
          controller: _controller,
          onChanged: (value) {
            debugPrint('Calculator input: $value');
          },
          theme: theme,
        );
      case 'OTP':
        return NumberPad.otp(
          controller: _controller,
          onChanged: (value) {
            debugPrint('OTP input: $value');
          },
          onOkPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP submitted: ${_controller.text}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          theme: theme,
        );
      case 'Numeric':
        return NumberPad.numeric(
          controller: _controller,
          maxLength: 8,
          showOkButton: true,
          showDecimalPoint: true,
          onChanged: (value) {
            debugPrint('Numeric input: $value');
          },
          onOkPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Numeric value submitted: ${_controller.text}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          theme: theme,
        );
      case 'Custom Layout':
        return NumberPad.custom(
          controller: _controller,
          layout: [
            ['2', '4', '9'],
            ['1', '6', '5'],
            ['7', '3', '8'],
            ['OK', '0', 'backspace'],
          ],
          customButtonHandlers: {
            'OK': () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Custom OK pressed! Value: ${_controller.text}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          },
          onChanged: (value) {
            debugPrint('Custom layout input: $value');
          },
          theme: NumberPadTheme.light().copyWith(
            // Custom colors for specific buttons
            buttonColors: {
              'OK': Colors.green,
              'backspace': Colors.red,
              '0': Colors.blue,
              '9': Colors.orange,
            },
            // Custom font sizes for specific buttons
            buttonFontSizes: {'OK': 20.0, 'backspace': 18.0, '0': 28.0},
            // Custom font weights for specific buttons
            buttonFontWeights: {
              'OK': FontWeight.w600,
              '0': FontWeight.w900,
              '9': FontWeight.w300,
            },
          ),
        );
      default: // Custom
        return NumberPad(
          controller: _controller,
          maxLength: 10,
          showOkButton: false,
          showDecimalPoint: true,
          onChanged: (value) {
            debugPrint('Current value: $value');
          },
          onOkPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OK pressed! Value: ${_controller.text}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          theme: theme,
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
