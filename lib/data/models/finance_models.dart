import 'package:flutter/material.dart';

enum TransactionType { income, expense, transfer }

enum AccountKind { bank, securities, wallet, card }

enum SyncProviderType { bank, card, investment, payment }

enum SyncAuthStatus {
  disconnected,
  authorizationRequired,
  pendingConsent,
  permissionRequired,
  connected,
  error,
}

TransactionType transactionTypeFromName(String value) {
  return TransactionType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => TransactionType.expense,
  );
}

AccountKind accountKindFromName(String value) {
  return AccountKind.values.firstWhere(
    (kind) => kind.name == value,
    orElse: () => AccountKind.bank,
  );
}

SyncProviderType syncProviderTypeFromName(String value) {
  return SyncProviderType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => SyncProviderType.bank,
  );
}

SyncAuthStatus syncAuthStatusFromName(String value) {
  return SyncAuthStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => SyncAuthStatus.disconnected,
  );
}

bool boolFromJson(dynamic value) {
  return value == true || value == 1;
}

class BudgetCategory {
  const BudgetCategory({
    required this.id,
    required this.name,
    required this.monthlyBudget,
    required this.isFixed,
    required this.colorValue,
    required this.iconCodePoint,
  });

  final String id;
  final String name;
  final int monthlyBudget;
  final bool isFixed;
  final int colorValue;
  final int iconCodePoint;

  Color get color => Color(colorValue);

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  BudgetCategory copyWith({
    String? id,
    String? name,
    int? monthlyBudget,
    bool? isFixed,
    int? colorValue,
    int? iconCodePoint,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      isFixed: isFixed ?? this.isFixed,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'monthlyBudget': monthlyBudget,
      'isFixed': isFixed,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
    };
  }

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      monthlyBudget: json['monthlyBudget'] as int,
      isFixed: boolFromJson(json['isFixed']),
      colorValue: json['colorValue'] as int,
      iconCodePoint: json['iconCodePoint'] as int,
    );
  }
}

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.sourceName,
    required this.isAutoSynced,
    this.providerId,
    this.externalId,
  });

  final String id;
  final String title;
  final int amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String sourceName;
  final bool isAutoSynced;
  final String? providerId;
  final String? externalId;

  TransactionEntry copyWith({
    String? id,
    String? title,
    int? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? sourceName,
    bool? isAutoSynced,
    String? providerId,
    String? externalId,
  }) {
    return TransactionEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      sourceName: sourceName ?? this.sourceName,
      isAutoSynced: isAutoSynced ?? this.isAutoSynced,
      providerId: providerId ?? this.providerId,
      externalId: externalId ?? this.externalId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'sourceName': sourceName,
      'isAutoSynced': isAutoSynced,
      'providerId': providerId,
      'externalId': externalId,
    };
  }

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: json['amount'] as int,
      type: transactionTypeFromName(json['type'] as String),
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
      sourceName: json['sourceName'] as String,
      isAutoSynced: boolFromJson(json['isAutoSynced']),
      providerId: json['providerId'] as String?,
      externalId: json['externalId'] as String?,
    );
  }
}

class LinkedAccount {
  const LinkedAccount({
    required this.id,
    required this.name,
    required this.kind,
    required this.principal,
    required this.currentBalance,
    required this.isLinked,
    this.providerId,
  });

  final String id;
  final String name;
  final AccountKind kind;
  final int principal;
  final int currentBalance;
  final bool isLinked;
  final String? providerId;

  int get profit => currentBalance - principal;

  double get yieldRate {
    if (principal == 0) {
      return 0;
    }
    return (profit / principal) * 100;
  }

