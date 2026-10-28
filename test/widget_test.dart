import 'package:flutter/material.dart';
import 'package:flutter_lab1/counter_logic.dart';
import 'package:flutter_lab1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final counter = find.byKey(const Key('counterValue'));
  final input = find.byKey(const Key('inputField'));
  final apply = find.byKey(const Key('applyButton'));

  String counterText(WidgetTester tester) =>
      tester.widget<Text>(counter).data ?? '';

  Future<void> submit(WidgetTester tester, String text) async {
    await tester.enterText(input, text);
    await tester.tap(apply);
    await tester.pump();
  }

  testWidgets('starts at zero', (tester) async {
    await tester.pumpWidget(const CounterApp());
    expect(counterText(tester), '0');
  });

  testWidgets('increments by entered numbers', (tester) async {
    await tester.pumpWidget(const CounterApp());

    await submit(tester, '5');
    expect(counterText(tester), '5');

    await submit(tester, '-2');
    expect(counterText(tester), '3');
  });

  testWidgets('resets on the magic command', (tester) async {
    await tester.pumpWidget(const CounterApp());

    await submit(tester, '10');
    await submit(tester, resetCommand);

    expect(counterText(tester), '0');
    expect(find.text('Лічильник обнулено'), findsOneWidget);
  });

  testWidgets('shows an error and keeps the value on invalid input', (
    tester,
  ) async {
    await tester.pumpWidget(const CounterApp());

    await submit(tester, '4');
    await submit(tester, '1.5');

    expect(counterText(tester), '4');
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('не є цілим числом'), findsWidgets);
  });

  testWidgets('submits from the keyboard action', (tester) async {
    await tester.pumpWidget(const CounterApp());

    await tester.enterText(input, '7');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(counterText(tester), '7');
  });
}
