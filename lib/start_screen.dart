import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

Widget startScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'First, enter your total net income this month.',
        ),
        const Text(
          '(This should be your entire "take-home" amount for the month, the amount that you bring home in your paycheck after taxes.)',
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        CupertinoTextField(
          placeholder: 'Enter ${appState.currentUserName}\'s net income',
          keyboardType: TextInputType.number,
          onChanged: (String value) {
            final parsed = double.tryParse(value);
            appState.updateTempCurrentUserNetIncomeCurrentMonth(parsed);
          },
        ),
        Container(
          margin: const EdgeInsets.only(top: 20.0),
          width: double.infinity,
          height: 50.0,
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text(
              'Next',
              style: TextStyle(color: CupertinoColors.white),
            ),
            onPressed: () {
              appState.updateHousematesIncome();
              appState.navigateToPage('household income summary');
            },
          ),
        ),
      ],
    );
  });
}
