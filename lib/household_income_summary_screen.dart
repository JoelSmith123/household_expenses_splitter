import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

Widget householdIncomeSummaryScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    return Column(
      children: <Widget>[
        Text(
            'Total household income: \$${appState.totalHouseholdIncome.toStringAsFixed(2)}'),
        for (var housemate in appState.housemates)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
                '${housemate['name']}\'s percentage of household income is ${housemate['percentageOfHouseholdIncome'].toStringAsFixed(2)}%'),
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
              appState.navigateToExpenses();
            },
          ),
        ),
      ],
    );
  });
}
