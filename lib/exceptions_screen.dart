import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

Widget exceptionsScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    List exceptions = appState.exceptions;

    // Sort the exceptions based on the selected criteria
    exceptions.sort((a, b) {
      if (appState.sortCriteria == 'name') {
        return a['name'].compareTo(b['name']);
      } else if (appState.sortCriteria == 'category') {
        return a['category'].compareTo(b['category']);
      }
      return 0;
    });

    return Expanded(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Group by: '),
                CupertinoSegmentedControl<String>(
                  children: const {
                    'name': Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('name'),
                    ),
                    'category': Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('category'),
                    ),
                  },
                  groupValue: appState.sortCriteria,
                  onValueChanged: (String newValue) {
                    appState.updateSortCriteria(newValue);
                  },
                ),
              ],
            ),
          ),
          Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // The list of exceptions
              for (var name
                  in appState.returnExceptionSetForSortCriteria()) ...[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Text(
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          name),
                    ),
                  ],
                ),
                for (var exception
                    in appState.returnExceptionsForSortCriteria(name))
                  Row(
                    children: <Widget>[
                      if (exception['type'] == 'REDUCED')
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              exception['category'] == 'All Expenses'
                                  ? '${exception['name']} pays ${exception['percent'].toStringAsFixed(2)}% of all their household expenses.'
                                  : '${exception['name']} pays ${exception['percent'].toStringAsFixed(2)}% of their normal ${exception['category']} charge.',
                            ),
                          ),
                        )
                      else if (exception['type'] == 'EXEMPT')
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              '${exception['name']} is exempt from their ${exception['category']} charge.',
                            ),
                          ),
                        ),
                      if (appState.exceptionsEditMode)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.delete),
                          onPressed: () {
                            appState.exceptions.remove(exception);
                          },
                        ),
                    ],
                  ),
              ],
            ],
          ),

          // edit/save button
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: SizedBox(
              width: 100, // Adjust the width as needed
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: appState.exceptionsEditMode
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.white,
                    border: appState.exceptionsEditMode
                        ? null
                        : Border.all(color: CupertinoColors.activeBlue),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        appState.exceptionsEditMode
                            ? CupertinoIcons.floppy_disk
                            : CupertinoIcons.pencil,
                        color: appState.exceptionsEditMode
                            ? CupertinoColors.white
                            : CupertinoColors.activeBlue,
                      ),
                      const SizedBox(
                          width:
                              4.0), // Add some space between the icon and the text
                      Text(
                        appState.exceptionsEditMode ? 'Save' : 'Edit',
                        style: TextStyle(
                          color: appState.exceptionsEditMode
                              ? CupertinoColors.white
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: () {
                  appState.toggleExceptionsEditMode();
                },
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  });
}
