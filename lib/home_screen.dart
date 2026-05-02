import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'styles/app_styles.dart';
import 'widgets/floating_nav_button.dart';

// TODO: replace mock paid / paidBy / exception with real schema fields once
// the database tracks who fronted each expense and per-month paid totals.

Widget homeScreen() {
  return Consumer<AppState>(
    builder: (context, appState, _) {
      final data = _buildHomeData(appState);
      final shares = _computeShares(data);

      return Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _AppBar(householdName: data.householdName),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg - 4, // 20
                      AppSpacing.xs,
                      AppSpacing.lg - 4, // 20
                      120, // clearance for floating menu button
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _MonthHeader(data: data),
                        const SizedBox(height: 18),
                        _BalancesCard(data: data, totals: shares.totals),
                        const SizedBox(height: 18),
                        _ExpensesMatrix(data: data, shares: shares),
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
            child: FloatingNavButton.menu(
              onPressed: appState.openMenu,
            ),
          ),
        ],
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Internal data shapes
// ─────────────────────────────────────────────────────────────────────────

class _HomeMember {
  final String id;
  final String name;
  final double share; // 0..1, fraction of household income
  final double paid; // dollars actually fronted this month (mock for now)

  const _HomeMember({
    required this.id,
    required this.name,
    required this.share,
    required this.paid,
  });
}

class _HomeExpense {
  final String id;
  final String name;
  final double amount;
  final String paidBy; // member id (mock for now)
  final Map<String, double>? exception; // memberId -> override share

  const _HomeExpense({
    required this.id,
    required this.name,
    required this.amount,
    required this.paidBy,
    this.exception,
  });
}

class _HomeData {
  final String householdName;
  final String monthLabel;
  final String previousMonthLabel;
  final List<_HomeMember> members;
  final List<_HomeExpense> expenses;
  final String? exceptionFootnote;

  const _HomeData({
    required this.householdName,
    required this.monthLabel,
    required this.previousMonthLabel,
    required this.members,
    required this.expenses,
    this.exceptionFootnote,
  });
}

class _Shares {
  final Map<String, Map<String, double>> perExpense; // expenseId -> memberId -> $
  final Map<String, double> totals; // memberId -> $ owed total

  const _Shares({required this.perExpense, required this.totals});
}

// Port of computeShares() from home.jsx — proportional split with per-expense
// exception override + redistribution of removed weight.
_Shares _computeShares(_HomeData data) {
  final memberIds = data.members.map((m) => m.id).toList();
  final baseShare = <String, double>{
    for (final m in data.members) m.id: m.share,
  };
  final perExpense = <String, Map<String, double>>{};
  final totals = <String, double>{for (final id in memberIds) id: 0.0};

  for (final exp in data.expenses) {
    final shares = Map<String, double>.from(baseShare);
    final exception = exp.exception;
    if (exception != null) {
      final exMembers = exception.keys.toList();
      for (final id in exMembers) {
        shares[id] = exception[id]!;
      }
      final removed = exMembers.fold<double>(
        0,
        (s, id) => s + (baseShare[id]! - exception[id]!),
      );
      final remaining =
          memberIds.where((id) => !exMembers.contains(id)).toList();
      final remainingTotal = remaining.fold<double>(
        0,
        (s, id) => s + baseShare[id]!,
      );
      if (remainingTotal > 0) {
        for (final id in remaining) {
          shares[id] =
              baseShare[id]! + removed * (baseShare[id]! / remainingTotal);
        }
      }
    }
    final cell = <String, double>{};
    for (final id in memberIds) {
      final v = exp.amount * shares[id]!;
      cell[id] = v;
      totals[id] = totals[id]! + v;
    }
    perExpense[exp.id] = cell;
  }
  return _Shares(perExpense: perExpense, totals: totals);
}

// ─────────────────────────────────────────────────────────────────────────
// Data projection — bind real AppState data where available; mock the rest.
// ─────────────────────────────────────────────────────────────────────────

_HomeData _buildHomeData(AppState appState) {
  final now = DateTime.now();
  final pastMonth = DateTime(now.year, now.month - 1, 1);
  final priorMonth = DateTime(now.year, now.month - 2, 1);
  final monthLabel = _formatMonthYear(pastMonth);
  final previousMonthLabel = _formatMonth(priorMonth);

  final hasHousemates = appState.housemates.isNotEmpty;
  final hasExpenses = appState.expenses.isNotEmpty;

  if (!hasHousemates || !hasExpenses) {
    return _sampleHomeData(
      monthLabel: monthLabel,
      previousMonthLabel: previousMonthLabel,
    );
  }

  final householdName = appState.householdName ?? 'My Household';

  // Compute member shares from real income data when present, else uniform.
  final totalIncome = appState.housemates.fold<double>(
    0,
    (s, h) => s + _toDouble(h['netIncome']),
  );
  final hasIncome = totalIncome > 0;

  final members = <_HomeMember>[];
  for (final h in appState.housemates) {
    final id = h['id'].toString();
    final name = (h['display_name'] ?? h['name'] ?? 'Unknown').toString();
    final income = _toDouble(h['netIncome']);
    final share = hasIncome
        ? income / totalIncome
        : 1.0 / appState.housemates.length;
    members.add(_HomeMember(id: id, name: name, share: share, paid: 0));
  }

  // Mock paid amounts: distribute the total spend across members in a shape
  // that gives the home view interesting balances to render. Real schema
  // doesn't yet track who fronted what.
  final totalSpend = appState.expenses.fold<double>(
    0,
    (s, e) => s + _toDouble(e['amount']),
  );
  if (totalSpend > 0 && members.isNotEmpty) {
    const mockSplit = [0.55, 0.45, 0.0];
    for (var i = 0; i < members.length; i++) {
      final factor = mockSplit[i % mockSplit.length];
      final m = members[i];
      members[i] = _HomeMember(
        id: m.id,
        name: m.name,
        share: m.share,
        paid: totalSpend * factor,
      );
    }
  }

  // Mock paidBy: cycle through members.
  final expenses = <_HomeExpense>[];
  for (var i = 0; i < appState.expenses.length; i++) {
    final e = appState.expenses[i];
    final id = (e['id'] ?? 'expense-$i').toString();
    final name = (e['name'] ?? 'Unknown').toString();
    final amount = _toDouble(e['amount']);
    final paidBy = members.isNotEmpty ? members[i % members.length].id : '';
    expenses.add(_HomeExpense(
      id: id,
      name: name,
      amount: amount,
      paidBy: paidBy,
    ));
  }

  return _HomeData(
    householdName: householdName,
    monthLabel: monthLabel,
    previousMonthLabel: previousMonthLabel,
    members: members,
    expenses: expenses,
    exceptionFootnote: null,
  );
}

// Sample data drawn directly from the design's home.jsx — used when there's
// no real household data yet (fresh/empty state and dev preview).
_HomeData _sampleHomeData({
  required String monthLabel,
  required String previousMonthLabel,
}) {
  return _HomeData(
    householdName: 'Birch Street',
    monthLabel: monthLabel,
    previousMonthLabel: previousMonthLabel,
    members: const [
      _HomeMember(id: 'sam', name: 'Sam', share: 0.32, paid: 1180.00),
      _HomeMember(id: 'pat', name: 'Pat', share: 0.44, paid: 2010.40),
      _HomeMember(id: 'jules', name: 'Jules', share: 0.24, paid: 0),
    ],
    expenses: const [
      _HomeExpense(id: 'rent', name: 'Rent', amount: 2400, paidBy: 'pat'),
      _HomeExpense(id: 'util', name: 'Utilities', amount: 184, paidBy: 'pat'),
      _HomeExpense(id: 'inet', name: 'Internet', amount: 70, paidBy: 'sam'),
      _HomeExpense(
        id: 'stream',
        name: 'Streaming',
        amount: 38,
        paidBy: 'sam',
        exception: {'sam': 0.0},
      ),
      _HomeExpense(id: 'groc', name: 'Groceries', amount: 612, paidBy: 'sam'),
      _HomeExpense(
        id: 'cleaning',
        name: 'Cleaning',
        amount: 80,
        paidBy: 'pat',
      ),
    ],
    exceptionFootnote: 'Streaming has an exception — Sam pays 0%.',
  );
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _formatMonth(DateTime d) => _monthNames[d.month - 1];
String _formatMonthYear(DateTime d) => '${_monthNames[d.month - 1]} ${d.year}';

String _formatMoneyCompact(double n, {bool compact = false}) {
  if (compact && n.abs() >= 1000) {
    final v = (n / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    return '\$${v}k';
  }
  return '\$${_groupedInt(n)}';
}

String _formatMoneyPrecise(double n) {
  return '\$${_groupedDecimal(n)}';
}

String _groupedInt(double n) {
  final rounded = n.round();
  return _addThousandsSeparator(rounded.toString());
}

String _groupedDecimal(double n) {
  final fixed = n.toStringAsFixed(2);
  final parts = fixed.split('.');
  return '${_addThousandsSeparator(parts[0])}.${parts[1]}';
}

String _addThousandsSeparator(String intPart) {
  final isNegative = intPart.startsWith('-');
  final digits = isNegative ? intPart.substring(1) : intPart;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return isNegative ? '-${buffer.toString()}' : buffer.toString();
}

// ─────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final String householdName;

  const _AppBar({required this.householdName});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg - 4),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Tally',
                style: AppText.title(size: 26).copyWith(
                  height: 1,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const Spacer(),
            const Icon(
              CupertinoIcons.house_fill,
              size: 13,
              color: AppColors.muted,
            ),
            const SizedBox(width: AppSpacing.xxs + 2),
            Text(
              householdName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final _HomeData data;

  const _MonthHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    final expenseTotal = data.expenses.fold<double>(0, (s, e) => s + e.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(data.monthLabel, style: AppText.monthHeader()),
            ),
            // Previous-month chevron affordance — visual only for v1.
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.chevron_left,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    data.previousMonthLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${data.expenses.length} shared expenses · '
          '${_formatMoneyPrecise(expenseTotal)} total',
          style: const TextStyle(fontSize: 14, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _BalancesCard extends StatelessWidget {
  final _HomeData data;
  final Map<String, double> totals;

  const _BalancesCard({required this.data, required this.totals});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'WHERE EVERYONE STANDS',
                  style: AppText.sectionLabel(),
                ),
              ),
              Text(
                'paid − owed',
                style: AppText.cardItemSub().copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < data.members.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _BalanceRow(
              member: data.members[i],
              owed: totals[data.members[i].id] ?? 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final _HomeMember member;
  final double owed;

  const _BalanceRow({required this.member, required this.owed});

  @override
  Widget build(BuildContext context) {
    final balance = member.paid - owed;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          child: Center(child: _MemberDisc(name: member.name)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name, style: AppText.cardItemTitle()),
              const SizedBox(height: 2),
              Text(
                'paid ${_formatMoneyCompact(member.paid)} · '
                'owed ${_formatMoneyCompact(owed)}',
                style: AppText.cardItemSub(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _BalancePill(amount: balance),
      ],
    );
  }
}

class _MemberDisc extends StatelessWidget {
  final String name;

  const _MemberDisc({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.green12,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: AppColors.deepGreen,
          height: 1,
        ),
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  final double amount;

  const _BalancePill({required this.amount});

  @override
  Widget build(BuildContext context) {
    final isZero = amount.abs() < 0.5;
    final isPositive = amount > 0;
    final color = isZero
        ? AppColors.muted
        : (isPositive ? AppColors.balancePositive : AppColors.balanceNegative);
    final sign = isZero ? '' : (isPositive ? '+' : '−');
    return Text(
      '$sign${_formatMoneyCompact(amount.abs())}',
      style: AppText.balancePill(color: color),
    );
  }
}

class _ExpensesMatrix extends StatelessWidget {
  final _HomeData data;
  final _Shares shares;

  const _ExpensesMatrix({required this.data, required this.shares});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: AppSpacing.xs),
          child: Text(
            'BREAKDOWN BY EXPENSE',
            style: AppText.sectionLabel(),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.hairline),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                _MatrixHeaderRow(members: data.members),
                for (var i = 0; i < data.expenses.length; i++)
                  _MatrixExpenseRow(
                    expense: data.expenses[i],
                    members: data.members,
                    cell: shares.perExpense[data.expenses[i].id]!,
                    paidBy: _resolvePayerName(data, data.expenses[i].paidBy),
                    isLast: i == data.expenses.length - 1,
                  ),
                _MatrixTotalsRow(members: data.members, totals: shares.totals),
              ],
            ),
          ),
        ),
        if (data.exceptionFootnote != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _ExceptionFootnote(text: data.exceptionFootnote!),
        ],
      ],
    );
  }

  String _resolvePayerName(_HomeData data, String paidById) {
    for (final m in data.members) {
      if (m.id == paidById) return m.name;
    }
    return '—';
  }
}

