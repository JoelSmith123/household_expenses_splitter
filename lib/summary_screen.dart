import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

Widget summaryScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Summary'),
        for (var housemate in appState.housemates)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              children: <Widget>[
                Text('${housemate['name']}\'s share of expenses:'),
                for (var i = 0; i < housemate['shareOfExpenses'].length; i++)
                  Text(
                      '${housemate['shareOfExpenses'][i]['name']}: \$${housemate['shareOfExpenses'][i]['amount'].toStringAsFixed(2)}'),
              ],
            ),
          ),
      ],
    );
  });
}
