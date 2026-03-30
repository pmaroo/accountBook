import 'package:flutter/foundation.dart';

import '../data/local/app_storage.dart';
import '../data/local/app_persisted_state.dart';
import '../data/local/app_storage_base.dart';
import '../data/models/finance_models.dart';
import '../data/repositories/mock_finance_repository.dart';
import '../data/services/export_service.dart';
import '../data/services/export_service_base.dart';
import '../data/services/finance_connectors.dart';
import '../data/services/local_alert_service.dart';
import '../data/services/local_alert_service_base.dart';
import '../data/services/notification_service.dart';

class AppController extends ChangeNotifier {
  AppController._({
    required AppStorageBase storage,
    required Map<String, FinanceConnector> connectors,
    required List<BudgetCategory> categories,
    required List<TransactionEntry> transactions,
    required List<LinkedAccount> accounts,
    required List<SavingsGoal> goals,
    required List<SyncProvider> syncProviders,
    required AppSettings settings,
    required NotificationService notificationService,
    required LocalAlertServiceBase alertService,
    required ExportServiceBase exportService,
  }) : _storage = storage,
       _connectors = connectors,
       _notificationService = notificationService,
       _alertService = alertService,
       _exportService = exportService,
       _categories = categories,
       _transactions = transactions,
       _accounts = accounts,
       _goals = goals,
       _syncProviders = syncProviders,
       _settings = settings;

  final AppStorageBase _storage;
  final Map<String, FinanceConnector> _connectors;
  final NotificationService _notificationService;
  final LocalAlertServiceBase _alertService;
  final ExportServiceBase _exportService;

  List<BudgetCategory> _categories;
  List<TransactionEntry> _transactions;
  List<LinkedAccount> _accounts;
  List<SavingsGoal> _goals;
  List<SyncProvider> _syncProviders;
  AppSettings _settings;

  static Future<AppController> create({AppStorageBase? storage}) async {
    final resolvedStorage = storage ?? AppStorage();
    final stored = await resolvedStorage.load();
    final seed = MockFinanceRepository.buildSeedData(DateTime.now());

    return AppController._(
      storage: resolvedStorage,
      connectors: buildFinanceConnectors(),
      notificationService: NotificationService(),
      alertService: LocalAlertService(),
      exportService: ExportService(),
      categories: stored?.categories.isNotEmpty == true
          ? stored!.categories
          : seed.categories,
      transactions: stored?.transactions.isNotEmpty == true
          ? stored!.transactions
          : seed.transactions,
      accounts: stored?.accounts.isNotEmpty == true
          ? stored!.accounts
          : seed.accounts,
      goals: stored?.goals.isNotEmpty == true ? stored!.goals : seed.goals,
      syncProviders: stored?.syncProviders.isNotEmpty == true
          ? stored!.syncProviders
          : seed.syncProviders,
      settings: stored?.settings ?? seed.settings,
    );
  }

  DashboardSnapshot get snapshot {
    return MockFinanceRepository.buildSnapshot(
      now: DateTime.now(),
      categories: _categories,
      transactions: _transactions,
      accounts: _accounts,
      goals: _goals,
      syncProviders: _syncProviders,
      settings: _settings,
    );
  }

  List<BudgetCategory> get categories => List.unmodifiable(_categories);

  List<SavingsGoal> get goals => List.unmodifiable(_goals);

  AppSettings get settings => _settings;

  List<SyncProvider> get syncProviders => List.unmodifiable(_syncProviders);

  List<NotificationMessage> get notificationMessages {
    return _notificationService.buildMessages(snapshot);
  }

  Future<bool> sendLocalNotifications() async {
    return _alertService.sendMessages(notificationMessages);
  }

  Future<ExportResult> exportTransactionsCsv() async {
    return _exportService.exportTransactionsCsv(_transactions);
  }

  Future<ExportResult> exportBackup() async {
    return _exportService.exportBackup(_currentState());
  }

  Future<ImportResult> importSelectedTransactionsCsv() async {
    final result = await _exportService.importSelectedTransactionsCsv();
    return _mergeImportedTransactions(result);
  }

  Future<ImportResult> importLatestTransactionsCsv() async {
    final result = await _exportService.importLatestTransactionsCsv();
    return _mergeImportedTransactions(result);
  }

  Future<ImportResult> restoreSelectedBackup() async {
    final result = await _exportService.restoreSelectedBackup();
    return _applyRestoredState(result);
  }

  Future<ImportResult> restoreLatestBackup() async {
    final result = await _exportService.restoreLatestBackup();
    return _applyRestoredState(result);
  }

