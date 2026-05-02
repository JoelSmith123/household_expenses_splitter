import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'styles/app_styles.dart';
import 'widgets/floating_nav_button.dart';

class _MenuItem {
  final String label;
  final String route;
  const _MenuItem(this.label, this.route);
}

const List<_MenuItem> _menuItems = [
  _MenuItem('Config', 'config'),
  _MenuItem('Exceptions', 'exceptions'),
  _MenuItem('App Settings', 'app settings'),
  _MenuItem('Update month', 'start'),
];

Widget menuScreen() {
  return Consumer<AppState>(
    builder: (context, appState, _) {
      return SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Spacer matches the home screen's app-bar height so the
                // visual rhythm stays consistent when toggling between them.
                const SizedBox(height: 44),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg - 4, // 20
                        0,
                        AppSpacing.lg - 4, // 20
                        120, // clearance for floating close button
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < _menuItems.length; i++) ...[
                            if (i > 0) const SizedBox(height: 28),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              pressedOpacity: 0.5,
                              onPressed: () =>
                                  appState.navigateToPage(_menuItems[i].route),
                              child: Text(
                                _menuItems[i].label,
                                style: AppText.menuItem(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: AppSpacing.lg - 4, // 20
              bottom: 28,
              child: FloatingNavButton.close(
                onPressed: appState.closeMenu,
              ),
            ),
          ],
        ),
      );
    },
  );
}
