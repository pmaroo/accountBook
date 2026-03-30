import 'package:flutter/material.dart';

import '../models/finance_models.dart';

class SeedDataBundle {
  const SeedDataBundle({
    required this.categories,
    required this.transactions,
    required this.accounts,
    required this.goals,
    required this.syncProviders,
    required this.settings,
  });

  final List<BudgetCategory> categories;
  final List<TransactionEntry> transactions;
  final List<LinkedAccount> accounts;
  final List<SavingsGoal> goals;
  final List<SyncProvider> syncProviders;
  final AppSettings settings;
}

class MockFinanceRepository {
  static SeedDataBundle buildSeedData(DateTime now) {
    final previousMonth = DateTime(now.year, now.month - 1, 12);
    final twoMonthsAgo = DateTime(now.year, now.month - 2, 12);

    return SeedDataBundle(
      categories: [
        BudgetCategory(
          id: 'food',
          name: '식비',
          monthlyBudget: 300000,
          isFixed: false,
          colorValue: 0xFFE76F51,
          iconCodePoint: Icons.restaurant_rounded.codePoint,
        ),
        BudgetCategory(
          id: 'rent',
          name: '월세',
          monthlyBudget: 650000,
          isFixed: true,
          colorValue: 0xFF355070,
          iconCodePoint: Icons.home_work_rounded.codePoint,
        ),
        BudgetCategory(
          id: 'living',
          name: '생활비',
          monthlyBudget: 220000,
          isFixed: false,
          colorValue: 0xFF577590,
          iconCodePoint: Icons.shopping_basket_rounded.codePoint,
        ),
        BudgetCategory(
          id: 'travel',
          name: '여행저축',
          monthlyBudget: 180000,
          isFixed: true,
          colorValue: 0xFF2A9D8F,
          iconCodePoint: Icons.luggage_rounded.codePoint,
        ),
        BudgetCategory(
          id: 'emergency',
          name: '비상금',
          monthlyBudget: 150000,
          isFixed: true,
          colorValue: 0xFF264653,
          iconCodePoint: Icons.health_and_safety_rounded.codePoint,
        ),
      ],
      transactions: [
        TransactionEntry(
          id: 't1',
          title: '월급',
          amount: 2800000,
          type: TransactionType.income,
          categoryId: 'income',
          date: DateTime(now.year, now.month, 25),
          sourceName: '회사 급여계좌',
          isAutoSynced: true,
          providerId: 'salary',
          externalId: 'salary-${now.month}',
        ),
        TransactionEntry(
          id: 't2',
          title: '월세 이체',
          amount: 650000,
          type: TransactionType.expense,
          categoryId: 'rent',
          date: DateTime(now.year, now.month, 1),
          sourceName: '토스뱅크',
          isAutoSynced: true,
          providerId: 'toss_bank',
          externalId: 'rent-${now.month}',
        ),
        TransactionEntry(
          id: 't3',
          title: '여행저축 자동이체',
          amount: 180000,
          type: TransactionType.transfer,
          categoryId: 'travel',
          date: DateTime(now.year, now.month, 3),
          sourceName: '신한은행',
          isAutoSynced: true,
          providerId: 'shinhan_bank',
          externalId: 'travel-${now.month}',
        ),
        TransactionEntry(
          id: 't4',
          title: '비상금 적립',
          amount: 150000,
          type: TransactionType.transfer,
          categoryId: 'emergency',
          date: DateTime(now.year, now.month, 3),
          sourceName: '카카오뱅크',
          isAutoSynced: true,
          providerId: 'kakao_bank',
          externalId: 'emergency-${now.month}',
        ),
        TransactionEntry(
          id: 't5',
          title: '장보기',
          amount: 128000,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(now.year, now.month, now.day),
          sourceName: '현대카드',
          isAutoSynced: true,
          providerId: 'hyundai_card',
          externalId: 'grocery-${now.day}',
        ),
        TransactionEntry(
          id: 't6',
          title: '점심 외식',
          amount: 16000,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(now.year, now.month, now.day - 1),
          sourceName: '삼성페이',
          isAutoSynced: true,
          providerId: 'samsung_pay',
          externalId: 'lunch-${now.day - 1}',
        ),
        TransactionEntry(
          id: 't7',
          title: '생활용품 구매',
          amount: 89000,
          type: TransactionType.expense,
          categoryId: 'living',
          date: DateTime(now.year, now.month, now.day - 2),
          sourceName: '쿠팡',
          isAutoSynced: false,
        ),
        TransactionEntry(
          id: 't8',
          title: '커피',
          amount: 5900,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(now.year, now.month, now.day),
          sourceName: '스타벅스 앱',
          isAutoSynced: true,
          providerId: 'starbucks',
          externalId: 'coffee-${now.day}',
        ),
        TransactionEntry(
          id: 'pm1',
          title: '월급',
          amount: 2750000,
          type: TransactionType.income,
          categoryId: 'income',
          date: DateTime(previousMonth.year, previousMonth.month, 25),
          sourceName: '회사 급여계좌',
          isAutoSynced: true,
          providerId: 'salary',
          externalId: 'salary-prev-${previousMonth.month}',
        ),
        TransactionEntry(
          id: 'pm2',
          title: '월세 이체',
          amount: 650000,
          type: TransactionType.expense,
          categoryId: 'rent',
          date: DateTime(previousMonth.year, previousMonth.month, 1),
          sourceName: '토스뱅크',
          isAutoSynced: true,
          providerId: 'toss_bank',
          externalId: 'rent-prev-${previousMonth.month}',
        ),
        TransactionEntry(
          id: 'pm3',
          title: '외식 모임',
          amount: 74000,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(previousMonth.year, previousMonth.month, 18),
          sourceName: '현대카드',
          isAutoSynced: true,
          providerId: 'hyundai_card',
          externalId: 'food-prev-${previousMonth.month}',
        ),
        TransactionEntry(
          id: 'pm4',
          title: '생활용품 정기구매',
          amount: 98000,
          type: TransactionType.expense,
          categoryId: 'living',
          date: DateTime(previousMonth.year, previousMonth.month, 7),
          sourceName: '쿠팡',
          isAutoSynced: false,
        ),
        TransactionEntry(
          id: 'pm5',
          title: '여행저축 자동이체',
          amount: 180000,
          type: TransactionType.transfer,
          categoryId: 'travel',
          date: DateTime(previousMonth.year, previousMonth.month, 3),
          sourceName: '신한은행',
          isAutoSynced: true,
          providerId: 'shinhan_bank',
          externalId: 'travel-prev-${previousMonth.month}',
        ),
        TransactionEntry(
          id: 'tm1',
          title: '월급',
          amount: 2680000,
          type: TransactionType.income,
          categoryId: 'income',
          date: DateTime(twoMonthsAgo.year, twoMonthsAgo.month, 25),
          sourceName: '회사 급여계좌',
          isAutoSynced: true,
          providerId: 'salary',
          externalId: 'salary-two-${twoMonthsAgo.month}',
        ),
        TransactionEntry(
          id: 'tm2',
          title: '월세 이체',
          amount: 650000,
          type: TransactionType.expense,
          categoryId: 'rent',
          date: DateTime(twoMonthsAgo.year, twoMonthsAgo.month, 1),
          sourceName: '토스뱅크',
          isAutoSynced: true,
          providerId: 'toss_bank',
          externalId: 'rent-two-${twoMonthsAgo.month}',
        ),
        TransactionEntry(
          id: 'tm3',
          title: '장보기',
          amount: 112000,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(twoMonthsAgo.year, twoMonthsAgo.month, 16),
          sourceName: '현대카드',
          isAutoSynced: true,
          providerId: 'hyundai_card',
          externalId: 'food-two-${twoMonthsAgo.month}',
        ),
        TransactionEntry(
          id: 'tm4',
          title: '생활비 이체',
          amount: 87000,
          type: TransactionType.expense,
          categoryId: 'living',
          date: DateTime(twoMonthsAgo.year, twoMonthsAgo.month, 10),
          sourceName: '신한은행',
          isAutoSynced: true,
          providerId: 'shinhan_bank',
          externalId: 'living-two-${twoMonthsAgo.month}',
        ),
        TransactionEntry(
          id: 'tm5',
          title: '비상금 적립',
          amount: 150000,
          type: TransactionType.transfer,
          categoryId: 'emergency',
          date: DateTime(twoMonthsAgo.year, twoMonthsAgo.month, 3),
          sourceName: '카카오뱅크',
          isAutoSynced: true,
          providerId: 'kakao_bank',
          externalId: 'emergency-two-${twoMonthsAgo.month}',
        ),
      ],
      accounts: const [
        LinkedAccount(
          id: 'a1',
          name: '토스뱅크 자유적금',
          kind: AccountKind.bank,
          principal: 2200000,
          currentBalance: 2264000,
          isLinked: true,
          providerId: 'toss_bank',
        ),
        LinkedAccount(
          id: 'a2',
          name: '미래에셋 ISA',
          kind: AccountKind.securities,
          principal: 1800000,
          currentBalance: 1935000,
          isLinked: true,
          providerId: 'mirae_asset',
        ),
        LinkedAccount(
          id: 'a3',
          name: '여행저축 통장',
          kind: AccountKind.bank,
          principal: 920000,
          currentBalance: 920000,
          isLinked: true,
          providerId: 'shinhan_bank',
        ),
      ],
      goals: const [
        SavingsGoal(
          id: 'g1',
          title: '비상금 300만원',
          targetAmount: 3000000,
          currentAmount: 1280000,
        ),
        SavingsGoal(
          id: 'g2',
          title: '여행저축 200만원',
          targetAmount: 2000000,
          currentAmount: 920000,
        ),
      ],
      syncProviders: [
        SyncProvider(
          id: 'toss_bank',
          name: '토스뱅크',
          type: SyncProviderType.bank,
          isConnected: true,
          hasPermission: true,
          authStatus: SyncAuthStatus.connected,
          statusMessage: '계좌 잔액과 거래내역 동기화 준비 완료',
          lastAuthorizedAt: DateTime(2026, 3, 25, 9, 30),
        ),
        SyncProvider(
          id: 'hyundai_card',
          name: '현대카드',
          type: SyncProviderType.card,
          isConnected: true,
          hasPermission: true,
          authStatus: SyncAuthStatus.connected,
          statusMessage: '카드 승인내역 자동 연동 중',
          lastAuthorizedAt: DateTime(2026, 3, 24, 21, 10),
        ),
        SyncProvider(
          id: 'mirae_asset',
          name: '미래에셋',
          type: SyncProviderType.investment,
          isConnected: true,
          hasPermission: true,
          authStatus: SyncAuthStatus.connected,
          statusMessage: '투자 평가금액 조회 권한 승인 완료',
          lastAuthorizedAt: DateTime(2026, 3, 22, 8, 45),
        ),
      ],
      settings: const AppSettings(
        autoSyncEnabled: true,
        savingsTipsEnabled: true,
        challengeReminderEnabled: true,
        challengeDailyTarget: 10000,
      ),
    );
  }

