import 'package:advanced_banking_system/core/constants/colors.dart';
import 'package:flutter/material.dart';

import '../../data/models/account_model.dart';
import '../../logic/services/account_tree_composite.dart';

enum AccountsFilter { all, checking, savings, invest, loans }

class AccountsTotals {
  final double assets;
  final double liabilities;
  const AccountsTotals({required this.assets, required this.liabilities});
}

class AccountsDerivedUi {
  final List<AccountComponent> items;
  final double assets;
  final double liabilities;

  const AccountsDerivedUi({
    required this.items,
    required this.assets,
    required this.liabilities,
  });

  const AccountsDerivedUi.empty()
    : items = const [],
      assets = 0,
      liabilities = 0;
}

List<AccountComponent> flattenLeaves(List<AccountComponent> roots) {
  final out = <AccountComponent>[];

  void walk(AccountComponent n) {
    if (n.children.isEmpty) {
      out.add(n);
      return;
    }
    for (final c in n.children) {
      walk(c);
    }
  }

  for (final r in roots) {
    walk(r);
  }
  return out;
}

List<AccountComponent> applyFilter(
  List<AccountComponent> list,
  AccountsFilter filter,
) {
  if (filter == AccountsFilter.all) return list;

  bool match(AccountType t) {
    switch (filter) {
      case AccountsFilter.checking:
        return t == AccountType.checking;
      case AccountsFilter.savings:
        return t == AccountType.savings;
      case AccountsFilter.invest:
        return t == AccountType.investment;
      case AccountsFilter.loans:
        return t == AccountType.loan;
      case AccountsFilter.all:
        return true;
    }
  }

  return list.where((a) => match(a.type)).toList();
}

AccountsTotals computeTotals(List<AccountComponent> leaves) {
  double assets = 0;
  double liabilities = 0;

  for (final a in leaves) {
    final b = a.ownBalance;
    if (b >= 0) {
      assets += b;
    } else {
      liabilities += b.abs();
    }
  }
  return AccountsTotals(assets: assets, liabilities: liabilities);
}

String formatMoney(double value) {
  final sign = value < 0 ? '-' : '';
  final abs = value.abs().toStringAsFixed(2);
  return '$sign\$$abs';
}

String typeLabel(AccountType t) {
  switch (t) {
    case AccountType.checking:
      return 'Checking Account';
    case AccountType.savings:
      return 'Savings Account';
    case AccountType.loan:
      return 'Loan Account';
    case AccountType.investment:
      return 'Investment Account';
  }
}

Color headerColor(AccountType t) {
  switch (t) {
    case AccountType.checking:
      return AppColors.blueColor;
    case AccountType.savings:
      return AppColors.green1Color;
    case AccountType.investment:
      return AppColors.majorelleBlueColor;
    case AccountType.loan:
      return AppColors.orangeColor;
  }
}

String fakeAccountNumberFromId(String id) {
  final digits = id.replaceAll(RegExp(r'[^0-9]'), '');
  final base = digits.padRight(16, '4').substring(0, 16);
  return '${base.substring(0, 4)}  ${base.substring(4, 8)}  ${base.substring(8, 12)}  ${base.substring(12, 16)}';
}