  LinkedAccount copyWith({
    String? id,
    String? name,
    AccountKind? kind,
    int? principal,
    int? currentBalance,
    bool? isLinked,
    String? providerId,
  }) {
    return LinkedAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      principal: principal ?? this.principal,
      currentBalance: currentBalance ?? this.currentBalance,
      isLinked: isLinked ?? this.isLinked,
      providerId: providerId ?? this.providerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'kind': kind.name,
      'principal': principal,
      'currentBalance': currentBalance,
      'isLinked': isLinked,
      'providerId': providerId,
    };
  }

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    return LinkedAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: accountKindFromName(json['kind'] as String),
      principal: json['principal'] as int,
      currentBalance: json['currentBalance'] as int,
      isLinked: boolFromJson(json['isLinked']),
      providerId: json['providerId'] as String?,
    );
  }
}

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
  });

  final String id;
  final String title;
  final int targetAmount;
  final int currentAmount;

  double get progress {
    if (targetAmount == 0) {
      return 0;
    }
    return currentAmount / targetAmount;
  }

  SavingsGoal copyWith({
    String? id,
    String? title,
    int? targetAmount,
    int? currentAmount,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmount: json['targetAmount'] as int,
      currentAmount: json['currentAmount'] as int,
    );
  }
}

class SpendingChallenge {
  const SpendingChallenge({
    required this.title,
    required this.dailyTarget,
    required this.todaySpent,
  });

  final String title;
  final int dailyTarget;
  final int todaySpent;

  bool get isSuccessful => todaySpent <= dailyTarget;
}

class CategoryBudgetStatus {
  const CategoryBudgetStatus({
    required this.category,
    required this.spent,
    required this.remaining,
    required this.dailyAllowance,
  });

  final BudgetCategory category;
  final int spent;
  final int remaining;
  final int dailyAllowance;

  double get progress {
    if (category.monthlyBudget == 0) {
      return 0;
    }
    return spent / category.monthlyBudget;
  }

  bool get isOverBudget => remaining < 0;

  bool get isWarning => !isOverBudget && progress >= 0.8;
}

class MonthlySpendingSummary {
  const MonthlySpendingSummary({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    required this.transfer,
  });

  final int year;
  final int month;
  final int income;
  final int expense;
  final int transfer;

  String get label => '$month월';
}

class CategoryTrendPoint {
  const CategoryTrendPoint({
    required this.label,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.colorValue,
  });

  final String label;
  final String categoryId;
  final String categoryName;
  final int amount;
  final int colorValue;

  Color get color => Color(colorValue);
}

class SyncProvider {
  const SyncProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.isConnected,
    required this.hasPermission,
    required this.authStatus,
    this.lastSyncedAt,
    this.statusMessage,
    this.lastAuthorizedAt,
  });

  final String id;
  final String name;
  final SyncProviderType type;
  final bool isConnected;
  final bool hasPermission;
  final SyncAuthStatus authStatus;
  final DateTime? lastSyncedAt;
  final String? statusMessage;
  final DateTime? lastAuthorizedAt;

  bool get isReadyToSync =>
      isConnected && hasPermission && authStatus == SyncAuthStatus.connected;

  SyncProvider copyWith({
    String? id,
    String? name,
    SyncProviderType? type,
    bool? isConnected,
    bool? hasPermission,
    SyncAuthStatus? authStatus,
    DateTime? lastSyncedAt,
    String? statusMessage,
    DateTime? lastAuthorizedAt,
  }) {
    return SyncProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isConnected: isConnected ?? this.isConnected,
      hasPermission: hasPermission ?? this.hasPermission,
      authStatus: authStatus ?? this.authStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      statusMessage: statusMessage ?? this.statusMessage,
      lastAuthorizedAt: lastAuthorizedAt ?? this.lastAuthorizedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'isConnected': isConnected,
      'hasPermission': hasPermission,
      'authStatus': authStatus.name,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'statusMessage': statusMessage,
      'lastAuthorizedAt': lastAuthorizedAt?.toIso8601String(),
    };
  }

  factory SyncProvider.fromJson(Map<String, dynamic> json) {
    return SyncProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      type: syncProviderTypeFromName(json['type'] as String),
      isConnected: boolFromJson(json['isConnected']),
      hasPermission: boolFromJson(json['hasPermission']),
      authStatus: syncAuthStatusFromName(
        json['authStatus'] as String? ??
            (boolFromJson(json['isConnected'])
                ? (boolFromJson(json['hasPermission'])
                      ? SyncAuthStatus.connected.name
                      : SyncAuthStatus.permissionRequired.name)
                : SyncAuthStatus.disconnected.name),
      ),
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
      statusMessage: json['statusMessage'] as String?,
      lastAuthorizedAt: json['lastAuthorizedAt'] == null
          ? null
          : DateTime.parse(json['lastAuthorizedAt'] as String),
    );
  }
}

