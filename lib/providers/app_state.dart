import 'package:flutter/cupertino.dart';

class ExceptionSets {
  Set housematesWithExceptions;
  Set categoriesWithExceptions;

  ExceptionSets({
    required this.housematesWithExceptions,
    required this.categoriesWithExceptions,
  });
}

class AppState extends ChangeNotifier {
  // constructor
  AppState() {
    _initializeControllers();
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

  // brightness mode
  bool brightnessModeSwitchValue = false;

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

    if (!exceptionsEditMode) {
      unsavedExceptions = exceptions.map((exception) {
        final newException = Map<String, dynamic>.from(exception);
        newException.remove('edited');
        return newException;
      }).toList();
      exceptions = unsavedExceptions;
      unsavedExceptions = [];
    }

    notifyListeners();
  }

  // edit mode for exceptions screen
  bool exceptionsEditMode = false;
  void toggleExceptionsEditMode() {
    exceptionsEditMode = !exceptionsEditMode;
    notifyListeners();
  }

  // core functionality state
  List housemates = [
    {
      'name': 'Isabel',
      'netIncome': 0,
      'percentageOfHouseholdIncome': 0,
      'shareOfExpenses': [],
    },
    {
      'name': 'Jay',
      'netIncome': 0,
      'percentageOfHouseholdIncome': 0,
      'shareOfExpenses': [],
    },
    {
      'name': 'Joel',
      'netIncome': 0,
      'percentageOfHouseholdIncome': 0,
      'shareOfExpenses': [],
    }
  ];
  List expenses = [
    {
      'name': 'Rent',
      'amount': 0,
    },
    {
      'name': 'Utilities',
      'amount': 0,
    },
    {
      'name': 'Groceries',
      'amount': 0,
    },
    {
      'name': 'Pets',
      'amount': 0,
    }
  ];
  List exceptions = [
    {
      'id': UniqueKey().hashCode,
      'name': 'Jay',
      'category': 'All Expenses',
      'type': 'REDUCED',
      'percent': 50
    },
    {
      'id': UniqueKey().hashCode,
      'name': 'Isabel',
      'category': 'Electricity',
      'type': 'REDUCED',
      'percent': 33.33
    },
    {
      'id': UniqueKey().hashCode,
      'name': 'Isabel',
      'category': 'Pets',
      'type': 'EXEMPT'
    }
  ];
  // unsaved exceptions have an additional "edited" key to track if they have been edited for UI purposes. Separated from the regular exceptions to allow for reverting changes.
  List unsavedExceptions = [];
  num totalHouseholdIncome = 0;
  String currentPage = 'start';
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
    notifyListeners();
  }

  bool returnIfExceptionIsEdited(exception) {
    return true;
    // int unsavedExceptionIndex = unsavedExceptions
    //     .indexWhere((tempEx) => tempEx['id'] == exception['id']);

    // if (unsavedExceptionIndex == -1) {
    //   // If no matching exception is found, return false or handle the error appropriately
    //   return false;
    // }

    // return unsavedExceptions[unsavedExceptionIndex]['edited'] as bool;
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
}
