import 'package:flutter/cupertino.dart';

void showSaveConfirmation(BuildContext context, appState, exceptions) {
  Map editedExceptionsByIdsMap = appState.getEditedExceptionsByIdsMap();

  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text(
          'Confirm These Edits?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        message: exceptions.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (var exception in exceptions)
                    if (exception['edited'] == true)
                      Column(children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(children: [
                              const Text('Before: '),
                              Row(
                                children: [
                                  if (exception['type'] == 'REDUCED')
                                    if (exception['category'] == 'All Expenses')
                                      Text(
                                        '${editedExceptionsByIdsMap[exception['id']]['name']} pays ${editedExceptionsByIdsMap[exception['id']]['percent'].toStringAsFixed(2)}% of all their household expenses.',
                                        style: const TextStyle(fontSize: 16),
                                      )
                                    else
                                      Text(
                                        '${editedExceptionsByIdsMap[exception['id']]['name']} pays ${editedExceptionsByIdsMap[exception['id']]['percent'].toStringAsFixed(2)}% of their normal ${editedExceptionsByIdsMap[exception['id']]['category']} charge.',
                                        style: const TextStyle(fontSize: 16),
                                      )
                                  else if (exception['type'] == 'EXEMPT')
                                    Text(
                                      '${editedExceptionsByIdsMap[exception['id']]['name']} is exempt from their ${editedExceptionsByIdsMap[exception['id']]['category']} charge.',
                                      style: const TextStyle(fontSize: 16),
                                    )
                                ],
                              ),
                            ])),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Column(children: [
                              const Text('After: '),
                              Row(
                                children: [
                                  if (exception['type'] == 'REDUCED')
                                    if (exception['category'] == 'All Expenses')
                                      Text(
                                        '${exception['name']} pays ${exception['percent'].toStringAsFixed(2)}% of all their household expenses.',
                                        style: const TextStyle(fontSize: 16),
                                      )
                                    else
                                      Text(
                                        '${exception['name']} pays ${exception['percent'].toStringAsFixed(2)}% of their normal ${exception['category']} charge.',
                                        style: const TextStyle(fontSize: 16),
                                      )
                                  else if (exception['type'] == 'EXEMPT')
                                    Text(
                                      '${exception['name']} is exempt from their ${exception['category']} charge.',
                                      style: const TextStyle(fontSize: 16),
                                    )
                                ],
                              ),
                            ])),
                      ]),
                ],
              )
            : const Text(
                'No changes detected.',
                style: TextStyle(fontSize: 16),
              ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              // Handle save logic here
              appState.saveExceptions();
              appState.toggleExceptionsEditMode();
              Navigator.pop(context); // Close the dialog
            },
            isDefaultAction: true,
            child: const Text('Save'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without saving
            },
            isDestructiveAction: true,
            child: const Text('Cancel'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              appState.initializeUnsavedExceptions();
              appState.notifyListeners();
              Navigator.pop(context); // Close the dialog without saving
            },
            isDestructiveAction: true,
            child: const Text('Cancel & Discard Changes'),
          ),
        ],
      );
    },
  );
}
