import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_numpad/flutter_custom_numpad.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Widget wrap(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme,
    home: Scaffold(body: child),
  );

  Future<void> tapAll(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      await tester.tap(find.text(key));
    }
    await tester.pump();
  }

  Color? textColor(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style?.color;

  /// Records method names sent on [SystemChannels.platform].
  List<MethodCall> recordPlatformCalls(WidgetTester tester) {
    final calls = <MethodCall>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    return calls;
  }

  group('Bug fixes', () {
    testWidgets('backspaceColor and okColor are applied', (tester) async {
      await tester.pumpWidget(
        wrap(
          NumberPad(
            controller: controller,
            showOkButton: true,
            showDecimalPoint: false,
            theme: const NumberPadTheme(
              numberColor: Colors.black,
              backspaceColor: Colors.red,
              okColor: Colors.green,
            ),
          ),
        ),
      );

      expect(
        tester.widget<Icon>(find.byIcon(Icons.backspace)).color,
        Colors.red,
      );
      expect(tester.widget<Icon>(find.byIcon(Icons.done)).color, Colors.green);
    });

    testWidgets('calculator symbols use their theme colors', (tester) async {
      await tester.pumpWidget(
        wrap(
          NumberPad.calculator(
            controller: controller,
            theme: NumberPadTheme.light(),
          ),
        ),
      );

      expect(textColor(tester, '='), Colors.green);
      expect(textColor(tester, 'C'), Colors.red);
      expect(textColor(tester, '+'), Colors.blue);
      expect(textColor(tester, '7'), Colors.black87);
    });

    testWidgets('OK button is shown alongside the decimal point', (
      tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        wrap(
          NumberPad(
            controller: controller,
            showOkButton: true,
            onOkPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('.'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.done));
      expect(pressed, isTrue);
    });

    testWidgets('only one decimal point is allowed', (tester) async {
      await tester.pumpWidget(wrap(NumberPad(controller: controller)));

      await tapAll(tester, ['1', '.', '5', '.', '2']);
      expect(controller.text, '1.52');
    });

    testWidgets('special buttons trigger haptic feedback once', (tester) async {
      final calls = recordPlatformCalls(tester);
      await tester.pumpWidget(
        wrap(NumberPad.phoneDialer(controller: controller)),
      );

      await tester.tap(find.text('*'));
      await tester.pump();

      expect(
        calls.where((c) => c.method == 'HapticFeedback.vibrate'),
        hasLength(1),
      );
    });

    testWidgets('long-pressing OK does not clear the input', (tester) async {
      controller.text = '12';
      await tester.pumpWidget(
        wrap(NumberPad.otp(controller: controller, onOkPressed: () {})),
      );

      await tester.longPress(find.byIcon(Icons.done));
      await tester.pump();
      expect(controller.text, '12');
    });
  });

  group('Calculator', () {
    testWidgets('evaluates and reports the result', (tester) async {
      double? result;
      await tester.pumpWidget(
        wrap(
          NumberPad.calculator(
            controller: controller,
            onResult: (value) => result = value,
          ),
        ),
      );

      await tapAll(tester, ['7', '+', '2', '×', '4', '=']);
      expect(controller.text, '15');
      expect(result, 15);

      await tapAll(tester, ['2']);
      expect(controller.text, '2', reason: 'a digit starts a new expression');
    });

    testWidgets('an operator after = continues from the result', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(NumberPad.calculator(controller: controller)),
      );

      await tapAll(tester, ['6', '÷', '4', '=', '×', '2', '=']);
      expect(controller.text, '3');
    });

    testWidgets('shows Error for undefined results and recovers', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(NumberPad.calculator(controller: controller)),
      );

      await tapAll(tester, ['1', '÷', '0', '=']);
      expect(controller.text, NumberPad.calculatorErrorText);

      await tapAll(tester, ['5']);
      expect(controller.text, '5');
    });

    testWidgets('replaces consecutive operators and guards decimals', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(NumberPad.calculator(controller: controller)),
      );

      await tapAll(tester, ['5', '+', '×']);
      expect(controller.text, '5×');

      await tapAll(tester, ['.', '.', '5', '.']);
      expect(controller.text, '5×0.5');
    });
  });

  group('Input validation', () {
    testWidgets('maxDecimalPlaces limits fraction digits', (tester) async {
      await tester.pumpWidget(
        wrap(NumberPad.numeric(controller: controller, maxDecimalPlaces: 2)),
      );

      await tapAll(tester, ['1', '.', '2', '3', '4']);
      expect(controller.text, '1.23');
    });

    testWidgets('maxValue rejects input that would exceed it', (tester) async {
      await tester.pumpWidget(
        wrap(NumberPad.numeric(controller: controller, maxValue: 100)),
      );

      await tapAll(tester, ['1', '0', '0', '1']);
      expect(controller.text, '100');
    });

    testWidgets('numeric preset strips redundant leading zeros', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(NumberPad.numeric(controller: controller)));

      await tapAll(tester, ['0', '0', '5']);
      expect(controller.text, '5');
    });

    testWidgets('inputFormatters can reject keys', (tester) async {
      await tester.pumpWidget(
        wrap(
          NumberPad(
            controller: controller,
            inputFormatters: [FilteringTextInputFormatter.deny('7')],
          ),
        ),
      );

      await tapAll(tester, ['1', '7', '2']);
      expect(controller.text, '12');
    });

    testWidgets('canSubmit disables OK until the input is valid', (
      tester,
    ) async {
      var submitted = 0;
      await tester.pumpWidget(
        wrap(
          NumberPad.otp(
            controller: controller,
            length: 4,
            canSubmit: (text) => text.length == 4,
            onOkPressed: () => submitted++,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.done));
      expect(submitted, 0);

      await tapAll(tester, ['1', '2', '3', '4']);
      await tester.tap(find.byIcon(Icons.done));
      expect(submitted, 1);
    });

    testWidgets('enabled: false and disabledKeys block input', (tester) async {
      await tester.pumpWidget(
        wrap(NumberPad(controller: controller, disabledKeys: const {'5'})),
      );
      await tapAll(tester, ['4', '5', '6']);
      expect(controller.text, '46');

      await tester.pumpWidget(
        wrap(NumberPad(controller: controller, enabled: false)),
      );
      await tapAll(tester, ['1']);
      expect(controller.text, '46');
    });
  });

  group('Amount mode', () {
    testWidgets('cents-first entry with grouping and 00 key', (tester) async {
      double? amount;
      await tester.pumpWidget(
        wrap(
          NumberPad.amount(
            controller: controller,
            onAmountChanged: (value) => amount = value,
          ),
        ),
      );

      await tapAll(tester, ['1', '2', '3']);
      expect(controller.text, '1.23');
      expect(amount, 1.23);

      await tapAll(tester, ['00', '4']);
      expect(controller.text, '1,230.04');

      await tester.tap(find.byIcon(Icons.backspace));
      await tester.pump();
      expect(controller.text, '123.00');
      expect(amount, 123);

      await tester.longPress(find.byIcon(Icons.backspace));
      await tester.pump();
      expect(controller.text, '');
      expect(amount, isNull);
    });

    testWidgets('leading zeros are ignored in cents-first mode', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(NumberPad.amount(controller: controller)));

      await tapAll(tester, ['0', '00', '5']);
      expect(controller.text, '0.05');
    });

    testWidgets('decimal entry with locale separators', (tester) async {
      double? amount;
      await tester.pumpWidget(
        wrap(
          NumberPad.amount(
            controller: controller,
            centsFirst: false,
            decimalSeparator: ',',
            groupSeparator: '.',
            onAmountChanged: (value) => amount = value,
          ),
        ),
      );

      await tapAll(tester, ['1', '2', '3', '4', ',', '5', '6', '7']);
      expect(controller.text, '1.234,56');
      expect(amount, 1234.56);
    });

    testWidgets('maxValue caps the amount', (tester) async {
      await tester.pumpWidget(
        wrap(NumberPad.amount(controller: controller, maxValue: 10)),
      );

      await tapAll(tester, ['1', '0', '0', '0', '1']);
      expect(controller.text, '10.00');
    });
  });

  group('Action button', () {
    testWidgets('shows next to OK and triggers its callback', (tester) async {
      var used = false;
      await tester.pumpWidget(
        wrap(
          NumberPad.otp(
            controller: controller,
            onOkPressed: () {},
            action: NumberPadAction(
              icon: const Icon(Icons.fingerprint),
              semanticLabel: 'Use fingerprint',
              onPressed: () => used = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.done), findsOneWidget);
      expect(find.bySemanticsLabel('Use fingerprint'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.fingerprint));
      expect(used, isTrue);
    });
  });

  group('Theme', () {
    testWidgets('reads NumberPadTheme from ThemeData.extensions', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          NumberPad(controller: controller),
          theme: ThemeData(
            extensions: const [NumberPadTheme(numberColor: Colors.purple)],
          ),
        ),
      );

      expect(textColor(tester, '1'), Colors.purple);
    });

    testWidgets('explicit theme overrides the extension', (tester) async {
      await tester.pumpWidget(
        wrap(
          NumberPad(
            controller: controller,
            theme: const NumberPadTheme(numberColor: Colors.orange),
          ),
          theme: ThemeData(
            extensions: const [
              NumberPadTheme(numberColor: Colors.purple, fontSize: 40),
            ],
          ),
        ),
      );

      final style = tester.widget<Text>(find.text('1')).style;
      expect(style?.color, Colors.orange);
      expect(style?.fontSize, 40);
    });

    testWidgets('follows dark mode automatically', (tester) async {
      final dark = ThemeData(brightness: Brightness.dark);
      await tester.pumpWidget(
        wrap(NumberPad(controller: controller), theme: dark),
      );

      expect(textColor(tester, '1'), dark.colorScheme.onSurface);
    });

    test('supports value equality and lerp', () {
      expect(NumberPadTheme.light(), NumberPadTheme.light());
      expect(NumberPadTheme.light().hashCode, NumberPadTheme.light().hashCode);
      expect(
        const NumberPadTheme(buttonColors: {'1': Colors.red}),
        const NumberPadTheme(buttonColors: {'1': Colors.red}),
      );
      expect(NumberPadTheme.light(), isNot(NumberPadTheme.dark()));

      final light = NumberPadTheme.light();
      final dark = NumberPadTheme.dark();
      expect(light.lerp(dark, 0).numberColor, Colors.black87);
      expect(light.lerp(dark, 1).numberColor, Colors.white);
      expect(light.lerp(dark, 0.5).fontSize, 24);
      expect(light.lerp(null, 0.5), light);
    });

    testWidgets('buttons shrink while pressed', (tester) async {
      await tester.pumpWidget(wrap(NumberPad(controller: controller)));

      double scaleOf(String key) => tester
          .widget<AnimatedScale>(
            find.ancestor(
              of: find.text(key),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale;

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('5')),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(scaleOf('5'), lessThan(1));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(scaleOf('5'), 1);
    });

    testWidgets('plays click sound when enabled', (tester) async {
      final calls = recordPlatformCalls(tester);
      await tester.pumpWidget(
        wrap(
          NumberPad(
            controller: controller,
            theme: const NumberPadTheme(enableSoundFeedback: true),
          ),
        ),
      );

      await tapAll(tester, ['1']);
      expect(calls.where((c) => c.method == 'SystemSound.play'), hasLength(1));
    });

    testWidgets('renders every button shape', (tester) async {
      for (final shape in NumberPadButtonShape.values) {
        await tester.pumpWidget(
          wrap(
            NumberPad(
              controller: controller,
              theme: NumberPadTheme(
                buttonShape: shape,
                buttonSpacing: 4,
                buttonElevation: 2,
                buttonBorderSide: const BorderSide(),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Accessibility', () {
    testWidgets('icon and symbol keys have semantic labels', (tester) async {
      await tester.pumpWidget(
        wrap(NumberPad.calculator(controller: controller)),
      );

      expect(find.bySemanticsLabel('Delete'), findsOneWidget);
      expect(find.bySemanticsLabel('Square root'), findsOneWidget);
      expect(find.bySemanticsLabel('Decimal point'), findsOneWidget);
    });

    testWidgets('semanticLabels overrides defaults', (tester) async {
      await tester.pumpWidget(
        wrap(
          NumberPad(
            controller: controller,
            semanticLabels: const {NumberPad.backspaceKey: 'Borrar'},
          ),
        ),
      );

      expect(find.bySemanticsLabel('Borrar'), findsOneWidget);
    });

    testWidgets('large text scale does not overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(3)),
            child: Scaffold(
              body: SizedBox(
                width: 240,
                height: 200,
                child: NumberPad(controller: controller),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps 1-2-3 order in right-to-left layouts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: NumberPad(controller: controller)),
          ),
        ),
      );

      expect(
        tester.getCenter(find.text('1')).dx,
        lessThan(tester.getCenter(find.text('3')).dx),
      );
    });
  });
}
