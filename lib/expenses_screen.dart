import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

Widget expensesScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    return Column(
      children: <Widget>[
        const Text(
          'Next, enter the total amount of each household expense for the month.',
        ),
        for (int i = 0; i < appState.expenses.length; i++)
          CupertinoTextField(
            controller: appState.expensesAmountControllers[i],
            keyboardType: TextInputType.number,
            placeholder:
                'Enter ${appState.expenses[i]['name']}\'s total amount for the month',
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
              appState.updateHousematesShare();
              appState.navigateToPage('summary');
            },
          ),
        ),
      ],
    );
  });
}
