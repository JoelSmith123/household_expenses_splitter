import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'exceptions_category_dropdown.dart';
import 'exceptions_save_confirmation.dart';

Widget exceptionsScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    List exceptions = [];
    if (appState.exceptionsEditMode) {
      exceptions = appState.unsavedExceptions;
    } else {
      exceptions = appState.exceptions;
    }

    // Sort the exceptions based on the selected criteria
    // exceptions.sort((a, b) {
    //   if (appState.sortCriteria == 'name') {
    //     return a['name'].compareTo(b['name']);
    //   } else if (appState.sortCriteria == 'category') {
    //     return a['category'].compareTo(b['category']);
    //   }
    //   return 0;
    // });

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
                for (var exception in appState.returnExceptionsForSortCriteria(
                    exceptions, name))
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Center(
                          child: appState.exceptionsEditMode
                              ? exception['edited'] == true
                                  ? const SizedBox(
                                      height:
                                          24.0, // Match height for consistent alignment
                                      width: 24.0,
                                      child: Icon(
                                        CupertinoIcons
                                            .star_fill, // Green asterisk icon
                                        color: CupertinoColors
                                            .systemGreen, // Set the color to green
                                        size:
                                            20.0, // Adjust size to fit the design
                                      ),
                                    )
                                  : Container()
                              : Container(),
                        ),
                        if (exception['type'] == 'REDUCED')
                          Expanded(
                            child: Text.rich(
                              textAlign: TextAlign.start,
                              TextSpan(
                                children: [
                                  appState.exceptionsEditMode
                                      ? TextSpan(children: [
                                          // the inline link for category dropdown
                                          exceptionsCategoryDropdown(
                                              appState,
                                              context,
                                              exception,
                                              appState.exceptionSets
                                                  .housematesWithExceptions
                                                  .toList(),
                                              'name')
                                        ])
                                      : TextSpan(text: exception['name']),
                                  TextSpan(children: [
                                    if (exception['category'] == 'All Expenses')
                                      TextSpan(children: [
                                        TextSpan(
                                            text:
                                                ' pays ${exception['percent'].toStringAsFixed(2)}% of '),
                                        appState.exceptionsEditMode
                                            ?
                                            // the inline link for category dropdown
                                            exceptionsCategoryDropdown(
                                                appState,
                                                context,
                                                exception,
                                                appState.exceptionSets
                                                    .categoriesWithExceptions
                                                    .toList(),
                                                'category')
                                            : const TextSpan(text: 'all'),
                                        const TextSpan(
                                            style: TextStyle(
                                                color: CupertinoColors.black),
                                            text: ' their household expenses.'),
                                      ])
                                    else
                                      TextSpan(children: [
                                        TextSpan(
                                            text:
                                                ' pays ${exception['percent'].toStringAsFixed(2)}% of their normal '),
                                        appState.exceptionsEditMode
                                            ?
                                            // the inline link for category dropdown
                                            exceptionsCategoryDropdown(
                                                appState,
                                                context,
                                                exception,
                                                appState.exceptionSets
                                                    .categoriesWithExceptions
                                                    .toList(),
                                                'category')
                                            : TextSpan(
                                                text: exception['category']),
                                        const TextSpan(
                                            style: TextStyle(
                                                color: CupertinoColors.black),
                                            text: ' charge.'),
                                      ]),
                                  ]),
                                ],
                              ),
                            ),
                          )
                        else if (exception['type'] == 'EXEMPT')
                          Expanded(
                            child: Text.rich(
                              textAlign: TextAlign.start,
                              TextSpan(
                                children: [
                                  appState.exceptionsEditMode
                                      ?
                                      // the inline link for category dropdown
                                      exceptionsCategoryDropdown(
                                          appState,
                                          context,
                                          exception,
                                          appState.exceptionSets
                                              .housematesWithExceptions
                                              .toList(),
                                          'name')
                                      : TextSpan(text: exception['name']),
                                  const TextSpan(
                                      style: TextStyle(
                                          color: CupertinoColors.black),
                                      text: ' is exempt from their '),
                                  appState.exceptionsEditMode
                                      ?
                                      // the inline link for category dropdown
                                      exceptionsCategoryDropdown(
                                          appState,
                                          context,
                                          exception,
                                          appState.exceptionSets
                                              .categoriesWithExceptions
                                              .toList(),
                                          'category')
                                      : TextSpan(text: exception['category']),
                                  const TextSpan(
                                      style: TextStyle(
                                          color: CupertinoColors.black),
                                      text: ' charge.'),
                                ],
                              ),
                            ),
                          ),

                        // delete button for each exception
                        Center(
                          child: appState.exceptionsEditMode
                              ? SizedBox(
                                  height:
                                      24.0, // Match icon height for consistent alignment
                                  width: 24.0,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: const Icon(CupertinoIcons.delete,
                                        size: 20.0),
                                    onPressed: () {
                                      appState.deleteException(exception);
                                    },
                                  ),
                                )
                              : Container(),
                        ),
                      ],
                    ),
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
                  // appState.handleExceptionsEditSaveBtnPressed();
                  if (!appState.exceptionsEditMode) {
                    appState.handleExceptionsEditSaveBtnPressed();
                  } else {
                    showSaveConfirmation(context, appState, exceptions);
                  }
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