class _MatrixHeaderRow extends StatelessWidget {
  final List<_HomeMember> members;

  const _MatrixHeaderRow({required this.members});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text('EXPENSE', style: AppText.tableColumnLabel())),
          for (final m in members) ...[
            const SizedBox(width: AppSpacing.xxs),
            SizedBox(
              width: 54,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(m.name, style: AppText.tableColumnName()),
                  const SizedBox(height: 2),
                  Text(
                    '${(m.share * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MatrixExpenseRow extends StatelessWidget {
  final _HomeExpense expense;
  final List<_HomeMember> members;
  final Map<String, double> cell;
  final String paidBy;
  final bool isLast;

  const _MatrixExpenseRow({
    required this.expense,
    required this.members,
    required this.cell,
    required this.paidBy,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final hasException = expense.exception != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.hairlineSoft)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        expense.name,
                        style: AppText.cardItemTitle(),
                      ),
                    ),
                    if (hasException) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        CupertinoIcons.star_fill,
                        size: 12,
                        color: AppColors.primaryGreen,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatMoneyCompact(expense.amount)} · paid by $paidBy',
                  style: AppText.cardItemSub().copyWith(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          for (final m in members) ...[
            const SizedBox(width: AppSpacing.xxs),
            SizedBox(
              width: 54,
              child: _AmountCell(value: cell[m.id] ?? 0),
            ),
          ],
        ],
      ),
    );
  }
}

class _AmountCell extends StatelessWidget {
  final double value;

  const _AmountCell({required this.value});

  @override
  Widget build(BuildContext context) {
    final isZero = value < 0.5;
    return Text(
      isZero ? '—' : _formatMoneyCompact(value),
      textAlign: TextAlign.right,
      style: AppText.tableCell(
        color: isZero ? AppColors.placeholderGray : AppColors.ink,
      ),
    );
  }
}

class _MatrixTotalsRow extends StatelessWidget {
  final List<_HomeMember> members;
  final Map<String, double> totals;

  const _MatrixTotalsRow({required this.members, required this.totals});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWarm,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text('Total owed', style: AppText.tableTotalLabel()),
          ),
          for (final m in members) ...[
            const SizedBox(width: AppSpacing.xxs),
            SizedBox(
              width: 54,
              child: Text(
                _formatMoneyCompact(totals[m.id] ?? 0),
                textAlign: TextAlign.right,
                style: AppText.tableTotalValue(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExceptionFootnote extends StatelessWidget {
  final String text;

  const _ExceptionFootnote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              CupertinoIcons.star_fill,
              size: 10,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: Text(text, style: AppText.microCaption()),
          ),
        ],
      ),
    );
  }
}