  static DashboardSnapshot buildSnapshot({
    required DateTime now,
    required List<BudgetCategory> categories,
    required List<TransactionEntry> transactions,
    required List<LinkedAccount> accounts,
    required List<SavingsGoal> goals,
    required List<SyncProvider> syncProviders,
    required AppSettings settings,
  }) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day + 1;
    final monthlyTransactions = transactions
        .where(
          (entry) =>
              entry.date.year == now.year && entry.date.month == now.month,
        )
        .toList();
    final allTransactions = [...transactions]
      ..sort((a, b) => a.date.compareTo(b.date));

    final challenge = SpendingChallenge(
      title: '하루 ${settings.challengeDailyTarget ~/ 10000}만원만 쓰기',
      dailyTarget: settings.challengeDailyTarget,
      todaySpent: monthlyTransactions
          .where(
            (entry) =>
                entry.type == TransactionType.expense &&
                entry.date.day == now.day,
          )
          .fold(0, (sum, entry) => sum + entry.amount),
    );

    final categoryStatuses = categories.map((category) {
      final spent = monthlyTransactions
          .where(
            (entry) =>
                entry.categoryId == category.id &&
                entry.type == TransactionType.expense,
          )
          .fold(0, (sum, entry) => sum + entry.amount);
      final remaining = category.monthlyBudget - spent;
      final dailyAllowance = daysRemaining > 0
          ? (remaining / daysRemaining).floor()
          : remaining;

      return CategoryBudgetStatus(
        category: category,
        spent: spent,
        remaining: remaining,
        dailyAllowance: dailyAllowance,
      );
    }).toList();

