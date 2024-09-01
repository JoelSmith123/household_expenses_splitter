import 'package:flutter/cupertino.dart';

class AppState extends ChangeNotifier {
  // constructor
  AppState() {
    _initializeControllers();
  }

  // controllers
  List<TextEditingController> housematesNetIncomeControllers = [];
  List<TextEditingController> expensesAmountControllers = [];

  // initialize controllers
  void _initializeControllers() {
    housematesNetIncomeControllers =
        List.generate(housemates.length, (index) => TextEditingController());
    expensesAmountControllers =
        List.generate(expenses.length, (index) => TextEditingController());
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
    }
  ];
  num totalHouseholdIncome = 0;
  String currentPage = 'start';
  String previousPage = '';

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
    } else if (currentPage == 'config') {
      currentPage = 'menu';
    } else {
      icon = CupertinoIcons.clear;
    }
    notifyListeners();
  }

  void navigateToConfig() {
    currentPage = 'config';
    notifyListeners();
  }

  void navigateToHouseholdIncomeSummary() {
    currentPage = 'household income summary';
    notifyListeners();
  }

  void navigateToExpenses() {
    currentPage = 'expenses';
    notifyListeners();
  }

  void navigateToSummary() {
    currentPage = 'summary';
    notifyListeners();
  }
}
