class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String oneSignalAppId = String.fromEnvironment('ONESIGNAL_APP_ID');
  static const bool enablePushNotifications = false;

  // Developer testing overrides
  static const bool enableDebugOverrides = true;
  // Options: 'onboarding profile', 'onboarding invite', 'onboarding add members',
  // 'onboarding contacts', 'onboarding invite sent', 'start'
  static const String? debugOverridePage = 'onboarding profile';
}
