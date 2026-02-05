import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'styles/app_styles.dart';

class OnboardingContactsScreen extends StatefulWidget {
  const OnboardingContactsScreen({super.key});

  @override
  State<OnboardingContactsScreen> createState() =>
      _OnboardingContactsScreenState();
}

class _OnboardingContactsScreenState extends State<OnboardingContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadContacts();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Invite household members', style: AppText.headline()),
          const SizedBox(height: AppSpacing.sm),
          Text('Select contacts to invite.', style: AppText.caption()),
          if (appState.lastErrorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(appState.lastErrorMessage!, style: AppText.caption()),
          ],
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: appState.contactsLoading
                ? const Center(child: CupertinoActivityIndicator())
                : CupertinoScrollbar(
                    child: ListView.separated(
                      itemCount: appState.availableContacts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final contact = appState.availableContacts[index];
                        final selected = appState.selectedContacts
                            .any((item) => item.id == contact.id);
                        return CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              appState.toggleContactSelection(contact),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryGreen.withOpacity(0.12)
                                  : CupertinoColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.deepGreen, width: 1),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(contact.displayName,
                                          style: AppText.body()),
                                      const SizedBox(height: 4),
                                      Text(contact.phoneDisplay,
                                          style: AppText.caption()),
                                    ],
                                  ),
                                ),
                                if (selected)
                                  const Icon(CupertinoIcons.check_mark_circled),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          CupertinoButton.filled(
            onPressed: appState.isBusy || appState.selectedContacts.isEmpty
                ? null
                : () => appState.createHouseholdAndInvites(),
            child: const Text('Complete'),
          ),
        ],
      );
    });
  }
}

Widget onboardingContactsScreen() => const OnboardingContactsScreen();
