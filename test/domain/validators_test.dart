import 'package:flutter_lab1/domain/validation/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('name', () {
    test('accepts Ukrainian names with apostrophe and hyphen', () {
      expect(Validators.name("Гап'як Артемій"), isNull);
      expect(Validators.name('Анна-Марія'), isNull);
    });

    test('rejects empty, digits, symbols and too short', () {
      expect(Validators.name('  '), isNotNull);
      expect(Validators.name('Artem1'), "Ім'я не може містити цифр");
      expect(Validators.name('Art@m'), isNotNull);
      expect(Validators.name('A'), isNotNull);
    });
  });

  group('email', () {
    test('accepts valid addresses', () {
      expect(Validators.email('name@example.com'), isNull);
      expect(Validators.email(' first.last+tag@mail.co.ua '), isNull);
    });

    for (final email in ['', 'name', 'name@', 'name@domain', '@x.com']) {
      test('rejects "$email"', () {
        expect(Validators.email(email), isNotNull);
      });
    }
  });

  group('password', () {
    test('accepts 8+ characters with letters and digits', () {
      expect(Validators.password('secret123'), isNull);
    });

    test('rejects short, spaces, no digits or no letters', () {
      expect(Validators.password('abc123'), contains('8 символів'));
      expect(Validators.password('secret 123'), isNotNull);
      expect(Validators.password('onlyletters'), isNotNull);
      expect(Validators.password('12345678'), isNotNull);
    });

    test('confirmation must match', () {
      final confirm = Validators.confirmPassword(() => 'secret123');
      expect(confirm('secret123'), isNull);
      expect(confirm('secret124'), 'Паролі не збігаються');
      expect(confirm(''), isNotNull);
    });
  });

  group('station', () {
    test('name length is limited', () {
      expect(Validators.stationName('Двір'), isNull);
      expect(Validators.stationName('Д'), isNotNull);
      expect(Validators.stationName('Д' * 31), isNotNull);
    });

    test('location is required', () {
      expect(Validators.location('Львів'), isNull);
      expect(Validators.location(' '), isNotNull);
    });
  });
}
