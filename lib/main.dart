import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

import 'menu_screen.dart';
import 'config_screen.dart';
import 'start_screen.dart';
import 'household_income_summary_screen.dart';
import 'expenses_screen.dart';
import 'summary_screen.dart';
// testing git stuff

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Provider.of<AppState>(context, listen: false).updateBrightnessMode(context);

    return Consumer<AppState>(builder: (context, appState, child) {
      return CupertinoApp(
        title: 'Flutter Demo',
        theme: CupertinoThemeData(
          brightness: appState.brightnessModeSwitchValue
              ? Brightness.dark
              : Brightness.light,
        ),
        home: MyHomePage(),
      );
    });
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const flowPages = [
      'start',
      'expenses',
      'summary',
      'household income summary'
    ];
    return Consumer<AppState>(builder: (context, appState, child) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Builder(
            builder: (BuildContext context) {
              IconData icon;
              if (flowPages.contains(appState.currentPage)) {
                icon = CupertinoIcons.bars;
              } else if (appState.currentPage == 'menu') {
                icon = CupertinoIcons.clear;
              } else if (appState.currentPage == 'config') {
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
                if (appState.currentPage == 'start') startScreen(),
                if (appState.currentPage == 'config') configScreen(),
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
