import '../models/finance_models.dart';

class AppPersistedState {
  const AppPersistedState({
    required this.categories,
    required this.transactions,
    required this.accounts,
    required this.goals,
    required this.syncProviders,
    required this.settings,
  });

  final List<BudgetCategory> categories;
  final List<TransactionEntry> transactions;
  final List<LinkedAccount> accounts;
  final List<SavingsGoal> goals;
  final List<SyncProvider> syncProviders;
  final AppSettings settings;

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((item) => item.toJson()).toList(),
      'transactions': transactions.map((item) => item.toJson()).toList(),
      'accounts': accounts.map((item) => item.toJson()).toList(),
      'goals': goals.map((item) => item.toJson()).toList(),
      'syncProviders': syncProviders.map((item) => item.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  factory AppPersistedState.fromJson(Map<String, dynamic> json) {
    return AppPersistedState(
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .map((item) => BudgetCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
      transactions: (json['transactions'] as List<dynamic>? ?? const [])
          .map(
            (item) => TransactionEntry.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      accounts: (json['accounts'] as List<dynamic>? ?? const [])
          .map((item) => LinkedAccount.fromJson(item as Map<String, dynamic>))
          .toList(),
      goals: (json['goals'] as List<dynamic>? ?? const [])
          .map((item) => SavingsGoal.fromJson(item as Map<String, dynamic>))
          .toList(),
      syncProviders: (json['syncProviders'] as List<dynamic>? ?? const [])
          .map((item) => SyncProvider.fromJson(item as Map<String, dynamic>))
          .toList(),
      settings: AppSettings.fromJson(
        (json['settings'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
    );
  }
}
