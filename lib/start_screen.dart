import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

Widget startScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    return Column(
      children: <Widget>[
        const Text(
          'First, enter the total net income of the month for each housemate.',
        ),
        for (int i = 0; i < appState.housemates.length; i++)
          CupertinoTextField(
            controller: appState.housematesNetIncomeControllers[i],
            placeholder:
                'Enter ${appState.housemates[i]['name']}\'s net income',
            keyboardType: TextInputType.number,
          ),
        Container(
          margin: EdgeInsets.only(top: 20.0),
          width: double.infinity,
          height: 50.0,
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(
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
