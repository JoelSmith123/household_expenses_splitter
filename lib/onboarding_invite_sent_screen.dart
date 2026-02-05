import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'styles/app_styles.dart';

class OnboardingInviteSentScreen extends StatelessWidget {
  const OnboardingInviteSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Invites sent!', style: AppText.headline()),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We\'ve sent them an invite. Hold tight, and we\'ll notify you once they\'ve joined.',
            style: AppText.body(),
          ),
          const SizedBox(height: AppSpacing.lg),
          CupertinoButton.filled(
            onPressed: () => appState.navigateToPage('start'),
            child: const Text('Continue'),
          ),
        ],
      );
    });
  }
}

Widget onboardingInviteSentScreen() => const OnboardingInviteSentScreen();
