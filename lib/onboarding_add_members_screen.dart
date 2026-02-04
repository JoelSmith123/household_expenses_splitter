import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'styles/app_styles.dart';

class OnboardingAddMembersScreen extends StatefulWidget {
  const OnboardingAddMembersScreen({super.key});

  @override
  State<OnboardingAddMembersScreen> createState() =>
      _OnboardingAddMembersScreenState();
}

class _OnboardingAddMembersScreenState
    extends State<OnboardingAddMembersScreen> {
  final TextEditingController _householdController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _householdController.dispose();
    super.dispose();
  }

  void _continue(AppState appState) {
    final name = _householdController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Please name your household.');
      return;
    }
    setState(() => _errorText = null);
    appState.setHouseholdName(name);
    appState.navigateToPage('onboarding contacts');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Welcome! Add members of your household',
              style: AppText.headline()),
          const SizedBox(height: AppSpacing.md),
          CupertinoTextField(
            controller: _householdController,
            placeholder: 'Household name',
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.deepGreen, width: 2),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_errorText!, style: AppText.caption()),
          ],
          const SizedBox(height: AppSpacing.lg),
          CupertinoButton.filled(
            onPressed: appState.isBusy ? null : () => _continue(appState),
            child: const Text('Import contacts'),
          ),
        ],
      );
    });
  }
}

Widget onboardingAddMembersScreen() => const OnboardingAddMembersScreen();
