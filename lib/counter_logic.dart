/// Command that resets the counter to zero.
const String resetCommand = 'Avada Kedavra';

/// Kind of result produced by [CounterLogic.apply].
enum CounterAction { increment, reset, invalid }

/// Result of processing a single user input.
class CounterResult {
  const CounterResult({
    required this.action,
    required this.value,
    this.message,
  });

  /// What happened with the input.
  final CounterAction action;

  /// Counter value after the input was processed.
  final int value;

  /// Human-readable error for [CounterAction.invalid].
  final String? message;

  bool get isValid => action != CounterAction.invalid;
}

/// Pure business logic of the counter, independent of Flutter widgets.
class CounterLogic {
  const CounterLogic._();

  /// Validates [input] and computes the new counter value from [current].
  ///
  /// * an integer (including negative) is added to the counter;
  /// * exactly [resetCommand] resets the counter to zero;
  /// * anything else is rejected and the counter stays unchanged.
  static CounterResult apply(int current, String input) {
    if (input == resetCommand) {
      return const CounterResult(action: CounterAction.reset, value: 0);
    }

    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return CounterResult(
        action: CounterAction.invalid,
        value: current,
        message: 'Поле порожнє. Введіть ціле число або "$resetCommand".',
      );
    }

    final number = int.tryParse(trimmed);
    if (number == null) {
      return CounterResult(
        action: CounterAction.invalid,
        value: current,
        message: '"$trimmed" не є цілим числом або командою "$resetCommand".',
      );
    }

    return CounterResult(
      action: CounterAction.increment,
      value: current + number,
    );
  }
}
