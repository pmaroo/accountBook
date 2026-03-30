import 'package:flutter/material.dart';

import '../app/theme/app_theme.dart';
import '../data/models/finance_models.dart';
import '../features/assets/assets_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/statistics/statistics_screen.dart';
import '../features/transactions/transactions_screen.dart';
import 'app_controller.dart';

class MoneyBookApp extends StatefulWidget {
  const MoneyBookApp({super.key, this.controllerFuture});

  final Future<AppController>? controllerFuture;

  @override
  State<MoneyBookApp> createState() => _MoneyBookAppState();
}

class _MoneyBookAppState extends State<MoneyBookApp> {
  late final Future<AppController> _controllerFuture;

  @override
  void initState() {
    super.initState();
    _controllerFuture = widget.controllerFuture ?? AppController.create();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTheWeb 가계부',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: FutureBuilder<AppController>(
        future: _controllerFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return MoneyBookShell(controller: snapshot.data!);
        },
      ),
    );
  }
}

class MoneyBookShell extends StatefulWidget {
  const MoneyBookShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<MoneyBookShell> createState() => _MoneyBookShellState();
}

class _MoneyBookShellState extends State<MoneyBookShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final snapshot = widget.controller.snapshot;

        final screens = [
          HomeScreen(snapshot: snapshot, controller: widget.controller),
          TransactionsScreen(snapshot: snapshot, controller: widget.controller),
          AssetsScreen(snapshot: snapshot, controller: widget.controller),
          StatisticsScreen(snapshot: snapshot),
          SettingsScreen(snapshot: snapshot, controller: widget.controller),
        ];

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: '홈',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: '내역',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                label: '자산',
              ),
              NavigationDestination(
                icon: Icon(Icons.insert_chart_outlined_rounded),
                selectedIcon: Icon(Icons.insert_chart_rounded),
                label: '통계',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: '설정',
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> showAmountEditDialog({
  required BuildContext context,
  required String title,
  required int initialPrimaryAmount,
  int? initialSecondaryAmount,
  String primaryLabel = '금액',
  String? secondaryLabel,
  required Future<void> Function(int primary, int? secondary) onSave,
}) async {
  final primaryController = TextEditingController(
    text: initialPrimaryAmount.toString(),
  );
  final secondaryController = TextEditingController(
    text: initialSecondaryAmount?.toString() ?? '',
  );

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: primaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: primaryLabel),
            ),
            if (secondaryLabel != null) ...[
              const SizedBox(height: 12),
              TextField(
                controller: secondaryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: secondaryLabel),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              final primary =
                  int.tryParse(primaryController.text) ?? initialPrimaryAmount;
              final secondary = secondaryLabel == null
                  ? null
                  : int.tryParse(secondaryController.text) ??
                        initialSecondaryAmount;
              await onSave(primary, secondary);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('저장'),
          ),
        ],
      );
    },
  );
}

Future<void> showTransactionFormSheet({
  required BuildContext context,
  required AppController controller,
  required List<BudgetCategory> categories,
  TransactionEntry? existing,
}) async {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final amountController = TextEditingController(
    text: existing?.amount.toString() ?? '',
  );
  var selectedType = existing?.type ?? TransactionType.expense;
  var selectedCategoryId = existing?.categoryId ?? categories.first.id;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final filteredCategories = categories
              .where(
                (category) => selectedType == TransactionType.expense
                    ? category.id != 'income'
                    : true,
              )
              .toList();

          if (!filteredCategories.any(
            (item) => item.id == selectedCategoryId,
          )) {
            selectedCategoryId = filteredCategories.first.id;
          }

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
                  existing == null ? '거래 추가' : '거래 수정',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('지출'),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('수입'),
                    ),
                    ButtonSegment(
                      value: TransactionType.transfer,
                      label: Text('저축/이체'),
                    ),
                  ],
                  selected: {selectedType},
                  onSelectionChanged: (selection) {
                    setModalState(() {
                      selectedType = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '이름'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '금액'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId,
                  decoration: const InputDecoration(labelText: '카테고리'),
                  items: filteredCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setModalState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final amount = int.tryParse(amountController.text);
                      if (titleController.text.trim().isEmpty ||
                          amount == null) {
                        return;
                      }

                      if (existing == null) {
                        await controller.addTransaction(
                          title: titleController.text.trim(),
                          amount: amount,
                          categoryId: selectedCategoryId,
                          type: selectedType,
                        );
                      } else {
                        await controller.updateTransaction(
                          id: existing.id,
                          title: titleController.text.trim(),
                          amount: amount,
                          categoryId: selectedCategoryId,
                          type: selectedType,
                        );
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(existing == null ? '추가하기' : '수정 저장'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
