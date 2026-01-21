import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

Widget genericErrorScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    if (appState.currentErrorToShow == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(appState.currentErrorToShow!.title),
        Text(appState.currentErrorToShow!.message),
        ],
    );
  });
}
