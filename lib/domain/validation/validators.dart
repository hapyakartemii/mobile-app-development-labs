/// Business rules for user input.
///
/// Each rule returns an error message or `null` when the value is valid,
/// so it plugs straight into `TextFormField.validator`. Repositories run
/// the same rules again, so invalid data can't be saved even if the UI
/// is bypassed.
abstract final class Validators {
  static const minPasswordLength = 8;
  static const maxStationNameLength = 30;
  static const maxLocationLength = 50;

  static final _email = RegExp(
    r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
  );
  static final _digit = RegExp(r'\d');
  static final _letter = RegExp('[A-Za-zА-Яа-яІіЇїЄєҐґ]');
  static final _nameChars = RegExp("^[A-Za-zА-Яа-яІіЇїЄєҐґ'’ʼ -]+\$");

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return "Введіть ім'я";
    if (_digit.hasMatch(text)) return "Ім'я не може містити цифр";
    if (!_nameChars.hasMatch(text)) {
      return "Ім'я може містити лише літери, пробіл, дефіс та апостроф";
    }
    if (text.length < 2) return "Ім'я має містити щонайменше 2 літери";
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введіть email';
    if (!_email.hasMatch(text)) {
      return 'Email має містити @ і домен, наприклад name@example.com';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Введіть пароль';
    if (text.length < minPasswordLength) {
      return 'Пароль має містити щонайменше $minPasswordLength символів';
    }
    if (text.contains(' ')) return 'Пароль не може містити пробілів';
    if (!_letter.hasMatch(text) || !_digit.hasMatch(text)) {
      return 'Пароль має містити і літери, і цифри';
    }
    return null;
  }

  /// On login only presence is checked, so the rules aren't revealed.
  static String? requiredPassword(String? value) =>
      (value ?? '').isEmpty ? 'Введіть пароль' : null;

  static String? Function(String?) confirmPassword(String Function() other) {
    return (value) {
      if ((value ?? '').isEmpty) return 'Повторіть пароль';
      return value == other() ? null : 'Паролі не збігаються';
    };
  }

  static String? stationName(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 2) return 'Назва має містити щонайменше 2 символи';
    if (text.length > maxStationNameLength) {
      return 'Назва не довша за $maxStationNameLength символів';
    }
    return null;
  }

  static String? location(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Вкажіть розташування';
    if (text.length > maxLocationLength) {
      return 'Розташування не довше за $maxLocationLength символів';
    }
    return null;
  }

  /// First error among [results], or `null` if all passed.
  static String? firstError(Iterable<String?> results) {
    for (final error in results) {
      if (error != null) return error;
    }
    return null;
  }
}
