import '../models/finance_models.dart';

class ConnectorPayload {
  const ConnectorPayload({required this.transactions, required this.accounts});

  final List<TransactionEntry> transactions;
  final List<LinkedAccount> accounts;
}

abstract class FinanceConnector {
  String get providerId;

  Future<ConnectorPayload> sync(DateTime now);
}

class TossBankConnector implements FinanceConnector {
  @override
  String get providerId => 'toss_bank';

  @override
  Future<ConnectorPayload> sync(DateTime now) async {
    return ConnectorPayload(
      transactions: [
        TransactionEntry(
          id: 'sync-toss-${now.microsecondsSinceEpoch}',
          title: '편의점 간식',
          amount: 4300,
          type: TransactionType.expense,
          categoryId: 'food',
          date: now,
          sourceName: '토스뱅크',
          isAutoSynced: true,
          providerId: providerId,
          externalId: 'toss-snack-${now.year}-${now.month}-${now.day}',
        ),
      ],
      accounts: [
        const LinkedAccount(
          id: 'a1',
          name: '토스뱅크 자유적금',
          kind: AccountKind.bank,
          principal: 2200000,
          currentBalance: 2279000,
          isLinked: true,
          providerId: 'toss_bank',
        ),
      ],
    );
  }
}

class HyundaiCardConnector implements FinanceConnector {
  @override
  String get providerId => 'hyundai_card';

  @override
  Future<ConnectorPayload> sync(DateTime now) async {
    return ConnectorPayload(
      transactions: [
        TransactionEntry(
          id: 'sync-hc-${now.microsecondsSinceEpoch}',
          title: '배달앱 결제',
          amount: 21900,
          type: TransactionType.expense,
          categoryId: 'food',
          date: now.subtract(const Duration(hours: 2)),
          sourceName: '현대카드',
          isAutoSynced: true,
          providerId: providerId,
          externalId: 'hyundai-delivery-${now.year}-${now.month}-${now.day}',
        ),
      ],
      accounts: const [],
    );
  }
}

class MiraeAssetConnector implements FinanceConnector {
  @override
  String get providerId => 'mirae_asset';

  @override
  Future<ConnectorPayload> sync(DateTime now) async {
    return ConnectorPayload(
      transactions: const [],
      accounts: [
        const LinkedAccount(
          id: 'a2',
          name: '미래에셋 ISA',
          kind: AccountKind.securities,
          principal: 1800000,
          currentBalance: 1968000,
          isLinked: true,
          providerId: 'mirae_asset',
        ),
      ],
    );
  }
}

Map<String, FinanceConnector> buildFinanceConnectors() {
  return {
    'toss_bank': TossBankConnector(),
    'hyundai_card': HyundaiCardConnector(),
    'mirae_asset': MiraeAssetConnector(),
  };
}
