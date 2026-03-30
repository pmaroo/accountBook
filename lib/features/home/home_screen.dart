import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_controller.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/finance_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.snapshot,
    required this.controller,
  });

  final DashboardSnapshot snapshot;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '가계부',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '오늘 예산과 지난달 대비 흐름을 함께 확인하세요.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  showTransactionFormSheet(
                    context: context,
                    controller: controller,
                    categories: controller.categories,
                  );
                },
                icon: const Icon(Icons.add_circle_outline_rounded),
                tooltip: '거래 추가',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _HeroSummary(snapshot: snapshot),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: '전월 대비 지출',
                  value: snapshot.monthlyExpenseDiff >= 0
                      ? '+${Formatters.won(snapshot.monthlyExpenseDiff)}'
                      : '-${Formatters.won(snapshot.monthlyExpenseDiff.abs())}',
                  helper:
                      '지난달 ${Formatters.percent(snapshot.monthlyExpenseDiffRate.abs())}',
                  icon: snapshot.monthlyExpenseDiff >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  accentColor: snapshot.monthlyExpenseDiff >= 0
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: '이번 주 소비 속도',
                  value: Formatters.won(snapshot.weeklyExpense),
                  helper: snapshot.weeklyExpenseDiff >= 0
                      ? '지난주보다 ${Formatters.won(snapshot.weeklyExpenseDiff)} 빠름'
                      : '지난주보다 ${Formatters.won(snapshot.weeklyExpenseDiff.abs())} 절약',
                  icon: Icons.local_fire_department_rounded,
                  accentColor: snapshot.weeklyExpenseDiff >= 0
                      ? const Color(0xFFE67E22)
                      : const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: '이번 달 수입',
                  value: Formatters.won(snapshot.monthlyIncome),
                  helper: '저축률 ${Formatters.percent(snapshot.savingsRate)}',
                  icon: Icons.south_west_rounded,
                  accentColor: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: '투자 수익',
                  value: Formatters.won(snapshot.totalInvestmentProfit),
                  helper: '자동 연동 ${Formatters.percent(snapshot.autoSyncRate)}',
                  icon: Icons.account_balance_wallet_rounded,
                  accentColor: const Color(0xFF0F766E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DailyAllowanceCard(snapshot: snapshot),
          const SizedBox(height: 16),
          _WeekPulseCard(snapshot: snapshot),
          const SizedBox(height: 16),
          _ChallengeCard(challenge: snapshot.challenge),
          const SizedBox(height: 24),
          Text(
            '절약 우선순위',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final insight in snapshot.priorityInsights)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_circle_rounded),
                  title: Text(insight),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            '카테고리 예산',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final status in snapshot.categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BudgetStatusCard(status: status),
            ),
          const SizedBox(height: 12),
          Text(
            '오늘의 절약 플랜',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final insight in snapshot.insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline_rounded),
                  title: Text(insight),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF115E59), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 달 총 저축 가능 금액',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Text(
            Formatters.won(snapshot.remainingBudget),
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '현재 저축 ${Formatters.won(snapshot.totalSaved)} · 지난달 지출 ${Formatters.won(snapshot.lastMonthExpense)}',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(height: 14),
            Text(label, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              helper,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyAllowanceCard extends StatelessWidget {
  const _DailyAllowanceCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDanger =
        snapshot.todayAllowance <= snapshot.settings.challengeDailyTarget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: (isDanger ? Colors.red : Colors.orange).withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                isDanger ? Icons.warning_amber_rounded : Icons.schedule_rounded,
                color: isDanger ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘 쓸 수 있는 금액',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.won(snapshot.todayAllowance),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDanger ? Colors.red : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDanger
                        ? '예산이 빠듯해요. 오늘은 꼭 필요한 지출만 추천해요.'
                        : '남은 예산과 챌린지 기준을 반영해 자동 계산했어요.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekPulseCard extends StatelessWidget {
  const _WeekPulseCard({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHot = snapshot.weeklyExpenseDiff > 0;

    return Card(
      color: isHot ? const Color(0xFFFFF3E8) : const Color(0xFFEDF6FF),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 주 소비 속도',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '이번 주 ${Formatters.won(snapshot.weeklyExpense)} 사용',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHot
                  ? '지난주보다 ${Formatters.won(snapshot.weeklyExpenseDiff)} 더 빠른 소비 흐름이에요.'
                  : '지난주보다 ${Formatters.won(snapshot.weeklyExpenseDiff.abs())} 덜 써서 안정적이에요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isHot
                    ? const Color(0xFFB45309)
                    : const Color(0xFF1D4ED8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final SpendingChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overAmount = challenge.todaySpent - challenge.dailyTarget;

    return Card(
      color: challenge.isSuccessful
          ? const Color(0xFFE8F7F4)
          : const Color(0xFFFFECEB),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '오늘 사용 ${Formatters.won(challenge.todaySpent)} / 목표 ${Formatters.won(challenge.dailyTarget)}',
            ),
            const SizedBox(height: 8),
            Text(
              challenge.isSuccessful
                  ? '아직 챌린지 성공 구간이에요. 오늘은 더 안 써도 좋습니다.'
                  : '${Formatters.won(overAmount)} 초과했어요. 빨간 신호입니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: challenge.isSuccessful
                    ? const Color(0xFF0F766E)
                    : Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetStatusCard extends StatelessWidget {
  const _BudgetStatusCard({required this.status});

  final CategoryBudgetStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = status.progress.clamp(0.0, 1.0);
    final accent = status.isOverBudget
        ? Colors.red
        : status.isWarning
        ? Colors.orange
        : status.category.color;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: status.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    status.category.icon,
                    color: status.category.color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.category.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        status.category.isFixed ? '고정지출/고정저축' : '변동지출',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  status.isOverBudget
                      ? '-${Formatters.won(status.remaining.abs())}'
                      : Formatters.won(status.remaining),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: progress,
                color: accent,
                backgroundColor: const Color(0xFFE8ECE9),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('사용 ${Formatters.won(status.spent)}'),
                Text('하루 ${Formatters.won(status.dailyAllowance)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
