import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'styles/app_styles.dart';
import 'widgets/floating_nav_button.dart';

Widget appSettingsScreen() {
  return Consumer<AppState>(
    builder: (context, appState, _) {
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
                      120, // clearance for floating back button
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('APPEARANCE', style: AppText.sectionLabel()),
                        const SizedBox(height: AppSpacing.sm),
                        _SettingsCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.sun_max,
                                  color: CupertinoColors.systemYellow,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Dark mode',
                                    style: AppText.cardItemTitle(),
                                  ),
                                ),
                                CupertinoSwitch(
                                  value: appState.brightnessModeSwitchValue,
                                  activeTrackColor: AppColors.deepGreen,
                                  onChanged: (_) =>
                                      appState.toggleBrightnessMode(),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Icon(
                                  CupertinoIcons.moon,
                                  color: AppColors.muted,
                                ),
                              ],
                            ),
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
            child: FloatingNavButton.back(
              onPressed: () => appState.navigateToPage('menu'),
            ),
          ),
        ],
      );
    },
  );
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}
