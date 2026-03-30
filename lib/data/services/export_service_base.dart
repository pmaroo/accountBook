import '../models/finance_models.dart';
import '../local/app_persisted_state.dart';

class ExportResult {
  const ExportResult({required this.success, required this.message, this.path});

  final bool success;
  final String message;
  final String? path;
}

class ImportResult {
  const ImportResult({
    required this.success,
    required this.message,
    this.path,
    this.transactions = const [],
    this.state,
  });

  final bool success;
  final String message;
  final String? path;
  final List<TransactionEntry> transactions;
  final AppPersistedState? state;
}

abstract class ExportServiceBase {
  Future<ExportResult> exportTransactionsCsv(List<TransactionEntry> entries);

  Future<ExportResult> exportBackup(AppPersistedState state);

  Future<ImportResult> importSelectedTransactionsCsv();

  Future<ImportResult> importLatestTransactionsCsv();

  Future<ImportResult> restoreSelectedBackup();

  Future<ImportResult> restoreLatestBackup();
}
