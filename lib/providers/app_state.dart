import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class AppState extends ChangeNotifier {
  late final SupabaseClient supabase;

  // constructor
  AppState();

  Future<void> _init() async {
    // initialize UI/view after controller initialization and data retrieval
    initializeView();
  }

  bool isBusy = false;
  String? lastErrorMessage;

  Future<void> getData() async {
    try {
      await Future.wait([
        getHousemates(),
        getExpenses(),
        getExceptions(),
      ]);
      _initializeControllers();
    } catch (e, stackTrace) {
      currentErrorToShow = GenericError(
        isCurrent: true,
        title: e.toString(),
        message: stackTrace.toString(),
      );
      navigateToPage('error');
      notifyListeners();
    }
  }

  // controllers
  List<TextEditingController> housematesNetIncomeControllers = [];
  List<TextEditingController> expensesAmountControllers = [];
  ExceptionSets exceptionSets = ExceptionSets(
    housematesWithExceptions: {},
    categoriesWithExceptions: {},
  );

  // initialize controllers
  void _initializeControllers() {
    housematesNetIncomeControllers =
        List.generate(housemates.length, (index) => TextEditingController());
    expensesAmountControllers =
        List.generate(expenses.length, (index) => TextEditingController());

    // we initialize unsaved exceptions here because they need to exist before UI elements on edit depend on them and there's no reason they can't exist this early. All that matters is that they are saved and reset properly later.
    initializeUnsavedExceptions();

    initializeExceptionSets();
  }

  // dispose controllers
  @override
  void dispose() {
    for (var controller in housematesNetIncomeControllers) {
      controller.dispose();
    }
    for (var controller in expensesAmountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  //
  // supabase initializations
  //

  bool supabaseInitCompleted = false;
  void setSupabaseReady(bool isReady) {
    if (isReady) {
      supabase = Supabase.instance.client;
      _init();
    }
    supabaseInitCompleted = isReady;
    notifyListeners();
  }

  void setInitError(Object e, StackTrace stackTrace) {
    currentErrorToShow = GenericError(
      isCurrent: true,
      title: e.toString(),
      message: stackTrace.toString(),
    );
    notifyListeners();
  }

  //
  // initializeView()
  //

  void initializeView() {
    // delay for testing
    Future.delayed(const Duration(seconds: 2), () => navigateToPage('signin'));

    // without delay:
    // navigateToPage('signin');
  }

  //
  // auth
  //

  bool signedIn = false;
  void setSignedIn(bool newSignedInStatus) async {
    signedIn = newSignedInStatus;
    notifyListeners();
  }

  String? currentUserName;
  int? currentUserId;
  int? currentHouseholdId;
  String? currentUserPhoneE164;
  String? householdName;
  String? pendingProfileName;

  //
  // onboarding/invites
  //

  PendingInvite? pendingInvite;
  String? pendingInviteHouseholdName;
  List<String> pendingInviteInviterNames = [];

  //
  // contacts/invites selection
  //

  List<InviteContact> availableContacts = [];
  List<InviteContact> selectedContacts = [];
  bool contactsLoading = false;

  //
  // onboarding/auth orchestration
  //

  Future<void> handleSignedIn() async {
    if (!supabaseInitCompleted) return;
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return;

    currentUserPhoneE164 = authUser.phone;
    if (AppConfig.enablePushNotifications) {
      // OneSignal registration requires APNs setup. Keeping for future use.
      // await registerOneSignalPlayerId();
    }
    if (_applyDebugOverrideIfNeeded()) {
      return;
    }
    await ensureUserProfile();
  }

  Future<void> registerOneSignalPlayerId() async {
    // Pseudocode:
    // final playerId = OneSignal.User.pushSubscription.id;
    // if (playerId == null || playerId.isEmpty) return;
    // oneSignalPlayerId = playerId;
    // if (currentUserId != null) {
    //   await supabase
    //       .from('users')
    //       .update({'onesignal_player_id': playerId}).eq('id', currentUserId!);
    // }
  }

  String? oneSignalPlayerId;

  Future<void> ensureUserProfile() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return;
    final authId = authUser.id;
    final phone = currentUserPhoneE164;

    final existingByAuth = await supabase
        .from('users')
        .select()
        .eq('auth_user_id', authId)
        .maybeSingle();

    if (existingByAuth != null) {
      currentUserId = existingByAuth['id'] as int?;
      currentUserName = existingByAuth['display_name'] as String?;
      currentHouseholdId = existingByAuth['household_id'] as int?;
      if (AppConfig.enablePushNotifications) {
        // OneSignal registration update (requires APNs setup).
        // if (oneSignalPlayerId != null && currentUserId != null) {
        //   await supabase.from('users').update({
        //     'onesignal_player_id': oneSignalPlayerId,
        //   }).eq('id', currentUserId!);
        // }
      }
      if (currentUserName == null || currentUserName!.trim().isEmpty) {
        navigateToPage('onboarding profile');
        return;
      }
      await checkPendingInvite();
      return;
    }

    if (phone != null && phone.isNotEmpty) {
      final existingByPhone = await supabase
          .from('users')
          .select()
          .eq('phone_e164', phone)
          .maybeSingle();
      if (existingByPhone != null) {
        currentUserId = existingByPhone['id'] as int?;
        currentUserName = existingByPhone['display_name'] as String?;
        currentHouseholdId = existingByPhone['household_id'] as int?;
        if (currentUserName == null || currentUserName!.trim().isEmpty) {
          navigateToPage('onboarding profile');
          return;
        }
        await supabase.from('users').update({
          'auth_user_id': authId,
          // 'onesignal_player_id': oneSignalPlayerId,
        }).eq('id', currentUserId!);
        await checkPendingInvite();
        return;
      }
    }

    navigateToPage('onboarding profile');
  }

  Future<void> completeProfileName(String name) async {
    if (currentUserId != null) {
      isBusy = true;
      notifyListeners();
      try {
        await supabase
            .from('users')
            .update({'display_name': name}).eq('id', currentUserId!);
        currentUserName = name;
        if (currentHouseholdId != null) {
          await getData();
          navigateToPage('start');
        } else {
          await checkPendingInvite();
        }
      } finally {
        isBusy = false;
        notifyListeners();
      }
      return;
    }

    pendingProfileName = name;
    currentUserName = name;
    notifyListeners();
    await checkPendingInvite();
  }

  Future<void> _ensureUserForHousehold(int householdId) async {
    if (currentUserId != null) {
      if (currentHouseholdId != householdId) {
        await supabase
            .from('users')
            .update({'household_id': householdId}).eq('id', currentUserId!);
        currentHouseholdId = householdId;
      }
      return;
    }

    final authUser = supabase.auth.currentUser;
    if (authUser == null) return;
    final displayName = pendingProfileName ?? currentUserName;
    if (displayName == null || displayName.trim().isEmpty) return;

    final data = await supabase.from('users').upsert({
      'auth_user_id': authUser.id,
      'display_name': displayName,
      'phone_e164': currentUserPhoneE164,
      'household_id': householdId,
      // 'onesignal_player_id': oneSignalPlayerId,
    }).select().maybeSingle();

    if (data != null) {
      currentUserId = data['id'] as int?;
      currentUserName = data['display_name'] as String?;
      currentHouseholdId = data['household_id'] as int?;
    }
  }

  Future<void> checkPendingInvite() async {
    if (currentHouseholdId != null) {
      await getData();
      navigateToPage('start');
      return;
    }

    final phone = currentUserPhoneE164;
    if (phone == null || phone.isEmpty) {
      navigateToPage('onboarding add members');
      return;
    }

    final inviteData = await supabase
        .from('household_invites')
        .select()
        .eq('invited_phone_e164', phone)
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (inviteData == null) {
      navigateToPage('onboarding add members');
      return;
    }

    pendingInvite = PendingInvite.fromJson(inviteData);
    await _loadInviteContext();
    navigateToPage('onboarding invite');
  }

  Future<void> _loadInviteContext() async {
    if (pendingInvite == null) return;
    final householdData = await supabase
        .from('households')
        .select('name')
        .eq('id', pendingInvite!.householdId)
        .maybeSingle();
    pendingInviteHouseholdName =
        householdData == null ? null : householdData['name'] as String?;

    if (pendingInvite!.inviterUserIds.isNotEmpty) {
      final inviterData = await supabase
          .from('users')
          .select('id,display_name')
          .inFilter('id', pendingInvite!.inviterUserIds);
      pendingInviteInviterNames = inviterData
          .map<String>((row) => row['display_name'] as String? ?? 'Unknown')
          .toList();
    } else {
      pendingInviteInviterNames = [];
    }
  }

  Future<void> acceptInvite() async {
    if (pendingInvite == null) return;
    isBusy = true;
    notifyListeners();
    try {
      await _ensureUserForHousehold(pendingInvite!.householdId);
      if (currentUserId == null) return;
      await supabase.from('household_invites').update({
        'status': 'accepted',
        'responded_at': DateTime.now().toIso8601String(),
      }).eq('id', pendingInvite!.id);

      if (AppConfig.enablePushNotifications) {
        // OneSignal/APNs not configured. Enable when ready:
        // await supabase.functions.invoke('send-invite-accepted-push', body: {
        //   'household_id': pendingInvite!.householdId,
        //   'inviter_user_ids': pendingInvite!.inviterUserIds,
        //   'accepted_user_name': currentUserName ?? 'Someone',
        // });
      }

      await getData();
      navigateToPage('start');
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> declineInvite(String? message) async {
    if (pendingInvite == null) return;
    isBusy = true;
    notifyListeners();
    try {
      await supabase.from('household_invites').update({
        'status': 'declined',
        'responded_at': DateTime.now().toIso8601String(),
        'decline_message': message,
      }).eq('id', pendingInvite!.id);

      await supabase.auth.signOut();
      resetToSigninFlow();
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void resetToSigninFlow() {
    signedIn = false;
    pendingInvite = null;
    pendingInviteHouseholdName = null;
    pendingInviteInviterNames = [];
    currentUserId = null;
    currentUserName = null;
    currentHouseholdId = null;
    pendingProfileName = null;
    selectedContacts = [];
    availableContacts = [];
    householdName = null;
    navigateToPage('logo');
    Future.delayed(const Duration(seconds: 2), () => navigateToPage('signin'));
  }

  void setHouseholdName(String name) {
    householdName = name;
    notifyListeners();
  }

  Future<void> createHouseholdAndInvites() async {
    if (householdName == null) return;
    if (selectedContacts.isEmpty) return;
    isBusy = true;
    notifyListeners();
    try {
      final householdData = await supabase
          .from('households')
          .insert({'name': householdName}).select().maybeSingle();
      if (householdData == null) return;

      final householdId = householdData['id'] as int;
      await _ensureUserForHousehold(householdId);
      if (currentUserId == null) return;

      final inviteRows = selectedContacts
          .map((contact) => {
                'household_id': householdId,
                'invited_phone_e164': contact.phoneE164,
                'inviter_user_ids': [currentUserId],
                'status': 'pending',
              })
          .toList();

      await supabase.from('household_invites').upsert(inviteRows);

      await supabase.functions.invoke('send-household-invite', body: {
        'household_id': householdId,
        'inviter_user_ids': [currentUserId],
        'invites': selectedContacts
            .map((contact) => {
                  'phone_e164': contact.phoneE164,
                  'display_name': contact.displayName,
                })
            .toList(),
      });

      await getData();
      navigateToPage('onboarding invite sent');
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> loadContacts() async {
    if (contactsLoading) return;
    contactsLoading = true;
    lastErrorMessage = null;
    availableContacts = [];
    notifyListeners();
    try {
      final permissionGranted = await FlutterContacts.requestPermission();
      if (!permissionGranted) {
        lastErrorMessage = 'Contacts permission denied.';
        return;
      }
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );
      availableContacts = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map((contact) {
            final phoneDisplay = contact.phones.first.number;
            final phoneE164 = normalizeToE164(phoneDisplay);
            return InviteContact(
              id: contact.id,
              displayName: contact.displayName,
              phoneE164: phoneE164,
              phoneDisplay: phoneDisplay,
            );
          })
          .toList();
    } catch (e) {
      lastErrorMessage = 'Unable to load contacts.';
    } finally {
      contactsLoading = false;
      notifyListeners();
    }
  }

  void toggleContactSelection(InviteContact contact) {
    lastErrorMessage = null;
    final existingIndex =
        selectedContacts.indexWhere((item) => item.id == contact.id);
    if (existingIndex >= 0) {
      selectedContacts.removeAt(existingIndex);
    } else {
      selectedContacts.add(contact);
    }
    notifyListeners();
  }

  void addManualContact(String name, String phoneRaw) {
    lastErrorMessage = null;
    if (name.isEmpty || phoneRaw.isEmpty) {
      lastErrorMessage = 'Name and phone are required.';
      notifyListeners();
      return;
    }
    final phoneE164 = normalizeToE164(phoneRaw);
    if (!phoneE164.startsWith('+')) {
      lastErrorMessage = 'Please select a country or enter +country code.';
      notifyListeners();
      return;
    }
    final id = 'manual-${DateTime.now().millisecondsSinceEpoch}';
    selectedContacts.add(InviteContact(
      id: id,
      displayName: name,
      phoneE164: phoneE164,
      phoneDisplay: phoneRaw,
    ));
    notifyListeners();
  }

  String normalizeToE164(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('+')) {
      return trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
    }
    final digits = trimmed.replaceAll(RegExp(r'\\D'), '');
    if (digits.length == 10) {
      return '+1$digits';
    }
    if (digits.length == 11 && digits.startsWith('1')) {
      return '+$digits';
    }
    return digits;
  }

  //
  // developer overrides
  //

  bool _applyDebugOverrideIfNeeded() {
    if (!AppConfig.enableDebugOverrides) return false;
    final overridePage = AppConfig.debugOverridePage;
    if (overridePage == null || overridePage.isEmpty) return false;

    switch (overridePage) {
      case 'onboarding invite':
        pendingInviteHouseholdName = 'The Cool Kids';
        pendingInviteInviterNames = ['Rob', 'Billy'];
        pendingInvite = PendingInvite(
          id: -1,
          householdId: -1,
          inviterUserIds: const [1, 2],
        );
        break;
      case 'onboarding add members':
        householdName = null;
        break;
      case 'onboarding contacts':
        householdName = householdName ?? 'Test Household';
        break;
      case 'onboarding invite sent':
        householdName = householdName ?? 'Test Household';
        break;
      case 'onboarding profile':
      case 'start':
      default:
        break;
    }

    navigateToPage(overridePage);
    return true;
  }

  //
  // brightness mode
  //

  bool brightnessModeSwitchValue = false;
  bool showNavigationBar = false;
  void toggleBrightnessMode() {
    brightnessModeSwitchValue = !brightnessModeSwitchValue;
    notifyListeners();
  }

  void updateBrightnessMode(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    brightnessModeSwitchValue = brightness == Brightness.dark;
    notifyListeners();
  }

  void initializeUnsavedExceptions() {
    unsavedExceptions =
        exceptions.map((exception) => {...exception, 'edited': false}).toList();
  }

  void handleExceptionsEditSaveBtnPressed() {
    toggleExceptionsEditMode();

    notifyListeners();
  }

  void sortExceptions() {
    exceptions.sort((a, b) {
      if (sortCriteria == 'name') {
        return a['name'].compareTo(b['name']);
      } else if (sortCriteria == 'category') {
        return a['category'].compareTo(b['category']);
      }
      return 0;
    });
  }

  void saveExceptions() {
    List unsavedExceptionsFunc = unsavedExceptions.map((unsavedEx) {
      final newException = Map<String, dynamic>.from(unsavedEx);
      newException.remove('edited');
      return newException;
    }).toList();
    exceptions = unsavedExceptionsFunc;
    unsavedExceptions = [];
  }

  // edit mode for exceptions screen
  bool exceptionsEditMode = false;
  void toggleExceptionsEditMode() {
    exceptionsEditMode = !exceptionsEditMode;
    notifyListeners();
  }

  // core functionality state
  List housemates = [];
  Future<void> getHousemates() async {
    if (currentHouseholdId == null) {
      housemates = [];
      return;
    }
    final data =
        await supabase.from('users').select().eq('household_id', currentHouseholdId!);
    housemates = data;
  }

  List expenses = [];
  Future<void> getExpenses() async {
    if (currentHouseholdId == null) {
      expenses = [];
      return;
    }
    final data = await supabase
        .from('expenses')
        .select()
        .eq('household_id', currentHouseholdId!);
    expenses = data;
  }

  List exceptions = [];
  Future<void> getExceptions() async {
    if (currentHouseholdId == null) {
      exceptions = [];
      return;
    }
    final data = await supabase
        .from('exceptions')
        .select()
        .eq('household_id', currentHouseholdId!);
    exceptions = data;
  }

  // unsaved exceptions have an additional "edited" key to track if they have been edited for UI purposes. Separated from the regular exceptions to allow for reverting changes.
  List unsavedExceptions = [];
  num totalHouseholdIncome = 0;
  String currentPage = 'logo';
  String previousPage = '';

  void updateTempSelectedItem(exception, String name, String type) {
    exception[type] = name;
    int unsavedExceptionIndex = unsavedExceptions
        .indexWhere((tempEx) => tempEx['id'] == exception['id']);
    int savedExceptionIndex =
        exceptions.indexWhere((ex) => ex['id'] == exception['id']);

    // check if the exception has reverted to unedited with this change
    bool categoryChanged = unsavedExceptions[unsavedExceptionIndex]
            ['category'] !=
        exceptions[savedExceptionIndex]['category'];
    bool nameChanged = unsavedExceptions[unsavedExceptionIndex]['name'] !=
        exceptions[savedExceptionIndex]['name'];
    bool typeChanged = unsavedExceptions[unsavedExceptionIndex]['type'] !=
        exceptions[savedExceptionIndex]['type'];
    bool percentChanged = unsavedExceptions[unsavedExceptionIndex]['percent'] !=
        exceptions[savedExceptionIndex]['percent'];
    bool isEdited =
        (categoryChanged || nameChanged || typeChanged || percentChanged);

    if (isEdited) {
      unsavedExceptions[unsavedExceptionIndex]['edited'] = true;
    } else {
      unsavedExceptions[unsavedExceptionIndex]['edited'] = false;
    }

    unsavedExceptions[unsavedExceptionIndex][type] = name;
    initializeExceptionSets();
    sortExceptions();
    notifyListeners();
  }

  Map getEditedExceptionsByIdsMap() {
    Map<int, dynamic> editedExceptionsByIdsMap = {};

    for (var unsavedEx in unsavedExceptions) {
      if (unsavedEx['edited'] == true) {
        int exOfUnsavedExIndex =
            exceptions.indexWhere((ex) => ex['id'] == unsavedEx['id']);

        editedExceptionsByIdsMap[unsavedEx['id']] =
            exceptions[exOfUnsavedExIndex];
      }
    }
    return editedExceptionsByIdsMap;
  }

  int returnInitialSelectedItem(exception, exceptionNamesAndCategories, type) {
    // TO-DO: update exceptionNamesAndCategories to use id identifiers instead of name
    return exceptionNamesAndCategories.indexOf(exception[type]);
  }

  String returnTempSelectedNameOrCategory(exception, type) {
    int exceptionIndex = unsavedExceptions
        .indexWhere((tempEx) => tempEx['id'] == exception['id']);
    if (unsavedExceptions[exceptionIndex][type] == 'All Expenses') {
      return 'all';
    }
    return unsavedExceptions[exceptionIndex][type];
  }

  String sortCriteria = 'name';
  void updateSortCriteria(String newValue) {
    sortCriteria = newValue;
    sortExceptions();
    notifyListeners();
  }

  List returnExceptionSetForSortCriteria() {
    if (sortCriteria == 'name') {
      return exceptionSets.housematesWithExceptions.toList();
    } else if (sortCriteria == 'category') {
      return exceptionSets.categoriesWithExceptions.toList();
    }
    return [];
  }

  List returnExceptionsForSortCriteria(funcExceptions, name) {
    return funcExceptions
        .where((exception) => exception[sortCriteria] == name)
        .toList();
  }

  void deleteException(exception) {
    unsavedExceptions.removeWhere((tempEx) => tempEx['id'] == exception['id']);
    initializeExceptionSets();
    notifyListeners();
  }

  void initializeExceptionSets() {
    // TO-DO: clean this up, the way exceptionSets is assigned isn't very efficient
    exceptionSets = ExceptionSets(
      housematesWithExceptions: {},
      categoriesWithExceptions: {},
    );

    List exceptionsForThisFunc =
        exceptionsEditMode ? unsavedExceptions : exceptions;

    Set housematesWithExceptions = {};
    Set categoriesWithExceptions = {};

    for (var exception in exceptionsForThisFunc) {
      housematesWithExceptions.add(exception['name']);
      categoriesWithExceptions.add(exception['category']);
    }

    exceptionSets = ExceptionSets(
      housematesWithExceptions: housematesWithExceptions,
      categoriesWithExceptions: categoriesWithExceptions,
    );
  }

  // core calculation methods
  void updateHousematesIncome() {
    totalHouseholdIncome = 0;

    for (int i = 0; i < housemates.length; i++) {
      num housemateNetIncome =
          double.tryParse(housematesNetIncomeControllers[i].text) ?? 0;
      housemates[i]['netIncome'] = housemateNetIncome;
      totalHouseholdIncome += housemateNetIncome;
    }

    for (int i = 0; i < housemates.length; i++) {
      num percentageOfHouseholdIncome =
          (housemates[i]['netIncome'] / totalHouseholdIncome * 100);
      housemates[i]['percentageOfHouseholdIncome'] =
          percentageOfHouseholdIncome;
    }
  }

  void updateHousematesShare() {
    for (int i = 0; i < expenses.length; i++) {
      num expenseAmount =
          double.tryParse(expensesAmountControllers[i].text) ?? 0;
      expenses[i]['amount'] = expenseAmount;
    }

    for (var housemate in housemates) {
      for (int i = 0; i < expenses.length; i++) {
        num expenseAmount = expenses[i]['amount'];
        housemate['shareOfExpenses'].add({
          'name': expenses[i]['name'],
          'amount':
              (expenseAmount * housemate['percentageOfHouseholdIncome'] / 100)
        });
      }
    }
  }

  // navigation methods
  void handleMenuButtonPressed(icon) {
    const flowPages = [
      'signin',
      'start',
      'expenses',
      'summary',
      'household income summary'
    ];
    if (flowPages.contains(currentPage) && icon == CupertinoIcons.bars) {
      previousPage = currentPage;
      currentPage = 'menu';
    } else if (currentPage == 'menu' && icon == CupertinoIcons.clear) {
      currentPage = previousPage;
    } else if (currentPage == 'config' || currentPage == 'exceptions') {
      currentPage = 'menu';
    } else {
      icon = CupertinoIcons.clear;
    }
    notifyListeners();
  }

  void navigateToPage(String page) {
    currentPage = page;
    notifyListeners();
  }

  // error handling methods
  GenericError? currentErrorToShow;
  void createErrorObject(bool isCurrent, String title, String message) {
    GenericError error =
        GenericError(isCurrent: isCurrent, title: title, message: message);
    if (isCurrent) {
      currentErrorToShow = error;
    }
  }
}

// utility classes
class ExceptionSets {
  Set housematesWithExceptions;
  Set categoriesWithExceptions;

  ExceptionSets({
    required this.housematesWithExceptions,
    required this.categoriesWithExceptions,
  });
}

class GenericError {
  bool isCurrent;
  final String title;
  final String message;

  GenericError({
    this.isCurrent = true,
    required this.title,
    this.message = '',
  });
}

class PendingInvite {
  final int id;
  final int householdId;
  final List<int> inviterUserIds;

  PendingInvite({
    required this.id,
    required this.householdId,
    required this.inviterUserIds,
  });

  factory PendingInvite.fromJson(Map<String, dynamic> data) {
    final inviterIds = (data['inviter_user_ids'] as List?)
            ?.map((value) => value as int)
            .toList() ??
        [];
    return PendingInvite(
      id: data['id'] as int,
      householdId: data['household_id'] as int,
      inviterUserIds: inviterIds,
    );
  }
}

class InviteContact {
  final String id;
  final String displayName;
  final String phoneE164;
  final String phoneDisplay;

  InviteContact({
    required this.id,
    required this.displayName,
    required this.phoneE164,
    required this.phoneDisplay,
  });
}
