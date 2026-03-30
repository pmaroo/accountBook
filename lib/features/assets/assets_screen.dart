import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_controller.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/finance_models.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({
    super.key,
    required this.snapshot,
    required this.controller,
  });

  final DashboardSnapshot snapshot;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final yieldRate = snapshot.totalInvestedPrincipal == 0
        ? 0.0
        : (snapshot.totalInvestmentProfit / snapshot.totalInvestedPrincipal) *
              100;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(
            '자산',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '저축 현황과 투자 수익을 연결 계좌 기준으로 확인하세요.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '총 저축',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    Formatters.won(snapshot.totalSaved),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '투자 수익 ${Formatters.won(snapshot.totalInvestmentProfit)} · 수익률 ${Formatters.percent(yieldRate)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '연결된 앱/계좌',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final account in snapshot.accounts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE8F7F4),
                    child: Icon(
                      account.kind == AccountKind.securities
                          ? Icons.show_chart_rounded
                          : Icons.account_balance_rounded,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                  title: Text(
                    account.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '원금 ${Formatters.won(account.principal)} · 평가금액 ${Formatters.won(account.currentBalance)}',
                  ),
                  trailing: Text(
                    Formatters.won(account.profit),
                    style: TextStyle(
                      color: account.profit >= 0
                          ? const Color(0xFF0F766E)
                          : Colors.red,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            '목표 진행률',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final goal in snapshot.goals)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  title: Text(
                    goal.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Formatters.won(goal.currentAmount)} / ${Formatters.won(goal.targetAmount)}',
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 10,
                            value: goal.progress.clamp(0.0, 1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      showAmountEditDialog(
                        context: context,
                        title: goal.title,
                        initialPrimaryAmount: goal.targetAmount,
                        initialSecondaryAmount: goal.currentAmount,
                        primaryLabel: '목표 금액',
                        secondaryLabel: '현재 금액',
                        onSave: (target, current) {
                          return controller.updateGoal(
                            goalId: goal.id,
                            targetAmount: target,
                            currentAmount: current ?? goal.currentAmount,
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: '목표 수정',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
