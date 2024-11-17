import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';

Widget menuScreen() {
  return Consumer<AppState>(builder: (context, appState, child) {
    return Expanded(
      child: Column(
        children: <Widget>[
          const Spacer(),
          CupertinoButton(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(8.0),
            child: const Text(
              'Config',
              style: TextStyle(
                fontSize: 16.0,
                color: CupertinoColors.white,
              ),
            ),
            onPressed: () {
              appState.navigateToPage('config');
            },
          ),
          const SizedBox(height: 16.0),
          CupertinoButton(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(8.0),
            child: const Text(
              'Exceptions',
              style: TextStyle(
                fontSize: 16.0,
                color: CupertinoColors.white,
              ),
            ),
            onPressed: () {
              appState.navigateToPage('exceptions');
            },
          ),

          // light mode/dark mode switch
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.sun_max,
                      color: CupertinoColors.systemYellow),
                  CupertinoSwitch(
                    value: appState.brightnessModeSwitchValue,
                    activeColor: CupertinoColors.systemGrey,
                    trackColor: CupertinoColors.systemYellow,
                    onChanged: (bool value) {
                      appState.toggleBrightnessMode();
                    },
                  ),
                  const Icon(CupertinoIcons.moon,
                      color: CupertinoColors.systemGrey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}
