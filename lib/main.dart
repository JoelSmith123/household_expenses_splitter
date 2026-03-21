import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'logo_screen.dart';
import 'generic_error_screen.dart';
import 'signin_screen.dart';
import 'menu_screen.dart';
import 'config_screen.dart';
import 'exceptions_screen.dart';
import 'start_screen.dart';
import 'household_income_summary_screen.dart';
import 'expenses_screen.dart';
import 'summary_screen.dart';
import 'onboarding_profile_screen.dart';
import 'onboarding_invite_screen.dart';
import 'onboarding_add_members_screen.dart';
import 'onboarding_contacts_screen.dart';
import 'onboarding_invite_sent_screen.dart';
import 'styles/app_styles.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class AppInitGate extends StatefulWidget {
  final Widget child;
  const AppInitGate({super.key, required this.child});

  @override
  State<AppInitGate> createState() => _AppInitGateState();
}

class _AppInitGateState extends State<AppInitGate> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ensure this only runs once even if dependencies change.
    if (_started) return;
    _started = true;

    // Kick off initialization after the widget tree exists.
    _init();
  }

  Future<void> _init() async {
    final appState = context.read<AppState>();

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      if (AppConfig.enablePushNotifications) {
        // OneSignal initialization (requires APNs setup). Keeping for future use.
        // Example:
        // OneSignal.initialize(AppConfig.oneSignalAppId);
        // OneSignal.Notifications.requestPermission(true);
      }

      appState.setSupabaseReady(true);
    } catch (e, stackTrace) {
      appState.setSupabaseReady(false);
      appState.setInitError(e, stackTrace);
      // Optionally navigate to your existing error page.
      appState.navigateToPage('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // While initializing, show your existing logo screen (or any loading UI).
    if (!appState.supabaseInitCompleted) {
      return logoScreen();
    }

    return widget.child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider.of<AppState>(context, listen: false).updateBrightnessMode(context);

    return Consumer<AppState>(
      builder: (context, appState, child) {
        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations
                .delegate, // <-- gives MaterialLocalizations
            GlobalWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US')],
          title: 'Flutter Demo',
          theme: CupertinoThemeData(
            brightness: appState.brightnessModeSwitchValue
                ? Brightness.dark
                : Brightness.light,
          ),
          home: const AppInitGate(child: MyHomePage()),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Widget _buildCurrentPage(AppState appState) {
    Widget screen;

    switch (appState.currentPage) {
      case 'logo':
        screen = logoScreen();
        break;
      case 'error':
        screen = genericErrorScreen();
        break;
      case 'menu':
        screen = menuScreen();
        break;
      case 'signin':
        screen = signinScreen();
        break;
      case 'start':
        screen = startScreen();
        break;
      case 'config':
        screen = configScreen();
        break;
      case 'exceptions':
        screen = exceptionsScreen();
        break;
      case 'expenses':
        screen = expensesScreen();
        break;
      case 'summary':
        screen = summaryScreen();
        break;
      case 'household income summary':
        screen = householdIncomeSummaryScreen();
        break;
      case 'onboarding profile':
        screen = onboardingProfileScreen();
        break;
      case 'onboarding invite':
        screen = onboardingInviteScreen();
        break;
      case 'onboarding add members':
        screen = onboardingAddMembersScreen();
        break;
      case 'onboarding contacts':
        screen = onboardingContactsScreen();
        break;
      case 'onboarding invite sent':
        screen = onboardingInviteSentScreen();
        break;
      default:
        screen = logoScreen();
        break;
    }

    return KeyedSubtree(key: ValueKey(appState.currentPage), child: screen);
  }

  @override
  Widget build(BuildContext context) {
    const flowPages = [
      'signin',
      'start',
      'expenses',
      'summary',
      'household income summary',
    ];
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return CupertinoPageScaffold(
          backgroundColor: AppColors.cream,
          navigationBar: appState.showNavigationBar
              ? CupertinoNavigationBar(
                  leading: Builder(
                    builder: (BuildContext context) {
                      IconData icon;
                      if (flowPages.contains(appState.currentPage)) {
                        icon = CupertinoIcons.bars;
                      } else if (appState.currentPage == 'menu') {
                        icon = CupertinoIcons.clear;
                      } else if (appState.currentPage == 'config' ||
                          appState.currentPage == 'exceptions') {
                        icon = CupertinoIcons.back;
                      } else {
                        icon = CupertinoIcons.clear;
                      }
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(icon),
                        onPressed: () {
                          appState.handleMenuButtonPressed(icon);
                        },
                      );
                    },
                  ),
                )
              : null,
          child: SafeArea(
            minimum: const EdgeInsets.all(20.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder:
                  (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
              child: SizedBox.expand(
                child: Align(
                  alignment: Alignment.center,
                  child: _buildCurrentPage(appState),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