    final monthlyIncome = monthlyTransactions
        .where((entry) => entry.type == TransactionType.income)
        .fold(0, (sum, entry) => sum + entry.amount);

    final monthlyExpense = monthlyTransactions
        .where((entry) => entry.type == TransactionType.expense)
        .fold(0, (sum, entry) => sum + entry.amount);
    final lastMonthDate = DateTime(now.year, now.month - 1, 1);
    final lastMonthExpense = transactions
        .where(
          (entry) =>
              entry.type == TransactionType.expense &&
              entry.date.year == lastMonthDate.year &&
              entry.date.month == lastMonthDate.month,
        )
        .fold(0, (sum, entry) => sum + entry.amount);
    final autoSyncedExpense = monthlyTransactions
        .where(
          (entry) =>
              entry.type == TransactionType.expense && entry.isAutoSynced,
        )
        .fold(0, (sum, entry) => sum + entry.amount);
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final previousWeekStart = weekStart.subtract(const Duration(days: 7));
    final previousWeekEnd = weekStart.subtract(const Duration(days: 1));
    final weeklyExpense = transactions
        .where(
          (entry) =>
              entry.type == TransactionType.expense &&
              !entry.date.isBefore(
                DateTime(weekStart.year, weekStart.month, weekStart.day),
              ) &&
              !entry.date.isAfter(now),
        )
        .fold(0, (sum, entry) => sum + entry.amount);
    final previousWeeklyExpense = transactions
        .where(
          (entry) =>
              entry.type == TransactionType.expense &&
              !entry.date.isBefore(
                DateTime(
                  previousWeekStart.year,
                  previousWeekStart.month,
                  previousWeekStart.day,
                ),
              ) &&
              !entry.date.isAfter(
                DateTime(
                  previousWeekEnd.year,
                  previousWeekEnd.month,
                  previousWeekEnd.day,
                  23,
                  59,
                  59,
                ),
              ),
        )
        .fold(0, (sum, entry) => sum + entry.amount);