class AppSettings {
  const AppSettings({
    required this.autoSyncEnabled,
    required this.savingsTipsEnabled,
    required this.challengeReminderEnabled,
    required this.challengeDailyTarget,
  });

  final bool autoSyncEnabled;
  final bool savingsTipsEnabled;
  final bool challengeReminderEnabled;
  final int challengeDailyTarget;

  AppSettings copyWith({
    bool? autoSyncEnabled,
    bool? savingsTipsEnabled,
    bool? challengeReminderEnabled,
    int? challengeDailyTarget,
  }) {
    return AppSettings(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      savingsTipsEnabled: savingsTipsEnabled ?? this.savingsTipsEnabled,
      challengeReminderEnabled:
          challengeReminderEnabled ?? this.challengeReminderEnabled,
      challengeDailyTarget: challengeDailyTarget ?? this.challengeDailyTarget,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoSyncEnabled': autoSyncEnabled,
      'savingsTipsEnabled': savingsTipsEnabled,
      'challengeReminderEnabled': challengeReminderEnabled,
      'challengeDailyTarget': challengeDailyTarget,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      autoSyncEnabled: boolFromJson(json['autoSyncEnabled']),
      savingsTipsEnabled: boolFromJson(json['savingsTipsEnabled']),
      challengeReminderEnabled: boolFromJson(json['challengeReminderEnabled']),
      challengeDailyTarget: json['challengeDailyTarget'] as int,
    );
  }
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.totalSaved,
    required this.totalInvestedPrincipal,
    required this.totalInvestedValue,
    required this.todayAllowance,
    required this.categories,
    required this.transactions,
    required this.accounts,
    required this.goals,
    required this.challenge,
    required this.insights,
    required this.syncProviders,
    required this.settings,
    required this.monthlyTrend,
    required this.categoryTrends,
    required this.autoSyncedExpense,
    required this.weeklyExpense,
    required this.previousWeeklyExpense,
    required this.lastMonthExpense,
    required this.priorityInsights,
  });

  final int monthlyIncome;
  final int monthlyExpense;
  final int totalSaved;
  final int totalInvestedPrincipal;
  final int totalInvestedValue;
  final int todayAllowance;
  final List<CategoryBudgetStatus> categories;
  final List<TransactionEntry> transactions;
  final List<LinkedAccount> accounts;
  final List<SavingsGoal> goals;
  final SpendingChallenge challenge;
  final List<String> insights;
  final List<SyncProvider> syncProviders;
  final AppSettings settings;
  final List<MonthlySpendingSummary> monthlyTrend;
  final List<CategoryTrendPoint> categoryTrends;
  final int autoSyncedExpense;
  final int weeklyExpense;
  final int previousWeeklyExpense;
  final int lastMonthExpense;
  final List<String> priorityInsights;

  int get remainingBudget => monthlyIncome - monthlyExpense;

  int get totalInvestmentProfit => totalInvestedValue - totalInvestedPrincipal;

  double get savingsRate {
    if (monthlyIncome == 0) {
      return 0;
    }
    return (remainingBudget / monthlyIncome) * 100;
  }

  double get autoSyncRate {
    if (monthlyExpense == 0) {
      return 0;
    }
    return (autoSyncedExpense / monthlyExpense) * 100;
  }

  int get monthlyExpenseDiff => monthlyExpense - lastMonthExpense;

  double get monthlyExpenseDiffRate {
    if (lastMonthExpense == 0) {
      return 0;
    }
    return (monthlyExpenseDiff / lastMonthExpense) * 100;
  }

  int get weeklyExpenseDiff => weeklyExpense - previousWeeklyExpense;

  double get weeklyExpenseDiffRate {
    if (previousWeeklyExpense == 0) {
      return 0;
    }
    return (weeklyExpenseDiff / previousWeeklyExpense) * 100;
  }
}
