/// Configuração do Supabase.
///
/// Duas formas de configurar:
/// 1. Substitua os valores default abaixo pelos do seu projeto
///    (Supabase Dashboard → Settings → API).
/// 2. Ou passe via linha de comando / CI:
///    flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// A anon key é pública por design (a segurança vem das políticas RLS
/// no banco), então não há problema em commitá-la no repositório.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://SEU-PROJETO.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'SUA_ANON_KEY',
  );

  /// Enquanto não configurado, o app roda em modo local (sem nuvem).
  static bool get isConfigured =>
      !url.contains('SEU-PROJETO') && anonKey != 'SUA_ANON_KEY';
}
