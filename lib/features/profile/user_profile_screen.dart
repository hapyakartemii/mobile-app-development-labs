import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:flutter_lab1/features/profile/widgets/profile_header.dart';
import 'package:flutter_lab1/features/shared/formatters.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';
import 'package:flutter_lab1/features/shared/widgets/app_message.dart';
import 'package:flutter_lab1/features/shared/widgets/info_tile.dart';
import 'package:flutter_lab1/features/shared/widgets/page_body.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';

/// Shows the signed-in user's data from the local storage.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final AppScope _scope = AppScope.of(context);
  AppUser? _user;
  int _stationCount = 0;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _scope.authRepository.currentUser();
    if (user == null) return _goToLogin();
    final stations = await _scope.stationRepository.getStations(user.id);
    if (!mounted) return;
    setState(() {
      _user = user;
      _stationCount = stations.length;
    });
  }

  Future<void> _logout() async {
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
    final user = _user;

    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : PageBody(
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
                          value: '$_stationCount',
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
            ),
    );
  }
}
