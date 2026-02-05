import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import 'providers/app_state.dart';
import 'styles/app_styles.dart';

class OnboardingContactsScreen extends StatefulWidget {
  const OnboardingContactsScreen({super.key});

  @override
  State<OnboardingContactsScreen> createState() =>
      _OnboardingContactsScreenState();
}

class _OnboardingContactsScreenState extends State<OnboardingContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _manualNameController = TextEditingController();
  final TextEditingController _manualPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _manualNameController.dispose();
    _manualPhoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker(BuildContext context, AppState appState) {
    showCountryPicker(
      context: context,
      onSelect: (country) => appState.setSelectedCountry(country),
    );
  }

  void _addManualContact(AppState appState) {
    final name = _manualNameController.text.trim();
    final phone = _manualPhoneController.text.trim();
    appState.addManualContact(name, phone);
    if (appState.lastErrorMessage == null) {
      _manualNameController.clear();
      _manualPhoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, child) {
      final query = _searchController.text.trim().toLowerCase();
      final filteredContacts = query.isEmpty
          ? appState.availableContacts
          : appState.availableContacts
              .where((contact) =>
                  contact.displayName.toLowerCase().contains(query) ||
                  contact.phoneDisplay.toLowerCase().contains(query))
              .toList();

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Invite household members', style: AppText.headline()),
          const SizedBox(height: AppSpacing.sm),
          Text('Select contacts or add manually.', style: AppText.caption()),
          const SizedBox(height: AppSpacing.md),
          CupertinoTextField(
            controller: _searchController,
            placeholder: 'Search contacts',
            onChanged: (_) => setState(() {}),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.deepGreen, width: 2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CupertinoTextField(
                  controller: _manualNameController,
                  placeholder: 'Name',
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.deepGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 3,
                child: CupertinoTextField(
                  controller: _manualPhoneController,
                  placeholder: 'Phone number',
                  keyboardType: TextInputType.phone,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.deepGreen, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                onPressed: () => _showCountryPicker(context, appState),
                child: Text(
                  appState.selectedCountry == null
                      ? 'Pick country'
                      : '${appState.selectedCountry!.flagEmoji} +${appState.selectedCountry!.phoneCode}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CupertinoButton.filled(
                onPressed:
                    appState.isBusy ? null : () => _addManualContact(appState),
                child: const Text('Add'),
              ),
            ],
          ),
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
                      itemCount: filteredContacts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
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
