import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_controller.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/finance_models.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
    required this.snapshot,
    required this.controller,
  });

  final DashboardSnapshot snapshot;
  final AppController controller;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final entries = widget.snapshot.transactions.where((entry) {
      final matchesType = _typeFilter == null || entry.type == _typeFilter;
      final matchesQuery =
          query.isEmpty ||
          entry.title.toLowerCase().contains(query) ||
          entry.sourceName.toLowerCase().contains(query);
      return matchesType && matchesQuery;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    final grouped = <String, List<TransactionEntry>>{};
    for (final entry in entries) {
      final key =
          '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('내역')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showTransactionFormSheet(
              context: context,
              controller: widget.controller,
              categories: widget.controller.categories,
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('내역 추가'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryBlock(
                            label: '이번 달 지출',
                            value: Formatters.won(
                              widget.snapshot.monthlyExpense,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _SummaryBlock(
                            label: '자동 연동',
                            value:
                                '${widget.snapshot.transactions.where((entry) => entry.isAutoSynced).length}건',
                          ),
                        ),
                        Expanded(
                          child: _SummaryBlock(
                            label: '수동 입력',
                            value:
                                '${widget.snapshot.transactions.where((entry) => !entry.isAutoSynced).length}건',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: '이름 또는 결제처 검색',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('CSV 내보내기'),
                          avatar: const Icon(
                            Icons.file_download_outlined,
                            size: 18,
                          ),
                          onPressed: () async {
                            final result = await widget.controller
                                .exportTransactionsCsv();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result.path == null
                                        ? result.message
                                        : '${result.message}\n${result.path}',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        ActionChip(
                          label: const Text('CSV 파일 선택'),
                          avatar: const Icon(
                            Icons.folder_open_rounded,
                            size: 18,
                          ),
                          onPressed: () async {
                            final result = await widget.controller
                                .importSelectedTransactionsCsv();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result.path == null
                                        ? result.message
                                        : '${result.message}\n${result.path}',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        ActionChip(
                          label: const Text('CSV 가져오기'),
                          avatar: const Icon(
                            Icons.file_upload_outlined,
                            size: 18,
                          ),
                          onPressed: () async {
                            final result = await widget.controller
                                .importLatestTransactionsCsv();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result.path == null
                                        ? result.message
                                        : '${result.message}\n${result.path}',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        FilterChip(
                          label: const Text('전체'),
                          selected: _typeFilter == null,
                          onSelected: (_) {
                            setState(() {
                              _typeFilter = null;
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('지출'),
                          selected: _typeFilter == TransactionType.expense,
                          onSelected: (_) {
                            setState(() {
                              _typeFilter = TransactionType.expense;
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('수입'),
                          selected: _typeFilter == TransactionType.income,
                          onSelected: (_) {
                            setState(() {
                              _typeFilter = TransactionType.income;
                            });
                          },
                        ),
                        FilterChip(
                          label: const Text('저축/이체'),
                          selected: _typeFilter == TransactionType.transfer,
                          onSelected: (_) {
                            setState(() {
                              _typeFilter = TransactionType.transfer;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (entries.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('조건에 맞는 거래 내역이 없습니다.'),
                ),
              ),
            for (final group in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 8),
                child: Text(
                  '${group.key.split('-')[0]}년 ${group.key.split('-')[1]}월',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              for (final entry in group.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        showTransactionDetailSheet(
                          context: context,
                          entry: entry,
                          controller: widget.controller,
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: entry.isAutoSynced
                            ? const Color(0xFFE8F7F4)
                            : const Color(0xFFFFF4E5),
                        child: Icon(
                          entry.isAutoSynced
                              ? Icons.sync_rounded
                              : Icons.edit_note_rounded,
                          color: entry.isAutoSynced
                              ? const Color(0xFF0F766E)
                              : const Color(0xFFE67E22),
                        ),
                      ),
                      title: Text(
                        entry.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${Formatters.monthDay(entry.date)} · ${entry.sourceName}',
                      ),
                      trailing: Text(
                        entry.type == TransactionType.income
                            ? '+${Formatters.won(entry.amount)}'
                            : '-${Formatters.won(entry.amount)}',
                        style: TextStyle(
                          color: entry.type == TransactionType.income
                              ? const Color(0xFF0F766E)
                              : Colors.red,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

Future<void> showTransactionDetailSheet({
  required BuildContext context,
  required TransactionEntry entry,
  required AppController controller,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '거래 상세',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            _DetailRow(label: '이름', value: entry.title),
            _DetailRow(
              label: '금액',
              value: entry.type == TransactionType.income
                  ? '+${Formatters.won(entry.amount)}'
                  : '-${Formatters.won(entry.amount)}',
            ),
            _DetailRow(label: '날짜', value: Formatters.monthDay(entry.date)),
            _DetailRow(label: '결제처', value: entry.sourceName),
            _DetailRow(
              label: '입력 방식',
              value: entry.isAutoSynced ? '자동 연동' : '수동 입력',
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await showTransactionFormSheet(
                        context: context,
                        controller: controller,
                        categories: controller.categories,
                        existing: entry,
                      );
                    },
                    child: const Text('수정'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await controller.deleteTransaction(entry.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('삭제'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