  Future<ImportResult> _mergeImportedTransactions(ImportResult result) async {
    if (!result.success || result.transactions.isEmpty) {
      return result;
    }

    final existingIds = _transactions.map((entry) => entry.id).toSet();
    final existingExternalKeys = _transactions
        .where((entry) => entry.providerId != null && entry.externalId != null)
        .map((entry) => '${entry.providerId}:${entry.externalId}')
        .toSet();

    var importedCount = 0;
    for (final transaction in result.transactions) {
      final externalKey =
          transaction.providerId != null && transaction.externalId != null
          ? '${transaction.providerId}:${transaction.externalId}'
          : null;
      final duplicate =
          existingIds.contains(transaction.id) ||
          (externalKey != null && existingExternalKeys.contains(externalKey));
      if (duplicate) {
        continue;
      }
      importedCount++;
      _transactions = [transaction, ..._transactions];
      existingIds.add(transaction.id);
      if (externalKey != null) {
        existingExternalKeys.add(externalKey);
      }
    }

    if (importedCount == 0) {
      return ImportResult(
        success: false,
        message: '새로 가져올 거래가 없습니다. 기존 데이터와 중복됩니다.',
        path: result.path,
      );
    }

    _transactions.sort((a, b) => b.date.compareTo(a.date));
    await _persistAndNotify();

    return ImportResult(
      success: true,
      message: '$importedCount건의 새 거래를 반영했습니다.',
      path: result.path,
      transactions: result.transactions,
    );
  }

  Future<ImportResult> _applyRestoredState(ImportResult result) async {
    final state = result.state;
    if (!result.success || state == null) {
      return result;
    }

    _categories = state.categories;
    _transactions = state.transactions;
    _accounts = state.accounts;
    _goals = state.goals;
    _syncProviders = state.syncProviders;
    _settings = state.settings;
    await _persistAndNotify();

    return result;
  }

  Future<void> addTransaction({
    required String title,
    required int amount,
    required String categoryId,
    required TransactionType type,
  }) async {
    final entry = TransactionEntry(
      id: 'manual-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: DateTime.now(),
      sourceName: '직접 입력',
      isAutoSynced: false,
    );

    _transactions = [entry, ..._transactions];
    await _persistAndNotify();
  }

