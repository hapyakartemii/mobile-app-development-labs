/// Human-readable dates for the UI.
abstract final class Formatters {
  /// "щойно", "5 хв тому", "3 год тому", "2 дн тому".
  static String relative(DateTime time, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(time);
    if (diff.inMinutes < 1) return 'щойно';
    if (diff.inHours < 1) return '${diff.inMinutes} хв тому';
    if (diff.inDays < 1) return '${diff.inHours} год тому';
    return '${diff.inDays} дн тому';
  }

  /// "11.11.2026".
  static String date(DateTime time) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(time.day)}.${twoDigits(time.month)}.${time.year}';
  }
}
