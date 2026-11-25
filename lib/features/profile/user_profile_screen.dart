import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/features/profile/widgets/flashlight_easter_egg.dart';
import 'package:flutter_lab1/features/profile/widgets/profile_header.dart';
import 'package:flutter_lab1/features/shared/formatters.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';
import 'package:flutter_lab1/features/shared/widgets/app_message.dart';
import 'package:flutter_lab1/features/shared/widgets/confirm_dialog.dart';
import 'package:flutter_lab1/features/shared/widgets/info_tile.dart';
import 'package:flutter_lab1/features/shared/widgets/page_body.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';
import 'package:flutter_lab1/logic/auth/auth_cubit.dart';
import 'package:flutter_lab1/logic/auth/auth_state.dart';
import 'package:flutter_lab1/logic/stations/stations_cubit.dart';

/// Profile drawn from the global state: the user from [AuthCubit], the
/// station count from [StationsCubit]. Logout goes through [AuthCubit];
/// [AppShell] then opens the login screen.
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Вийти з акаунта?',
      message: 'Сесію буде завершено. Щоб увійти знову, знадобиться інтернет.',
      confirmLabel: 'Вийти',
    );
    if (confirmed) await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final stationCount = context.select(
      (StationsCubit cubit) => cubit.state.stations.length,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return PageBody(
            maxWidth: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Easter egg: long press on the avatar = flashlight.
                FlashlightEasterEgg(child: ProfileHeader(user: user)),
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
                  isLoading: state.isSubmitting,
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
