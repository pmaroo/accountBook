import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../local/app_persisted_state.dart';
import '../models/finance_models.dart';
import 'export_service_base.dart';

class ExportService implements ExportServiceBase {
  @override
  Future<ExportResult> exportTransactionsCsv(
    List<TransactionEntry> entries,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final filename =
        'transactions_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv';
    final file = File(path.join(directory.path, filename));

    final lines = <String>[
      'id,title,amount,type,categoryId,date,sourceName,isAutoSynced,providerId,externalId',
      ...entries.map((entry) {
        return [
          entry.id,
          _escape(entry.title),
          entry.amount.toString(),
          entry.type.name,
          entry.categoryId,
          entry.date.toIso8601String(),
          _escape(entry.sourceName),
          entry.isAutoSynced.toString(),
          entry.providerId ?? '',
          entry.externalId ?? '',
        ].join(',');
      }),
    ];

    await file.writeAsString(lines.join('\n'));

    return ExportResult(
      success: true,
      message: 'CSV 파일을 저장했습니다.',
      path: file.path,
    );
  }

  @override
  Future<ExportResult> exportBackup(AppPersistedState state) async {
    final directory = await getApplicationDocumentsDirectory();
    final filename =
        'backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    final file = File(path.join(directory.path, filename));

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(state.toJson()),
    );

    return ExportResult(
      success: true,
      message: '백업 파일을 저장했습니다.',
      path: file.path,
    );
  }

  @override
  Future<ImportResult> importSelectedTransactionsCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      dialogTitle: '가져올 거래 CSV 파일 선택',
    );
    final selectedPath = result?.files.singleOrNull?.path;
    if (selectedPath == null) {
      return const ImportResult(success: false, message: 'CSV 파일 선택이 취소되었습니다.');
    }

    return _importTransactionsFromCsvFile(File(selectedPath));
  }

  @override
  Future<ImportResult> importLatestTransactionsCsv() async {
    final file = await _latestFile(prefix: 'transactions_', extension: '.csv');
    if (file == null) {
      return const ImportResult(success: false, message: '가져올 CSV 파일이 없습니다.');
    }

    return _importTransactionsFromCsvFile(file);
  }

  @override
  Future<ImportResult> restoreSelectedBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      dialogTitle: '복원할 백업 JSON 파일 선택',
    );
    final selectedPath = result?.files.singleOrNull?.path;
    if (selectedPath == null) {
      return const ImportResult(success: false, message: '백업 파일 선택이 취소되었습니다.');
    }

    return _restoreBackupFromFile(File(selectedPath));
  }

  @override
  Future<ImportResult> restoreLatestBackup() async {
    final file = await _latestFile(prefix: 'backup_', extension: '.json');
    if (file == null) {
      return const ImportResult(success: false, message: '복원할 백업 파일이 없습니다.');
    }

    return _restoreBackupFromFile(file);
  }

  Future<ImportResult> _importTransactionsFromCsvFile(File file) async {
    final raw = await file.readAsString();
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.length <= 1) {
      return ImportResult(
        success: false,
        message: 'CSV 파일에 거래 내역이 없습니다.',
        path: file.path,
      );
    }

    final entries = <TransactionEntry>[];
    for (final line in lines.skip(1)) {
      final values = _parseCsvLine(line);
      if (values.length < 10) {
        continue;
      }

      entries.add(
        TransactionEntry(
          id: values[0],
          title: values[1],
          amount: int.tryParse(values[2]) ?? 0,
          type: transactionTypeFromName(values[3]),
          categoryId: values[4],
          date: DateTime.tryParse(values[5]) ?? DateTime.now(),
          sourceName: values[6],
          isAutoSynced: bool.tryParse(values[7]) ?? false,
          providerId: values[8].isEmpty ? null : values[8],
          externalId: values[9].isEmpty ? null : values[9],
        ),
      );
    }

    return ImportResult(
      success: entries.isNotEmpty,
      message: entries.isEmpty
          ? 'CSV 파일에서 읽을 수 있는 거래가 없습니다.'
          : '${entries.length}건의 거래를 CSV에서 가져왔습니다.',
      path: file.path,
      transactions: entries,
    );
  }

  Future<ImportResult> _restoreBackupFromFile(File file) async {
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final state = AppPersistedState.fromJson(json);

    return ImportResult(
      success: true,
      message: '최신 백업 파일을 불러왔습니다.',
      path: file.path,
      state: state,
    );
  }

  String _escape(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<File?> _latestFile({
    required String prefix,
    required String extension,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final files =
        directory
            .listSync()
            .whereType<File>()
            .where(
              (file) =>
                  path.basename(file.path).startsWith(prefix) &&
                  file.path.endsWith(extension),
            )
            .toList()
          ..sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
          );

    return files.isEmpty ? null : files.first;
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var index = 0; index < line.length; index++) {
      final char = line[index];
      final next = index + 1 < line.length ? line[index + 1] : null;

      if (char == '"') {
        if (inQuotes && next == '"') {
          buffer.write('"');
          index++;
          continue;
        }
        inQuotes = !inQuotes;
        continue;
      }

      if (char == ',' && !inQuotes) {
        values.add(buffer.toString());
        buffer.clear();
        continue;
      }

      buffer.write(char);
    }

    values.add(buffer.toString());
    return values;
  }
}
