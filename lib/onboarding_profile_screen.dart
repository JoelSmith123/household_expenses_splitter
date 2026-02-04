import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'styles/app_styles.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState appState) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Please enter your name.');
      return;
    }
    setState(() => _errorText = null);
    await appState.completeProfileName(name);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tell us your name', style: AppText.headline()),
            const SizedBox(height: AppSpacing.md),
            CupertinoTextField(
              controller: _nameController,
              placeholder: 'Full name',
              onSubmitted: (_) => _submit(appState),
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
              onPressed: () => _submit(appState),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}

Widget onboardingProfileScreen() => const OnboardingProfileScreen();
