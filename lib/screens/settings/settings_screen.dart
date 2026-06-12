import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/app_colors.dart';
import '../auth/login_screen.dart';
import '../verse/verse_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    auth.userName.isNotEmpty
                        ? auth.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        auth.user?.email ?? '',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _sectionHeader('Aparência'),
          _toggleTile(
            icon: Icons.dark_mode_outlined,
            title: 'Modo escuro',
            subtitle: 'Visual em tons de azul escuro',
            value: settings.darkMode,
            onChanged: settings.setDarkMode,
          ),

          const SizedBox(height: 16),
          _sectionHeader('Notificações'),
          _toggleTile(
            icon: Icons.notifications_outlined,
            title: 'Notificações',
            subtitle: 'Receber alertas de tarefas',
            value: settings.notifications,
            onChanged: settings.setNotifications,
          ),
          _toggleTile(
            icon: Icons.volume_up_outlined,
            title: 'Som nas notificações',
            subtitle: 'Tocar som ao receber alertas',
            value: settings.sound,
            onChanged: settings.setSound,
          ),
          _toggleTile(
            icon: Icons.repeat_rounded,
            title: 'Lembretes recorrentes',
            subtitle: 'Repetir alertas até confirmação',
            value: settings.recurringReminders,
            onChanged: settings.setRecurringReminders,
          ),

          const SizedBox(height: 16),
          _sectionHeader('Outros'),
          _actionTile(
            icon: Icons.auto_awesome,
            title: 'Versículos favoritos',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const VerseScreen())),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Sair da conta',
                style: TextStyle(color: AppColors.error)),
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),

          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Dia Organizado v1.0.0',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8),
        ),
      );

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: SwitchListTile(
          secondary: Icon(icon, color: AppColors.textSecondary),
          title: Text(title,
              style: const TextStyle(color: AppColors.textPrimary)),
          subtitle: Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          value: value,
          onChanged: onChanged,
        ),
      );

  Widget _actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.textSecondary),
          title: Text(title,
              style: const TextStyle(color: AppColors.textPrimary)),
          trailing: const Icon(Icons.chevron_right,
              color: AppColors.textSecondary),
          onTap: onTap,
        ),
      );
}
