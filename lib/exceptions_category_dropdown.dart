import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

TextSpan exceptionsCategoryDropdown(
    appState, context, exception, exceptionNamesAndCategories, type) {
  return TextSpan(
    text: appState.returnTempSelectedNameOrCategory(exception, type),
    style: const TextStyle(
      color: CupertinoColors.activeBlue,
      decoration: TextDecoration.underline,
    ),
    recognizer: TapGestureRecognizer()
      ..onTap = () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 216.0,
              color: CupertinoColors.systemBackground.resolveFrom(context),
              padding: const EdgeInsets.only(top: 6.0),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                top: false,
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: appState.returnInitialSelectedItem(
                        exception, exceptionNamesAndCategories, type),
                  ),
                  onSelectedItemChanged: (int selectedItemInd) {
                    appState.updateTempSelectedItem(exception,
                        exceptionNamesAndCategories[selectedItemInd], type);
                  },
                  children: <Widget>[
                    for (String value in exceptionNamesAndCategories)
                      Center(child: Text(value)),
                  ],
                ),
              ),
            );
          },
        );
      },
  );
}
