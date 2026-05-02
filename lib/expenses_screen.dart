import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'styles/app_styles.dart';
import 'widgets/floating_nav_button.dart';

Widget expensesScreen() {
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