    final totalSaved = goals.fold(0, (sum, goal) => sum + goal.currentAmount);
    final investedAccounts = accounts.where(
      (account) => account.kind == AccountKind.securities,
    );
    final totalInvestedPrincipal = investedAccounts.fold(
      0,
      (sum, account) => sum + account.principal,
    );
    final totalInvestedValue = investedAccounts.fold(
      0,
      (sum, account) => sum + account.currentBalance,
    );

    final todayAllowance = categoryStatuses
        .where((status) => !status.category.isFixed)
        .fold(0, (sum, status) => sum + status.dailyAllowance);

    final monthlyTrend = _buildMonthlyTrend(
      now: now,
      transactions: allTransactions,
    );
    final categoryTrends = _buildCategoryTrends(
      now: now,
      transactions: allTransactions,
      categories: categories,
    );
    final priorityInsights = _buildPriorityInsights(
      categories: categoryStatuses,
      weeklyExpense: weeklyExpense,
      previousWeeklyExpense: previousWeeklyExpense,
      monthlyExpense: monthlyExpense,
      lastMonthExpense: lastMonthExpense,
    );

    return DashboardSnapshot(
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      totalSaved: totalSaved,
      totalInvestedPrincipal: totalInvestedPrincipal,
      totalInvestedValue: totalInvestedValue,
      todayAllowance: todayAllowance,
      categories: categoryStatuses,
      transactions: monthlyTransactions
        ..sort((a, b) => b.date.compareTo(a.date)),
      accounts: accounts,
      goals: goals,
      challenge: challenge,
      insights: _buildInsights(
        categories: categoryStatuses,
        challenge: challenge,
        totalInvestmentProfit: totalInvestedValue - totalInvestedPrincipal,
        settings: settings,
      ),
      syncProviders: syncProviders,
      settings: settings,
      monthlyTrend: monthlyTrend,
      categoryTrends: categoryTrends,
      autoSyncedExpense: autoSyncedExpense,
      weeklyExpense: weeklyExpense,
      previousWeeklyExpense: previousWeeklyExpense,
      lastMonthExpense: lastMonthExpense,
      priorityInsights: priorityInsights,
    );
  }

  static List<MonthlySpendingSummary> _buildMonthlyTrend({
    required DateTime now,
    required List<TransactionEntry> transactions,
  }) {
    final months = List.generate(3, (index) {
      final date = DateTime(now.year, now.month - (2 - index), 1);
      final monthTransactions = transactions
          .where(
            (entry) =>
                entry.date.year == date.year && entry.date.month == date.month,
          )
          .toList();
      final income = monthTransactions
          .where((entry) => entry.type == TransactionType.income)
          .fold(0, (sum, entry) => sum + entry.amount);
      final expense = monthTransactions
          .where((entry) => entry.type == TransactionType.expense)
          .fold(0, (sum, entry) => sum + entry.amount);
      final transfer = monthTransactions
          .where((entry) => entry.type == TransactionType.transfer)
          .fold(0, (sum, entry) => sum + entry.amount);
      return MonthlySpendingSummary(
        year: date.year,
        month: date.month,
        income: income,
        expense: expense,
        transfer: transfer,
      );
    });

    return months;
  }

  static List<CategoryTrendPoint> _buildCategoryTrends({
    required DateTime now,
    required List<TransactionEntry> transactions,
    required List<BudgetCategory> categories,
  }) {
    final variableCategories = categories
        .where((category) => !category.isFixed)
        .toList();
    final output = <CategoryTrendPoint>[];

    for (final monthOffset in [2, 1, 0]) {
      final date = DateTime(now.year, now.month - monthOffset, 1);
      for (final category in variableCategories) {
        final amount = transactions
            .where(
              (entry) =>
                  entry.date.year == date.year &&
                  entry.date.month == date.month &&
                  entry.categoryId == category.id &&
                  entry.type == TransactionType.expense,
            )
            .fold(0, (sum, entry) => sum + entry.amount);
        output.add(
          CategoryTrendPoint(
            label: '${date.month}월',
            categoryId: category.id,
            categoryName: category.name,
            amount: amount,
            colorValue: category.colorValue,
          ),
        );
      }
    }

    return output;
  }

  static List<String> _buildPriorityInsights({
    required List<CategoryBudgetStatus> categories,
    required int weeklyExpense,
    required int previousWeeklyExpense,
    required int monthlyExpense,
    required int lastMonthExpense,
  }) {
    final messages = <String>[];
    final sorted = [...categories]
      ..sort((a, b) => b.progress.compareTo(a.progress));

    if (sorted.isNotEmpty) {
      final top = sorted.first;
      messages.add(
        '1순위: ${top.category.name}를 먼저 줄여보세요. 이번 달 ${top.spent}원 사용으로 예산 사용률이 가장 높아요.',
      );
    }

    if (weeklyExpense > previousWeeklyExpense) {
      messages.add(
        '2순위: 이번 주 지출이 지난주보다 ${weeklyExpense - previousWeeklyExpense}원 늘었어요. 주말 외식/배달부터 점검해보세요.',
      );
    }

    if (monthlyExpense > lastMonthExpense) {
      messages.add(
        '3순위: 이번 달 총지출이 지난달보다 ${monthlyExpense - lastMonthExpense}원 증가했어요. 늘어난 항목 위주로 예산을 재조정해보세요.',
      );
    }

    return messages.take(3).toList();
  }

  static List<String> _buildInsights({
    required List<CategoryBudgetStatus> categories,
    required SpendingChallenge challenge,
    required int totalInvestmentProfit,
    required AppSettings settings,
  }) {
    final insights = <String>[];

    final overBudget = categories.where((status) => status.isOverBudget);
    for (final status in overBudget) {
      insights.add(
        '${status.category.name}가 ${status.remaining.abs()}원 초과됐어요. 이번 주는 해당 카테고리 지출을 줄여야 해요.',
      );
    }

    final warning = categories.where((status) => status.isWarning);
    for (final status in warning) {
      insights.add(
        '${status.category.name} 예산을 ${status.spent}원 사용했어요. 남은 일수 기준 하루 ${status.dailyAllowance > 0 ? status.dailyAllowance : 0}원 이내로 맞춰보세요.',
      );
    }

    if (!challenge.isSuccessful) {
      insights.add('오늘 챌린지 목표를 초과했어요. 내일은 커피나 배달 중 한 항목만 줄여도 회복할 수 있어요.');
    }

    if (totalInvestmentProfit > 0) {
      insights.add('투자 수익이 플러스예요. 이번 달 남은 예산 일부를 저축 목표로 재배치해보세요.');
    }

    if (!settings.autoSyncEnabled) {
      insights.add('자동 연동이 꺼져 있어요. 거래 누락을 막으려면 동기화를 다시 켜두는 편이 좋아요.');
    }

    if (insights.isEmpty) {
      insights.add('예산 흐름이 안정적이에요. 남은 예산은 비상금과 여행저축으로 나눠 적립해보세요.');
    }

    return insights;
  }
}
