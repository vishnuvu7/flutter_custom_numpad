import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_numpad/flutter_numpad.dart';

void main() {
  group('NumberPad Widget Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('NumberPad displays all number buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NumberPad(controller: controller)),
        ),
      );

      // Check if all number buttons are present
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
    });

    testWidgets('NumberPad shows backspace button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NumberPad(controller: controller)),
        ),
      );

      expect(find.byIcon(Icons.backspace), findsOneWidget);
    });

    testWidgets('NumberPad does not show OK button by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NumberPad(controller: controller)),
        ),
      );

      expect(find.byIcon(Icons.done), findsNothing);
    });

    testWidgets('NumberPad shows OK button when showOkButton is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberPad(controller: controller, showOkButton: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets(
      'NumberPad does not show decimal point when showDecimalPoint is false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NumberPad(controller: controller, showDecimalPoint: false),
            ),
          ),
        );

        expect(find.text('.'), findsNothing);
      },
    );

    testWidgets('Tapping number buttons adds to controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NumberPad(controller: controller)),
        ),
      );

      await tester.tap(find.text('1'));
      await tester.pump();
      expect(controller.text, equals('1'));

      await tester.tap(find.text('2'));
      await tester.pump();
      expect(controller.text, equals('12'));

      await tester.tap(find.text('3'));
      await tester.pump();
      expect(controller.text, equals('123'));
    });

    testWidgets('Tapping decimal point adds to controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NumberPad(controller: controller)),
        ),
      );

      await tester.tap(find.text('.'));
      await tester.pump();
      expect(controller.text, equals('.'));
    });

    testWidgets('Tapping backspace removes last character', (
      WidgetTester tester,
    ) async {
      controller.text = '123';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NumberPad(controller: controller)),
        ),
      );

      await tester.tap(find.byIcon(Icons.backspace));
      await tester.pump();
      expect(controller.text, equals('12'));
    });

    testWidgets('Long press on backspace clears all text', (
      WidgetTester tester,
    ) async {
      controller.text = '123';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NumberPad(controller: controller)),
        ),
      );

      await tester.longPress(find.byIcon(Icons.backspace));
      await tester.pump();
      expect(controller.text, equals(''));
    });

    testWidgets('Respects maxLength constraint', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NumberPad(controller: controller, maxLength: 3)),
        ),
      );

      // Add 3 digits
      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(controller.text, equals('123'));

      // Try to add more - should not work
      await tester.tap(find.text('4'));
      await tester.pump();
      expect(controller.text, equals('123'));
    });

    testWidgets('onChanged callback is called when text changes', (
      WidgetTester tester,
    ) async {
      String? lastChangedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberPad(
              controller: controller,
              onChanged: (value) {
                lastChangedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('5'));
      await tester.pump();
      expect(lastChangedValue, equals('5'));
    });

    testWidgets('onOkPressed callback is called when OK button is tapped', (
      WidgetTester tester,
    ) async {
      bool okPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberPad(
              controller: controller,
              showOkButton: true,
              onOkPressed: () {
                okPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.done));
      await tester.pump();
      expect(okPressed, isTrue);
    });

    testWidgets('Uses light theme by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NumberPad(controller: controller)),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('1'));
      expect(textWidget.style?.color, equals(Colors.black87));
    });

    testWidgets('Uses custom theme when provided', (WidgetTester tester) async {
      final customTheme = NumberPadTheme(
        numberColor: Colors.red,
        fontSize: 30.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberPad(controller: controller, theme: customTheme),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('1'));
      expect(textWidget.style?.color, equals(Colors.red));
      expect(textWidget.style?.fontSize, equals(30.0));
    });

    // Preset Configuration Tests
    group('Preset Configuration Tests', () {
      testWidgets('NumberPad.phoneDialer shows phone dialer layout', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: NumberPad.phoneDialer(controller: controller)),
          ),
        );

        // Check for phone dialer specific buttons
        expect(find.text('*'), findsOneWidget);
        expect(find.text('#'), findsOneWidget);
        expect(find.text('.'), findsNothing); // No decimal point
        expect(find.byIcon(Icons.done), findsNothing); // No OK button
      });

      testWidgets('NumberPad.calculator shows calculator layout', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: NumberPad.calculator(controller: controller)),
          ),
        );

        // Check for calculator specific buttons
        expect(find.text('+'), findsOneWidget);
        expect(find.text('-'), findsOneWidget);
        expect(find.text('×'), findsOneWidget);
        expect(find.text('÷'), findsOneWidget);
        expect(find.text('='), findsOneWidget);
        expect(find.text('%'), findsOneWidget);
        expect(find.text('√'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
        expect(find.text('.'), findsOneWidget); // Has decimal point
      });

      testWidgets('NumberPad.otp shows OTP layout', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NumberPad.otp(controller: controller, onOkPressed: () {}),
            ),
          ),
        );

        expect(find.text('.'), findsNothing); // No decimal point
        expect(find.byIcon(Icons.done), findsOneWidget); // Has OK button
      });

      testWidgets('NumberPad.numeric shows numeric layout', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NumberPad.numeric(
                controller: controller,
                showOkButton: true,
                showDecimalPoint: true,
              ),
            ),
          ),
        );

        expect(find.text('.'), findsOneWidget); // Has decimal point
        expect(find.byIcon(Icons.done), findsOneWidget); // Has OK button
      });

      testWidgets('Phone dialer respects max length of 15', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: NumberPad.phoneDialer(controller: controller)),
          ),
        );

        // Add 15 digits
        for (int i = 0; i < 15; i++) {
          await tester.tap(find.text('1'));
          await tester.pump();
        }
        expect(controller.text.length, equals(15));

        // Try to add more - should not work
        await tester.tap(find.text('2'));
        await tester.pump();
        expect(controller.text.length, equals(15));
      });

      testWidgets('OTP respects max length of 6', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NumberPad.otp(controller: controller, onOkPressed: () {}),
            ),
          ),
        );

        // Add 6 digits
        for (int i = 0; i < 6; i++) {
          await tester.tap(find.text('1'));
          await tester.pump();
        }
        expect(controller.text.length, equals(6));

        // Try to add more - should not work
        await tester.tap(find.text('2'));
        await tester.pump();
        expect(controller.text.length, equals(6));
      });
    });

    // Custom Layout Tests
    group('Custom Layout Tests', () {
      testWidgets('NumberPad.custom shows custom layout', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NumberPad.custom(
                controller: controller,
                layout: [
                  ['A', 'B', 'C'],
                  ['1', '2', '3'],
                  ['OK', '0', 'CLEAR'],
                ],
                customButtonHandlers: {'OK': () {}, 'CLEAR': () {}},
              ),
            ),
          ),
        );

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);
        expect(find.text('CLEAR'), findsOneWidget);
      });

      testWidgets('Custom layout handles custom button presses', (
        WidgetTester tester,
      ) async {
        bool okPressed = false;
        bool clearPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NumberPad.custom(
                controller: controller,
                layout: [
                  ['OK', 'CLEAR'],
                ],
                customButtonHandlers: {
                  'OK': () => okPressed = true,
                  'CLEAR': () => clearPressed = true,
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('OK'));
        await tester.pump();
        expect(okPressed, isTrue);

        await tester.tap(find.text('CLEAR'));
        await tester.pump();
        expect(clearPressed, isTrue);
      });

      testWidgets('Custom layout numbers work normally', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NumberPad.custom(
                controller: controller,
                layout: [
                  ['1', '2', '3'],
                ],
              ),
            ),
          ),
        );

        await tester.tap(find.text('1'));
        await tester.pump();
        expect(controller.text, equals('1'));

        await tester.tap(find.text('2'));
        await tester.pump();
        expect(controller.text, equals('12'));
      });
    });

    // Special Button Tests
    group('Special Button Tests', () {
      testWidgets('Calculator special buttons work', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: NumberPad.calculator(controller: controller)),
          ),
        );

        // Test that special buttons add to text
        await tester.tap(find.text('+'));
        await tester.pump();
        expect(controller.text, equals('+'));

        await tester.tap(find.text('='));
        await tester.pump();
        expect(controller.text, equals('+='));

        await tester.tap(find.text('C'));
        await tester.pump();
        expect(controller.text, equals('')); // C should clear
      });

      testWidgets('Phone dialer special buttons work', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: NumberPad.phoneDialer(controller: controller)),
          ),
        );

        await tester.tap(find.text('*'));
        await tester.pump();
        expect(controller.text, equals('*'));

        await tester.tap(find.text('#'));
        await tester.pump();
        expect(controller.text, equals('*#'));
      });
    });
  });

  group('NumberPadTheme Tests', () {
    test('NumberPadTheme.light() creates light theme', () {
      final theme = NumberPadTheme.light();
      expect(theme.numberColor, equals(Colors.black87));
      expect(theme.backspaceColor, equals(Colors.black87));
      expect(theme.okColor, equals(Colors.black87));
      expect(theme.fontSize, equals(24.0));
      expect(theme.fontWeight, equals(FontWeight.bold));
      expect(theme.borderRadius, equals(8.0));
      expect(theme.enableHapticFeedback, isTrue);
    });

    test('NumberPadTheme.dark() creates dark theme', () {
      final theme = NumberPadTheme.dark();
      expect(theme.numberColor, equals(Colors.white));
      expect(theme.backspaceColor, equals(Colors.white));
      expect(theme.okColor, equals(Colors.white));
      expect(theme.fontSize, equals(24.0));
      expect(theme.fontWeight, equals(FontWeight.bold));
      expect(theme.borderRadius, equals(8.0));
      expect(theme.enableHapticFeedback, isTrue);
    });

    test('copyWith creates new theme with updated values', () {
      final originalTheme = NumberPadTheme.light();
      final newTheme = originalTheme.copyWith(
        numberColor: Colors.blue,
        fontSize: 28.0,
      );

      expect(newTheme.numberColor, equals(Colors.blue));
      expect(newTheme.fontSize, equals(28.0));
      expect(newTheme.backspaceColor, equals(originalTheme.backspaceColor));
      expect(newTheme.okColor, equals(originalTheme.okColor));
    });

    // Custom Styling Tests
    group('Custom Styling Tests', () {
      test('getButtonColor returns custom color for specific button', () {
        final theme = NumberPadTheme.light().copyWith(
          buttonColors: {'OK': Colors.green, 'backspace': Colors.red},
        );

        expect(theme.getButtonColor('OK'), equals(Colors.green));
        expect(theme.getButtonColor('backspace'), equals(Colors.red));
        expect(
          theme.getButtonColor('1'),
          equals(Colors.black87),
        ); // Default color
      });

      test(
        'getButtonFontSize returns custom font size for specific button',
        () {
          final theme = NumberPadTheme.light().copyWith(
            buttonFontSizes: {'OK': 20.0, '0': 28.0},
          );

          expect(theme.getButtonFontSize('OK'), equals(20.0));
          expect(theme.getButtonFontSize('0'), equals(28.0));
          expect(theme.getButtonFontSize('1'), equals(24.0)); // Default size
        },
      );

      test(
        'getButtonFontWeight returns custom font weight for specific button',
        () {
          final theme = NumberPadTheme.light().copyWith(
            buttonFontWeights: {'OK': FontWeight.w600, '0': FontWeight.w900},
          );

          expect(theme.getButtonFontWeight('OK'), equals(FontWeight.w600));
          expect(theme.getButtonFontWeight('0'), equals(FontWeight.w900));
          expect(
            theme.getButtonFontWeight('1'),
            equals(FontWeight.bold),
          ); // Default weight
        },
      );

      test('Custom styling works with null values', () {
        final theme = NumberPadTheme.light().copyWith(
          buttonColors: {'OK': Colors.green},
          buttonFontSizes: {'OK': 20.0},
          buttonFontWeights: {'OK': FontWeight.w600},
        );

        expect(theme.getButtonColor('1'), equals(Colors.black87));
        expect(theme.getButtonFontSize('1'), equals(24.0));
        expect(theme.getButtonFontWeight('1'), equals(FontWeight.bold));
      });
    });
  });
}
