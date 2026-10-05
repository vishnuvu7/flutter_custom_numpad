import 'package:flutter/material.dart';
import 'package:flutter_custom_numpad/flutter_custom_numpad.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('box shape obscures entered digits by default', (tester) async {
    await tester.pumpWidget(
      wrap(
        PinDisplay(
          controller: controller,
          length: 4,
          shape: PinDisplayShape.box,
        ),
      ),
    );

    controller.text = '12';
    await tester.pump();

    expect(find.text('•'), findsNWidgets(2));
    expect(find.text('1'), findsNothing);
  });

  testWidgets('shows digits when obscureText is false', (tester) async {
    await tester.pumpWidget(
      wrap(
        PinDisplay(
          controller: controller,
          length: 4,
          shape: PinDisplayShape.underline,
          obscureText: false,
        ),
      ),
    );

    controller.text = '42';
    await tester.pump();

    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('calls onCompleted once when length is reached', (tester) async {
    final completed = <String>[];
    await tester.pumpWidget(
      wrap(
        PinDisplay(
          controller: controller,
          length: 4,
          onCompleted: completed.add,
        ),
      ),
    );

    controller.text = '123';
    await tester.pump();
    expect(completed, isEmpty);

    controller.text = '1234';
    await tester.pump();
    expect(completed, ['1234']);

    controller.text = '1234';
    await tester.pump();
    expect(completed, ['1234']);

    controller.text = '123';
    controller.text = '1235';
    await tester.pump();
    expect(completed, ['1234', '1235']);
  });

  testWidgets('announces progress to screen readers', (tester) async {
    await tester.pumpWidget(
      wrap(PinDisplay(controller: controller, length: 6)),
    );

    controller.text = '12';
    await tester.pump();

    expect(
      tester.getSemantics(find.byType(PinDisplay)),
      matchesSemantics(
        label: 'PIN',
        value: '2 of 6 digits entered',
        isLiveRegion: true,
      ),
    );
  });

  testWidgets('works together with NumberPad.otp', (tester) async {
    String? completed;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              PinDisplay(
                controller: controller,
                length: 4,
                onCompleted: (pin) => completed = pin,
              ),
              Expanded(child: NumberPad.otp(controller: controller, length: 4)),
            ],
          ),
        ),
      ),
    );

    for (final digit in ['1', '2', '3', '4', '5']) {
      await tester.tap(find.text(digit));
    }
    await tester.pump();

    expect(controller.text, '1234');
    expect(completed, '1234');
  });
}
