import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/finance_models.dart';
import 'app_persisted_state.dart';
import 'app_storage_base.dart';

class AppStorage implements AppStorageBase {
  static const _databaseName = 'money_book.db';
  static const _settingsRowId = 1;
  static bool _ffiInitialized = false;

  @override
  Future<AppPersistedState?> load() async {
    final db = await _openDatabase();
    try {
      final settingsRows = await db.query(
        'settings',
        where: 'id = ?',
        whereArgs: [_settingsRowId],
      );
      if (settingsRows.isEmpty) {
        return null;
      }

      final categories = (await db.query(
        'categories',
      )).map(BudgetCategory.fromJson).toList();
      final transactions = (await db.query(
        'transactions',
      )).map(TransactionEntry.fromJson).toList();
      final accounts = (await db.query(
        'accounts',
      )).map(LinkedAccount.fromJson).toList();
      final goals = (await db.query(
        'goals',
      )).map(SavingsGoal.fromJson).toList();
      final syncProviders = (await db.query(
        'sync_providers',
      )).map(SyncProvider.fromJson).toList();

      return AppPersistedState(
        categories: categories,
        transactions: transactions,
        accounts: accounts,
        goals: goals,
        syncProviders: syncProviders,
        settings: AppSettings.fromJson(settingsRows.first),
      );
    } finally {
      await db.close();
    }
  }

  @override
  Future<void> save(AppPersistedState state) async {
    final db = await _openDatabase();
    try {
      await db.transaction((txn) async {
        await txn.delete('categories');
        await txn.delete('transactions');
        await txn.delete('accounts');
        await txn.delete('goals');
        await txn.delete('sync_providers');
        await txn.delete('settings');

        for (final category in state.categories) {
          await txn.insert('categories', category.toJson());
        }
        for (final transaction in state.transactions) {
          await txn.insert('transactions', transaction.toJson());
        }
        for (final account in state.accounts) {
          await txn.insert('accounts', account.toJson());
        }
        for (final goal in state.goals) {
          await txn.insert('goals', goal.toJson());
        }
        for (final provider in state.syncProviders) {
          await txn.insert('sync_providers', provider.toJson());
        }
        await txn.insert('settings', {
          'id': _settingsRowId,
          ...state.settings.toJson(),
        });
      });
    } finally {
      await db.close();
    }
  }

  @override
  Future<void> clear() async {
    final db = await _openDatabase();
    try {
      await db.delete('categories');
      await db.delete('transactions');
      await db.delete('accounts');
      await db.delete('goals');
      await db.delete('sync_providers');
      await db.delete('settings');
    } finally {
      await db.close();
    }
  }

  Future<Database> _openDatabase() async {
    if (!_ffiInitialized && !(Platform.isAndroid || Platform.isIOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _ffiInitialized = true;
    }

    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, _databaseName);

    return openDatabase(
      fullPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            monthlyBudget INTEGER NOT NULL,
            isFixed INTEGER NOT NULL,
            colorValue INTEGER NOT NULL,
            iconCodePoint INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL,
            type TEXT NOT NULL,
            categoryId TEXT NOT NULL,
            date TEXT NOT NULL,
            sourceName TEXT NOT NULL,
            isAutoSynced INTEGER NOT NULL,
            providerId TEXT,
            externalId TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE accounts(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            kind TEXT NOT NULL,
            principal INTEGER NOT NULL,
            currentBalance INTEGER NOT NULL,
            isLinked INTEGER NOT NULL,
            providerId TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE goals(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            targetAmount INTEGER NOT NULL,
            currentAmount INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sync_providers(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            isConnected INTEGER NOT NULL,
            hasPermission INTEGER NOT NULL,
            authStatus TEXT NOT NULL,
            lastSyncedAt TEXT,
            statusMessage TEXT,
            lastAuthorizedAt TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE settings(
            id INTEGER PRIMARY KEY,
            autoSyncEnabled INTEGER NOT NULL,
            savingsTipsEnabled INTEGER NOT NULL,
            challengeReminderEnabled INTEGER NOT NULL,
            challengeDailyTarget INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE sync_providers ADD COLUMN authStatus TEXT NOT NULL DEFAULT 'disconnected'",
          );
          await db.execute(
            'ALTER TABLE sync_providers ADD COLUMN statusMessage TEXT',
          );
          await db.execute(
            'ALTER TABLE sync_providers ADD COLUMN lastAuthorizedAt TEXT',
          );
          await db.execute('''
            UPDATE sync_providers
            SET authStatus = CASE
              WHEN isConnected = 1 AND hasPermission = 1 THEN 'connected'
              WHEN isConnected = 1 THEN 'permissionRequired'
              ELSE 'disconnected'
            END
          ''');
        }
      },
    );
  }
}
