import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

Widget configScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    final fieldText = TextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Customize Housemates'),
        for (var housemate in appState.housemates)
          Row(
            children: <Widget>[
              Text(housemate['name']),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.delete),
                onPressed: () {
                  appState.housemates.remove(housemate);
                },
              ),
            ],
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: CupertinoTextField(
                controller: fieldText,
                keyboardType: TextInputType.text,
                placeholder: 'Enter a new housemate\'s name',
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.plus),
              onPressed: () {
                appState.housemates.add({
                  'name': fieldText.text,
                  'netIncome': 0,
                  'percentageOfHouseholdIncome': 0,
                });
                fieldText.clear();
              },
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 60.0),
          child: Text('Customize Expenses'),
        ),
        for (var expense in appState.expenses)
          Row(
            children: <Widget>[
              Text(expense['name']),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.delete),
                onPressed: () {
                  appState.expenses.remove(expense);
                },
              ),
            ],
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: CupertinoTextField(
                controller: fieldText,
                keyboardType: TextInputType.text,
                placeholder: 'Enter a new expense\'s name',
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.plus),
              onPressed: () {
                appState.expenses.add({
                  'name': fieldText.text,
                  'amount': 0,
                });
                fieldText.clear();
              },
            ),
          ],
        ),
      ],
    );
  });
}
