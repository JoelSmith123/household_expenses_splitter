import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'signin_screen.dart';
import 'menu_screen.dart';
import 'config_screen.dart';
import 'exceptions_screen.dart';
import 'start_screen.dart';
import 'household_income_summary_screen.dart';
import 'expenses_screen.dart';
import 'summary_screen.dart';
// testing git stuff

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wfotybsrulygfaucjcpa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indmb3R5YnNydWx5Z2ZhdWNqY3BhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgzMDkwMzQsImV4cCI6MjA1Mzg4NTAzNH0.kudmu74JQfGfQJ1_63tialCwtkPKOdg9XM08liuCpnk',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider.of<AppState>(context, listen: false).updateBrightnessMode(context);

    return Consumer<AppState>(builder: (context, appState, child) {
      return CupertinoApp(
              debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations
              .delegate, // <-- gives MaterialLocalizations
          GlobalWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
        ],
        title: 'Flutter Demo',
        theme: CupertinoThemeData(
          brightness: appState.brightnessModeSwitchValue
              ? Brightness.dark
              : Brightness.light,
        ),
        home: const MyHomePage(),
      );
    });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const flowPages = [
      'signin',
      'start',
      'expenses',
      'summary',
      'household income summary'
    ];
    return Consumer<AppState>(builder: (context, appState, child) {
      return CupertinoPageScaffold(
        backgroundColor: Color(0xFFf9f5d2),
        navigationBar: CupertinoNavigationBar(
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
          middle: Text(appState.currentPage),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (appState.currentPage == 'menu') menuScreen(),
                if (appState.currentPage == 'signin') signinScreen(),
                if (appState.currentPage == 'start') startScreen(),
                if (appState.currentPage == 'config') configScreen(),
                if (appState.currentPage == 'exceptions') exceptionsScreen(),
                if (appState.currentPage == 'expenses') expensesScreen(),
                if (appState.currentPage == 'summary') summaryScreen(),
                if (appState.currentPage == 'household income summary')
                  householdIncomeSummaryScreen(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
