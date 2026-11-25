import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/features/profile/widgets/profile_header.dart';
import 'package:flutter_lab1/features/shared/formatters.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';
import 'package:flutter_lab1/features/shared/widgets/app_message.dart';
import 'package:flutter_lab1/features/shared/widgets/async_body.dart';
import 'package:flutter_lab1/features/shared/widgets/confirm_dialog.dart';
import 'package:flutter_lab1/features/shared/widgets/info_tile.dart';
import 'package:flutter_lab1/features/shared/widgets/page_body.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';

/// Signed-in user's profile, loaded with a [FutureBuilder] (see
/// [AsyncBody]): from the server, or the cached copy when offline.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final AppScope _scope = AppScope.of(context);
  late Future<(AppUser, int)> _profile = _load();
  bool _isLoggingOut = false;

  /// The user and how many stations they have.
  Future<(AppUser, int)> _load() async {
    final user = await _scope.authRepository.currentUser();
    if (user == null) {
      throw const AuthException('Сесія закінчилась. Увійдіть знову.');
    }
    final stations = await _scope.stationRepository.getStations(user.id);
    return (user, stations.length);
  }

  Future<void> _logout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Вийти з акаунта?',
      message: 'Сесію буде завершено. Щоб увійти знову, знадобиться інтернет.',
      confirmLabel: 'Вийти',
    );
    if (!confirmed || !mounted) return;
    setState(() => _isLoggingOut = true);
    await _scope.authRepository.logout();
    await _goToLogin();
  }

  Future<void> _goToLogin() async {
    if (!mounted) return;
    await AppRoutes.resetTo(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: AsyncBody<(AppUser, int)>(
        future: _profile,
        onRetry: () => setState(() => _profile = _load()),
        builder: (context, profile) {
          final (user, stationCount) = profile;
          return PageBody(
            maxWidth: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(user: user),
                const SectionHeader(title: 'Особисті дані'),
                Card(
                  child: Column(
                    children: [
                      InfoTile(
                        icon: Icons.person_outline,
                        label: "Ім'я",
                        value: user.name,
                      ),
                      InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      InfoTile(
                        icon: Icons.sensors,
                        label: 'Підключені станції',
                        value: '$stationCount',
                      ),
                      InfoTile(
                        icon: Icons.event_outlined,
                        label: 'Зареєстрований',
                        value: Formatters.date(user.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                AppButton(
                  label: 'Редагувати профіль',
                  icon: Icons.edit_outlined,
                  onPressed: () => showComingSoon(context),
                ),
                const SizedBox(height: AppSpacing.m),
                AppButton(
                  label: 'Вийти',
                  icon: Icons.logout,
                  variant: AppButtonVariant.outlined,
                  isLoading: _isLoggingOut,
                  onPressed: _logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
