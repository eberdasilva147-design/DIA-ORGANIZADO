import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/note_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/verse_provider.dart';
import 'services/data_service.dart';
import 'services/local_data_service.dart';
import 'services/supabase_data_service.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Se o Supabase estiver configurado, usa a nuvem (com login);
  // senão, roda em modo local (dados salvos no dispositivo, sem login).
  bool cloudReady = false;
  try {
    if (SupabaseConfig.isConfigured) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
      );
      cloudReady = true;
    }
  } catch (e) {
    debugPrint('Supabase não configurado: $e');
  }

  if (cloudReady) {
    DataService.instance = SupabaseDataService();
  } else {
    final local = LocalDataService();
    await local.init();
    DataService.instance = local;
  }

  await NotificationService().init();
  await initializeDateFormatting('pt_BR', null);

  runApp(DiaOrganizadoApp(localMode: !cloudReady));
}

class DiaOrganizadoApp extends StatelessWidget {
  /// Em modo local não há login: o splash vai direto para a Home.
  final bool localMode;
  const DiaOrganizadoApp({super.key, this.localMode = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(localMode: localMode)),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => VerseProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (_, settings, __) => MaterialApp(
          title: 'Dia Organizado',
          debugShowCheckedModeBanner: false,
          theme: settings.darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
