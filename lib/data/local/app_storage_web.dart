import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/finance_models.dart';
import 'app_persisted_state.dart';
import 'app_storage_base.dart';

class AppStorage implements AppStorageBase {
  static const _categoriesKey = 'categories';
  static const _transactionsKey = 'transactions';
  static const _accountsKey = 'accounts';
  static const _goalsKey = 'goals';
  static const _providersKey = 'providers';
  static const _settingsKey = 'settings';

  @override
  Future<AppPersistedState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_settingsKey);
    if (settingsString == null) {
      return null;
    }

    return AppPersistedState(
      categories: _decodeList(
        prefs.getString(_categoriesKey),
        BudgetCategory.fromJson,
      ),
      transactions: _decodeList(
        prefs.getString(_transactionsKey),
        TransactionEntry.fromJson,
      ),
      accounts: _decodeList(
        prefs.getString(_accountsKey),
        LinkedAccount.fromJson,
      ),
      goals: _decodeList(prefs.getString(_goalsKey), SavingsGoal.fromJson),
      syncProviders: _decodeList(
        prefs.getString(_providersKey),
        SyncProvider.fromJson,
      ),
      settings: AppSettings.fromJson(
        jsonDecode(settingsString) as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<void> save(AppPersistedState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoriesKey, _encodeList(state.categories));
    await prefs.setString(_transactionsKey, _encodeList(state.transactions));
    await prefs.setString(_accountsKey, _encodeList(state.accounts));
    await prefs.setString(_goalsKey, _encodeList(state.goals));
    await prefs.setString(_providersKey, _encodeList(state.syncProviders));
    await prefs.setString(_settingsKey, jsonEncode(state.settings.toJson()));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_categoriesKey);
    await prefs.remove(_transactionsKey);
    await prefs.remove(_accountsKey);
    await prefs.remove(_goalsKey);
    await prefs.remove(_providersKey);
    await prefs.remove(_settingsKey);
  }

  String _encodeList(List<dynamic> items) {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }

  List<T> _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
