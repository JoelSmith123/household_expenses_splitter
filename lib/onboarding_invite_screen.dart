import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'styles/app_styles.dart';

class OnboardingInviteScreen extends StatelessWidget {
  const OnboardingInviteScreen({super.key});

  Future<void> _showDeclineDialog(
      BuildContext context, AppState appState) async {
    final controller = TextEditingController();
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Decline invite?'),
          content: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              const Text('Optional message to the inviter:'),
              const SizedBox(height: AppSpacing.sm),
              CupertinoTextField(
                controller: controller,
                placeholder: 'Add a message (optional)',
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Decline'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final message = controller.text.trim();
      await appState.declineInvite(message.isEmpty ? null : message);
    }
  }

  String _buildInviterText(List<String> names) {
    if (names.isEmpty) return 'Someone';
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]} and ${names[1]}';
    return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, child) {
      final inviterText = _buildInviterText(appState.pendingInviteInviterNames);
      final householdName = appState.pendingInviteHouseholdName ?? 'their';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('You\'ve been invited', style: AppText.headline()),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$inviterText invited you to join $householdName household. Join?',
            style: AppText.body(),
          ),
          const SizedBox(height: AppSpacing.lg),
          CupertinoButton.filled(
            onPressed: appState.isBusy ? null : () => appState.acceptInvite(),
            child: const Text('Join'),
          ),
          const SizedBox(height: AppSpacing.sm),
          CupertinoButton(
            onPressed: appState.isBusy
                ? null
                : () => _showDeclineDialog(context, appState),
            child: const Text('Decline'),
          ),
        ],
      );
    });
  }
}

Widget onboardingInviteScreen() => const OnboardingInviteScreen();
