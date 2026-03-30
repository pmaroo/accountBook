import 'dart:convert';

import 'package:file_picker/file_picker.dart';

import '../models/finance_models.dart';
import '../local/app_persisted_state.dart';
import 'export_service_base.dart';

class ExportService implements ExportServiceBase {
  @override
  Future<ExportResult> exportTransactionsCsv(
    List<TransactionEntry> entries,
  ) async {
    return const ExportResult(
      success: false,
      message: '웹에서는 현재 CSV 파일 저장을 지원하지 않습니다.',
    );
  }

  @override
  Future<ExportResult> exportBackup(AppPersistedState state) async {
    return const ExportResult(
      success: false,
      message: '웹에서는 현재 백업 파일 저장을 지원하지 않습니다.',
    );
  }

  @override
  Future<ImportResult> importSelectedTransactionsCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
      dialogTitle: '가져올 거래 CSV 파일 선택',
    );
    final file = result?.files.singleOrNull;
    final bytes = file?.bytes;
    if (bytes == null) {
      return const ImportResult(success: false, message: 'CSV 파일 선택이 취소되었습니다.');
    }

    final lines = utf8
        .decode(bytes)
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.length <= 1) {
      return ImportResult(
        success: false,
        message: 'CSV 파일에 거래 내역이 없습니다.',
        path: file?.name,
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
      path: file?.name,
      transactions: entries,
    );
  }

  @override
  Future<ImportResult> importLatestTransactionsCsv() async {
    return const ImportResult(
      success: false,
      message: '웹에서는 현재 CSV 가져오기를 지원하지 않습니다.',
    );
  }

  @override
  Future<ImportResult> restoreSelectedBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
      dialogTitle: '복원할 백업 JSON 파일 선택',
    );
    final file = result?.files.singleOrNull;
    final bytes = file?.bytes;
    if (bytes == null) {
      return const ImportResult(success: false, message: '백업 파일 선택이 취소되었습니다.');
    }

    final state = AppPersistedState.fromJson(
      jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
    );

    return ImportResult(
      success: true,
      message: '선택한 백업 파일을 불러왔습니다.',
      path: file?.name,
      state: state,
    );
  }

  @override
  Future<ImportResult> restoreLatestBackup() async {
    return const ImportResult(
      success: false,
      message: '웹에서는 현재 백업 복원을 지원하지 않습니다.',
    );
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
