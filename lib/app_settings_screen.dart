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
                        const SizedBox(height: AppSpacing.lg),
                        Text('ACCOUNT', style: AppText.sectionLabel()),
                        const SizedBox(height: AppSpacing.sm),
                        _SettingsCard(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 14,
                            ),
                            onPressed: () =>
                                _confirmSignOut(context, appState),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.square_arrow_right,
                                  color: AppColors.balanceNegative,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Sign out',
                                    style: AppText.cardItemTitle().copyWith(
                                      color: AppColors.balanceNegative,
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

Future<void> _confirmSignOut(BuildContext context, AppState appState) async {
  final shouldSignOut = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: const Text('Sign out?'),
      content: const Text(
        "You'll need to verify your phone number to sign back in.",
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );
  if (shouldSignOut == true) {
    await appState.signOut();
  }
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
