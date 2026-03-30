import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/finance_models.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key, required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentMonth = snapshot.monthlyTrend.isNotEmpty
        ? snapshot.monthlyTrend.last
        : MonthlySpendingSummary(
            year: DateTime.now().year,
            month: DateTime.now().month,
            income: snapshot.monthlyIncome,
            expense: snapshot.monthlyExpense,
            transfer: 0,
          );
    final previousMonth = snapshot.monthlyTrend.length > 1
        ? snapshot.monthlyTrend[snapshot.monthlyTrend.length - 2]
        : currentMonth;
    final expenseDiff = currentMonth.expense - previousMonth.expense;
    final topCategory = [...snapshot.categories]
      ..sort((a, b) => b.spent.compareTo(a.spent));
    final mostSpentCategory = topCategory.isEmpty
        ? null
        : topCategory.first.category.name;
    final maxTrendValue = snapshot.monthlyTrend.fold<int>(
      0,
      (max, item) => [
        item.expense,
        item.income,
        item.transfer,
        max,
      ].reduce((a, b) => a > b ? a : b),
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(
            '통계',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '이번 달 소비 패턴과 지난달 대비 변화까지 한눈에 확인하세요.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '총 지출',
                  value: Formatters.won(snapshot.monthlyExpense),
                  helper: expenseDiff >= 0
                      ? '지난달보다 ${Formatters.won(expenseDiff)} 증가'
                      : '지난달보다 ${Formatters.won(expenseDiff.abs())} 절약',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: '자동 연동 비율',
                  value: Formatters.percent(snapshot.autoSyncRate),
                  helper: '이번 달 지출 기준',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '가장 많이 쓴 항목',
                  value: mostSpentCategory ?? '-',
                  helper: mostSpentCategory == null ? '' : '이번 달 최다 지출',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: '남은 예산',
                  value: Formatters.won(snapshot.remainingBudget),
                  helper: '저축 가능 ${Formatters.percent(snapshot.savingsRate)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '3개월 흐름',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '수입 · 지출 · 저축/이체 비교',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final summary in snapshot.monthlyTrend)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _MonthlyTrendRow(
                        summary: summary,
                        maxValue: maxTrendValue == 0 ? 1 : maxTrendValue,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '카테고리 소비 추세',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '변동지출 월별 비교',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final group in _groupCategoryTrends(
                    snapshot.categoryTrends,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _CategoryTrendCard(points: group),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '카테고리별 사용량',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final status in snapshot.categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CategoryUsageRow(status: status),
            ),
          const SizedBox(height: 18),
          Text(
            '절약 제안 리포트',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final insight in snapshot.insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.auto_graph_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(insight)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<List<CategoryTrendPoint>> _groupCategoryTrends(
    List<CategoryTrendPoint> points,
  ) {
    final map = <String, List<CategoryTrendPoint>>{};
    for (final point in points) {
      map.putIfAbsent(point.categoryId, () => []).add(point);
    }
    return map.values.toList();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
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

class _MonthlyTrendRow extends StatelessWidget {
  const _MonthlyTrendRow({required this.summary, required this.maxValue});

  final MonthlySpendingSummary summary;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${summary.year}년 ${summary.month}월',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _MiniBar(
          label: '수입',
          value: summary.income,
          maxValue: maxValue,
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 8),
        _MiniBar(
          label: '지출',
          value: summary.expense,
          maxValue: maxValue,
          color: const Color(0xFFE76F51),
        ),
        const SizedBox(height: 8),
        _MiniBar(
          label: '저축/이체',
          value: summary.transfer,
          maxValue: maxValue,
          color: const Color(0xFF0F766E),
        ),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = maxValue == 0 ? 0.0 : value / maxValue;

    return Row(
      children: [
        SizedBox(width: 56, child: Text(label)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: progress,
              color: color,
              backgroundColor: const Color(0xFFE8ECE9),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 88,
          child: Text(Formatters.won(value), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

class _CategoryTrendCard extends StatelessWidget {
  const _CategoryTrendCard({required this.points});

  final List<CategoryTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<int>(
      1,
      (max, point) => point.amount > max ? point.amount : max,
    );
    final categoryName = points.first.categoryName;
    final categoryColor = points.first.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              categoryName,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final point in points)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Text(
                        Formatters.won(point.amount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: point.amount / maxValue,
                          widthFactor: 0.65,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: point.color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(point.label),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryUsageRow extends StatelessWidget {
  const _CategoryUsageRow({required this.status});

  final CategoryBudgetStatus status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status.category.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(Formatters.won(status.spent)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 14,
            value: status.progress.clamp(0.0, 1.0),
            color: status.category.color,
            backgroundColor: const Color(0xFFE6ECE8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '예산 ${Formatters.won(status.category.monthlyBudget)} · 남은 금액 ${Formatters.won(status.remaining)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}