  Future<void> updateTransaction({
    required String id,
    required String title,
    required int amount,
    required String categoryId,
    required TransactionType type,
  }) async {
    _transactions = _transactions.map((entry) {
      if (entry.id != id) {
        return entry;
      }

      return entry.copyWith(
        title: title,
        amount: amount,
        categoryId: categoryId,
        type: type,
      );
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    await _persistAndNotify();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions = _transactions.where((entry) => entry.id != id).toList();
    await _persistAndNotify();
  }

  Future<void> updateCategoryBudget(
    String categoryId,
    int monthlyBudget,
  ) async {
    _categories = _categories.map((category) {
      if (category.id != categoryId) {
        return category;
      }
      return category.copyWith(monthlyBudget: monthlyBudget);
    }).toList();
    await _persistAndNotify();
  }

  Future<void> addCategory({
    required String name,
    required int monthlyBudget,
    required bool isFixed,
  }) async {
    final entry = BudgetCategory(
      id: 'category-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      monthlyBudget: monthlyBudget,
      isFixed: isFixed,
      colorValue:
          _categoryColorValues[_categories.length %
              _categoryColorValues.length],
      iconCodePoint:
          _categoryIconCodePoints[_categories.length %
              _categoryIconCodePoints.length],
    );

    _categories = [..._categories, entry];
    await _persistAndNotify();
  }

  Future<void> updateCategory({
    required String categoryId,
    required String name,
    required int monthlyBudget,
    required bool isFixed,
  }) async {
    _categories = _categories.map((category) {
      if (category.id != categoryId) {
        return category;
      }
      return category.copyWith(
        name: name,
        monthlyBudget: monthlyBudget,
        isFixed: isFixed,
      );
    }).toList();
    await _persistAndNotify();
  }

  Future<bool> deleteCategory(String categoryId) async {
    final used = _transactions.any((entry) => entry.categoryId == categoryId);
    if (used) {
      return false;
    }
    _categories = _categories
        .where((category) => category.id != categoryId)
        .toList();
    await _persistAndNotify();
    return true;
  }

  Future<void> updateGoal({
    required String goalId,
    required int targetAmount,
    required int currentAmount,
  }) async {
    _goals = _goals.map((goal) {
      if (goal.id != goalId) {
        return goal;
      }
      return goal.copyWith(
        targetAmount: targetAmount,
        currentAmount: currentAmount,
      );
    }).toList();
    await _persistAndNotify();
  }

  Future<void> updateSettings(AppSettings next) async {
    _settings = next;
    await _persistAndNotify();
  }

  Future<void> toggleProviderConnection(
    String providerId,
    bool connected,
  ) async {
    _syncProviders = _syncProviders.map((provider) {
      if (provider.id != providerId) {
        return provider;
      }
      return provider.copyWith(
        isConnected: connected,
        hasPermission: connected ? provider.hasPermission : false,
        authStatus: connected
            ? (provider.hasPermission
                  ? SyncAuthStatus.connected
                  : SyncAuthStatus.authorizationRequired)
            : SyncAuthStatus.disconnected,
        statusMessage: connected ? '연결됨. 인증을 시작해 주세요.' : '앱 연결이 해제되었습니다.',
      );
    }).toList();
    await _persistAndNotify();
  }

  Future<void> updateProviderPermission(
    String providerId,
    bool hasPermission,
  ) async {
    _syncProviders = _syncProviders.map((provider) {
      if (provider.id != providerId) {
        return provider;
      }
      return provider.copyWith(
        hasPermission: hasPermission,
        authStatus: hasPermission
            ? SyncAuthStatus.connected
            : SyncAuthStatus.permissionRequired,
        statusMessage: hasPermission ? '필수 권한 승인이 완료되었습니다.' : '권한 승인이 필요합니다.',
        lastAuthorizedAt: hasPermission
            ? DateTime.now()
            : provider.lastAuthorizedAt,
      );
    }).toList();
    await _persistAndNotify();
  }

  Future<void> startProviderAuthorization(String providerId) async {
    _syncProviders = _syncProviders.map((provider) {
      if (provider.id != providerId) {
        return provider;
      }
      return provider.copyWith(
        isConnected: true,
        hasPermission: false,
        authStatus: SyncAuthStatus.pendingConsent,
        statusMessage: '${provider.name} 앱에서 본인 확인을 기다리고 있습니다.',
      );
    }).toList();
    await _persistAndNotify();
  }

  Future<void> completeProviderAuthorization(
    String providerId, {
    required bool grantTransactions,
    required bool grantBalance,
    required bool grantInvestments,
  }) async {
    _syncProviders = _syncProviders.map((provider) {
      if (provider.id != providerId) {
        return provider;
      }

      final permissionGranted = switch (provider.type) {
        SyncProviderType.bank => grantTransactions && grantBalance,
        SyncProviderType.card => grantTransactions,
        SyncProviderType.investment => grantBalance && grantInvestments,
        SyncProviderType.payment => grantTransactions,
      };

      return provider.copyWith(
        isConnected: true,
        hasPermission: permissionGranted,
        authStatus: permissionGranted
            ? SyncAuthStatus.connected
            : SyncAuthStatus.permissionRequired,
        statusMessage: permissionGranted
            ? '인증과 권한 승인이 완료되었습니다.'
            : '필수 권한이 빠져 있어 추가 승인이 필요합니다.',
        lastAuthorizedAt: permissionGranted
            ? DateTime.now()
            : provider.lastAuthorizedAt,
      );
    }).toList();
    await _persistAndNotify();
  }

  Future<void> markProviderAuthorizationError(
    String providerId,
    String message,
  ) async {
    _syncProviders = _syncProviders.map((provider) {
      if (provider.id != providerId) {
        return provider;
      }
      return provider.copyWith(
        authStatus: SyncAuthStatus.error,
        statusMessage: message,
      );
    }).toList();
    await _persistAndNotify();
  }

  Future<void> syncProvider(String providerId) async {
    final provider = _syncProviders.firstWhere((item) => item.id == providerId);
    if (!_settings.autoSyncEnabled || !provider.isReadyToSync) {
      return;
    }

    final connector = _connectors[providerId];
    if (connector == null) {
      return;
    }

    final payload = await connector.sync(DateTime.now());

    for (final transaction in payload.transactions) {
      final duplicate = _transactions.any(
        (entry) =>
            entry.providerId == transaction.providerId &&
            entry.externalId == transaction.externalId,
      );
      if (!duplicate) {
        _transactions = [transaction, ..._transactions];
      }
    }

    for (final account in payload.accounts) {
      final index = _accounts.indexWhere((item) => item.id == account.id);
      if (index == -1) {
        _accounts = [..._accounts, account];
      } else {
        final next = [..._accounts];
        next[index] = account;
        _accounts = next;
      }
    }

    _syncProviders = _syncProviders.map((item) {
      if (item.id != providerId) {
        return item;
      }
      return item.copyWith(
        authStatus: SyncAuthStatus.connected,
        statusMessage: '최근 데이터를 성공적으로 동기화했습니다.',
        lastSyncedAt: DateTime.now(),
      );
    }).toList();

    await _persistAndNotify();
  }

  Future<void> resetToSeed() async {
    final seed = MockFinanceRepository.buildSeedData(DateTime.now());
    _categories = seed.categories;
    _transactions = seed.transactions;
    _accounts = seed.accounts;
    _goals = seed.goals;
    _syncProviders = seed.syncProviders;
    _settings = seed.settings;
    await _persistAndNotify();
  }

  Future<void> _persistAndNotify() async {
    await _storage.save(_currentState());
    notifyListeners();
  }

  AppPersistedState _currentState() {
    return AppPersistedState(
      categories: _categories,
      transactions: _transactions,
      accounts: _accounts,
      goals: _goals,
      syncProviders: _syncProviders,
      settings: _settings,
    );
  }
}

const _categoryColorValues = [
  0xFFE76F51,
  0xFF577590,
  0xFF2A9D8F,
  0xFF355070,
  0xFF8E7DBE,
];

const _categoryIconCodePoints = [0xe56c, 0xe59c, 0xe227, 0xe491, 0xe3d4];
