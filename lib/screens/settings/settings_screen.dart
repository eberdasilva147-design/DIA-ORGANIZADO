import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/dia_colors.dart';
import '../../utils/l10n_ext.dart';
import '../auth/login_screen.dart';
import '../verse/verse_screen.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final l = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
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
                        style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        auth.user?.email ?? '',
                        style: TextStyle(
                            color: context.colors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Aparência ──────────────────────────────────────────────
          _sectionHeader(l.settingsAppearance),
          _toggleTile(
            context: context,
            icon: Icons.dark_mode_outlined,
            title: l.settingsDarkMode,
            subtitle: l.settingsDarkModeSubtitle,
            value: settings.darkMode,
            onChanged: settings.setDarkMode,
          ),

          const SizedBox(height: 16),

          // ── Idioma ─────────────────────────────────────────────────
          _sectionHeader(l.settingsLanguageSection),
          _languageTile(context, settings),

          const SizedBox(height: 16),

          // ── Notificações ───────────────────────────────────────────
          _sectionHeader(l.settingsNotifications),

          if (!settings.notifications) ...[
            _permissionBanner(context, l),
            const SizedBox(height: 8),
          ],

          _toggleTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: l.settingsNotifications,
            subtitle: l.settingsNotificationsSubtitle,
            value: settings.notifications,
            onChanged: settings.setNotifications,
          ),

          _toggleTile(
            context: context,
            icon: Icons.volume_up_outlined,
            title: l.settingsSound,
            subtitle: l.settingsSoundSubtitle,
            value: settings.sound && settings.notifications,
            onChanged: settings.notifications ? settings.setSound : null,
            disabled: !settings.notifications,
          ),
          _toggleTile(
            context: context,
            icon: Icons.vibration_outlined,
            title: l.settingsVibration,
            subtitle: l.settingsVibrationSubtitle,
            value: settings.vibration && settings.notifications,
            onChanged: settings.notifications ? settings.setVibration : null,
            disabled: !settings.notifications,
          ),
          _toggleTile(
            context: context,
            icon: Icons.do_not_disturb_on_outlined,
            title: l.settingsSilentMode,
            subtitle: l.settingsSilentModeSubtitle,
            value: settings.silentMode && settings.notifications,
            onChanged: settings.notifications
                ? (val) {
                    settings.setSilentMode(val);
                    if (val) {
                      settings.setSound(false);
                      settings.setVibration(false);
                    }
                  }
                : null,
            disabled: !settings.notifications,
          ),

          const SizedBox(height: 8),

          _toggleTile(
            context: context,
            icon: Icons.bedtime_outlined,
            title: l.settingsDoNotDisturb,
            subtitle: l.settingsDoNotDisturbSubtitle,
            value: settings.doNotDisturb,
            onChanged: settings.setDoNotDisturb,
          ),

          _toggleTile(
            context: context,
            icon: Icons.schedule_outlined,
            title: l.settingsQuietHours,
            subtitle: l.settingsQuietHoursSubtitle,
            value: settings.quietHoursEnabled,
            onChanged: settings.setQuietHoursEnabled,
          ),

          if (settings.quietHoursEnabled) ...[
            _quietHoursPicker(context, settings, l),
            const SizedBox(height: 4),
          ],

          const SizedBox(height: 8),

          _toggleTile(
            context: context,
            icon: Icons.repeat_rounded,
            title: l.settingsRecurringReminders,
            subtitle: l.settingsRecurringRemindersSubtitle,
            value: settings.recurringReminders,
            onChanged: settings.setRecurringReminders,
          ),

          const SizedBox(height: 16),

          // ── Outros ─────────────────────────────────────────────────
          _sectionHeader(l.settingsOthers),
          _actionTile(
            context: context,
            icon: Icons.auto_awesome,
            title: l.settingsFavoriteVerses,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const VerseScreen())),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(l.settingsSignOut,
                style: const TextStyle(color: AppColors.error)),
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
          Center(
            child: Text(
              l.settingsVersion,
              style:
                  TextStyle(color: context.colors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets auxiliares ─────────────────────────────────────────────

  Widget _permissionBanner(BuildContext context, AppLocalizations l) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l.settingsPermissionBanner,
                style: TextStyle(color: AppColors.warning, fontSize: 13),
              ),
            ),
          ],
        ),
      );

  Widget _languageTile(BuildContext context, SettingsProvider settings) {
    final l = context.l10n;
    final lang = settings.locale.languageCode;
    final name = _languageName(lang);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: ListTile(
        leading: Icon(Icons.language_outlined,
            color: context.colors.textSecondary),
        title: Text(l.settingsLanguage,
            style: TextStyle(color: context.colors.textPrimary)),
        subtitle: Text(l.settingsLanguageSubtitle,
            style:
                TextStyle(color: context.colors.textSecondary, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name,
                style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: context.colors.textSecondary),
          ],
        ),
        onTap: () => _pickLanguage(context, settings),
      ),
    );
  }

  String _languageName(String code) {
    switch (code) {
      case 'en':
        return 'English (US)';
      case 'es':
        return 'Español (PY)';
      default:
        return 'Português (BR)';
    }
  }

  void _pickLanguage(BuildContext context, SettingsProvider settings) {
    final options = [
      ('pt', '🇧🇷', 'Português (Brasil)'),
      ('en', '🇺🇸', 'English (US)'),
      ('es', '🇵🇾', 'Español (Paraguay)'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 12),
            for (final (code, flag, name) in options)
              ListTile(
                leading: Text(flag, style: const TextStyle(fontSize: 24)),
                title: Text(name,
                    style: TextStyle(color: context.colors.textPrimary)),
                trailing: settings.locale.languageCode == code
                    ? const Icon(Icons.check, color: AppColors.gold)
                    : null,
                onTap: () {
                  settings.setLocale(Locale(code));
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _quietHoursPicker(
          BuildContext context, SettingsProvider settings, AppLocalizations l) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.brightness_3_outlined,
                color: context.colors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.settingsQuietPeriod,
                      style: TextStyle(
                          color: context.colors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _timeButton(
                        context: context,
                        label: l.settingsStart,
                        time: settings.quietHoursStart,
                        onPick: (t) => settings.setQuietHoursStart(t),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(l.settingsTo,
                            style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 13)),
                      ),
                      _timeButton(
                        context: context,
                        label: l.settingsEnd,
                        time: settings.quietHoursEnd,
                        onPick: (t) => settings.setQuietHoursEnd(t),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _timeButton({
    required BuildContext context,
    required String label,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onPick,
  }) =>
      InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
            helpText: label,
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            ),
          );
          if (picked != null) onPick(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(label,
                  style: TextStyle(
                      color: context.colors.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(
                '${time.hour.toString().padLeft(2, '0')}:'
                '${time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );

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
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool disabled = false,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: disabled
              ? context.colors.card.withOpacity(0.5)
              : context.colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: SwitchListTile(
          secondary: Icon(icon,
              color: disabled
                  ? context.colors.textSecondary.withOpacity(0.4)
                  : context.colors.textSecondary),
          title: Text(title,
              style: TextStyle(
                  color: disabled
                      ? context.colors.textPrimary.withOpacity(0.4)
                      : context.colors.textPrimary)),
          subtitle: Text(subtitle,
              style: TextStyle(
                  color: disabled
                      ? context.colors.textSecondary.withOpacity(0.4)
                      : context.colors.textSecondary,
                  fontSize: 12)),
          value: value,
          onChanged: onChanged,
        ),
      );

  Widget _actionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: ListTile(
          leading: Icon(icon, color: context.colors.textSecondary),
          title: Text(title,
              style: TextStyle(color: context.colors.textPrimary)),
          trailing: Icon(Icons.chevron_right,
              color: context.colors.textSecondary),
          onTap: onTap,
        ),
      );
}
