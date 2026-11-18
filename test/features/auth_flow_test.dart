import 'package:flutter/material.dart';
import 'package:flutter_lab1/data/local/shared_prefs_auth_repository.dart';
import 'package:flutter_lab1/features/auth/login_screen.dart';
import 'package:flutter_lab1/features/auth/registration_screen.dart';
import 'package:flutter_lab1/features/dashboard/main_screen.dart';
import 'package:flutter_lab1/features/profile/user_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_deps.dart';

void main() {
  late TestDeps deps;

  setUp(() async => deps = await TestDeps.create());

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> fillRegistration(
    WidgetTester tester, {
    required String name,
    required String email,
    required String password,
    required String confirm,
  }) async {
    await tester.enterText(field("Ім'я"), name);
    await tester.enterText(field('Email'), email);
    await tester.enterText(field('Пароль'), password);
    await tester.enterText(field('Повторіть пароль'), confirm);
    await tap(tester, find.text('Створити акаунт'));
  }

  testWidgets('without a session the app opens the login screen', (
    tester,
  ) async {
    await tester.pumpWidget(deps.app());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('invalid registration shows errors and saves nothing', (
    tester,
  ) async {
    await tester.pumpWidget(deps.app());
    await tester.pumpAndSettle();
    await tap(tester, find.text('Зареєструватися'));

    await fillRegistration(
      tester,
      name: 'Artem1',
      email: 'artem.example.com',
      password: 'short',
      confirm: 'other',
    );

    expect(find.text("Ім'я не може містити цифр"), findsOneWidget);
    expect(find.textContaining('Email має містити @'), findsOneWidget);
    expect(find.textContaining('щонайменше 8 символів'), findsOneWidget);
    expect(find.text('Паролі не збігаються'), findsOneWidget);
    expect(find.byType(RegistrationScreen), findsOneWidget);
    expect(deps.prefs.getString(SharedPrefsAuthRepository.usersKey), isNull);
  });

  testWidgets('valid registration saves the user and opens the dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(deps.app());
    await tester.pumpAndSettle();
    await tap(tester, find.text('Зареєструватися'));

    await fillRegistration(
      tester,
      name: testName,
      email: testEmail,
      password: testPassword,
      confirm: testPassword,
    );

    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.text('Ще немає станцій'), findsOneWidget);
    expect((await deps.auth.currentUser())?.email, testEmail);
  });

  testWidgets('registration with a taken email shows an error', (tester) async {
    await deps.signUp();
    await deps.auth.logout();
    await tester.pumpWidget(deps.app());
    await tester.pumpAndSettle();
    await tap(tester, find.text('Зареєструватися'));

    await fillRegistration(
      tester,
      name: 'Інший',
      email: testEmail,
      password: 'another123',
      confirm: 'another123',
    );

    expect(find.text('Користувач з таким email уже існує'), findsOneWidget);
    expect(find.byType(RegistrationScreen), findsOneWidget);
  });

  testWidgets('wrong password blocks login and shows an error', (tester) async {
    await deps.signUp();
    await deps.auth.logout();
    await tester.pumpWidget(deps.app());
    await tester.pumpAndSettle();

    await tester.enterText(field('Email'), testEmail);
    await tester.enterText(field('Пароль'), 'wrong1234');
    await tap(tester, find.text('Увійти'));

    expect(find.text('Невірний email або пароль'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('correct credentials open the dashboard', (tester) async {
    await deps.signUp();
    await deps.auth.logout();
    await tester.pumpWidget(deps.app());
    await tester.pumpAndSettle();

    await tester.enterText(field('Email'), testEmail);
    await tester.enterText(field('Пароль'), testPassword);
    await tap(tester, find.text('Увійти'));

    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('saved session skips login; profile shows user; logout works', (
    tester,
  ) async {
    await deps.signUp();
    await tester.pumpWidget(deps.app());
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);

    await tap(tester, find.byTooltip('Профіль'));
    expect(find.byType(UserProfileScreen), findsOneWidget);
    expect(find.text(testName), findsWidgets);
    expect(find.text(testEmail), findsWidgets);

    await tap(tester, find.text('Вийти'));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(await deps.auth.currentUser(), isNull);
  });
}
