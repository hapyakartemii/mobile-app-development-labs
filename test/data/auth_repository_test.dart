import 'package:flutter_lab1/data/local/shared_prefs_auth_repository.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_deps.dart';

void main() {
  late TestDeps deps;

  setUp(() async => deps = await TestDeps.create());

  test('register saves the user and starts a session', () async {
    final user = await deps.signUp();

    expect(user.name, testName);
    expect((await deps.auth.currentUser())?.id, user.id);
  });

  test('password is stored only as a hash', () async {
    await deps.signUp();

    final raw = deps.prefs.getString(SharedPrefsAuthRepository.usersKey);
    expect(raw, isNot(contains(testPassword)));
  });

  test('email is case-insensitive and must be unique', () async {
    await deps.signUp();

    expect(
      () => deps.auth.register(
        name: 'Інший',
        email: ' ARTEM@example.com ',
        password: 'another123',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('register rejects invalid data', () {
    expect(
      () => deps.auth.register(name: 'A1', email: 'x', password: '1'),
      throwsA(isA<AuthException>()),
    );
  });

  test('login succeeds with the right password', () async {
    await deps.signUp();
    await deps.auth.logout();

    final user = await deps.auth.login(
      email: 'Artem@Example.com',
      password: testPassword,
    );
    expect(user.email, testEmail);
    expect(await deps.auth.currentUser(), isNotNull);
  });

  test('login fails with a wrong password or unknown email', () async {
    await deps.signUp();
    await deps.auth.logout();

    for (final (email, password) in [
      (testEmail, 'wrong1234'),
      ('nobody@example.com', testPassword),
    ]) {
      await expectLater(
        deps.auth.login(email: email, password: password),
        throwsA(isA<AuthException>()),
      );
    }
    expect(await deps.auth.currentUser(), isNull);
  });

  test('session survives a new repository instance (app restart)', () async {
    final user = await deps.signUp();

    final restarted = SharedPrefsAuthRepository(deps.prefs);
    expect((await restarted.currentUser())?.id, user.id);
  });

  test('logout ends the session', () async {
    await deps.signUp();
    await deps.auth.logout();

    expect(await deps.auth.currentUser(), isNull);
  });
}
