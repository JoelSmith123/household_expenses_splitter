import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'styles/app_styles.dart';
import 'widgets/floating_nav_button.dart';

Widget householdIncomeSummaryScreen() {
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
                      Text(
                          'Total household income: \$${appState.totalHouseholdIncome.toStringAsFixed(2)}'),
                      for (var housemate in appState.housemates)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                              '${housemate['name']}\'s percentage of household income is ${housemate['percentageOfHouseholdIncome'].toStringAsFixed(2)}%'),
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
                            appState.navigateToPage('expenses');
                          },
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
