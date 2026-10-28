import 'package:flutter_lab1/counter_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterLogic.apply', () {
    test('adds a positive integer', () {
      final result = CounterLogic.apply(10, '5');
      expect(result.action, CounterAction.increment);
      expect(result.value, 15);
      expect(result.isValid, isTrue);
    });

    test('adds a negative integer', () {
      final result = CounterLogic.apply(10, '-3');
      expect(result.value, 7);
    });

    test('ignores surrounding whitespace in numbers', () {
      expect(CounterLogic.apply(0, '  42 ').value, 42);
    });

    test('resets on the exact command', () {
      final result = CounterLogic.apply(99, resetCommand);
      expect(result.action, CounterAction.reset);
      expect(result.value, 0);
    });

    test('command is case sensitive', () {
      final result = CounterLogic.apply(99, 'avada kedavra');
      expect(result.action, CounterAction.invalid);
      expect(result.value, 99);
    });

    for (final input in ['', '   ', 'abc', '1.5', '2,5', '#!', '5a']) {
      test('rejects "$input" and keeps the value', () {
        final result = CounterLogic.apply(7, input);
        expect(result.action, CounterAction.invalid);
        expect(result.value, 7);
        expect(result.message, isNotNull);
        expect(result.isValid, isFalse);
      });
    }
  });
}
