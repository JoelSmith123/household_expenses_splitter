import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'styles/app_styles.dart';
import 'widgets/floating_nav_button.dart';

Widget summaryScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg - 4, // 20
                    AppSpacing.lg,
                    AppSpacing.lg - 4, // 20
                    120, // clearance for floating menu button
                  ),
                  child: Column(
                    children: <Widget>[
                      const Text('Summary'),
                      for (var housemate in appState.housemates)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                  '${housemate['name']}\'s share of expenses:'),
                              for (var i = 0;
                                  i < housemate['shareOfExpenses'].length;
                                  i++)
                                Text(
                                    '${housemate['shareOfExpenses'][i]['name']}: \$${housemate['shareOfExpenses'][i]['amount'].toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppSpacing.lg - 4, // 20
          bottom: AppSpacing.lg - 4, // 20
          child: FloatingNavButton.menu(
            onPressed: appState.openMenu,
          ),
        ),
      ],
    );
  });
}
