class AppConfig {
  static const String oneSignalAppId = 'REPLACE_WITH_ONESIGNAL_APP_ID';
  static const bool enablePushNotifications = false;

  // Developer testing overrides
  static const bool enableDebugOverrides = true;
  // Options: 'onboarding profile', 'onboarding invite', 'onboarding add members',
  // 'onboarding contacts', 'onboarding invite sent', 'start'
  static const String? debugOverridePage = 'onboarding profile';
}
