import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/app_controller.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/finance_models.dart';
import '../../data/services/notification_service.dart';
import 'link_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.snapshot,
    required this.controller,
  });

  final DashboardSnapshot snapshot;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifications = controller.notificationMessages;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(
            '설정',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '자동 연동, 알림, 카테고리 기준을 한 곳에서 관리하세요.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          Text(
            '알림 미리보기',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (notifications.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('현재 표시할 알림이 없습니다.'),
              ),
            ),
          for (final notification in notifications)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    switch (notification.severity) {
                      NotificationSeverity.info =>
                        Icons.notifications_none_rounded,
                      NotificationSeverity.warning =>
                        Icons.notification_important_outlined,
                      NotificationSeverity.critical =>
                        Icons.warning_amber_rounded,
                    },
                    color: switch (notification.severity) {
                      NotificationSeverity.info => const Color(0xFF2563EB),
                      NotificationSeverity.warning => const Color(0xFFE67E22),
                      NotificationSeverity.critical => Colors.red,
                    },
                  ),
                  title: Text(notification.title),
                  subtitle: Text(notification.body),
                ),
              ),
            ),
          const SizedBox(height: 10),
          FilledButton.tonal(
            onPressed: () async {
              final sent = await controller.sendLocalNotifications();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      sent ? '로컬 알림을 발송했습니다.' : '발송할 알림이 없거나 이 환경은 지원하지 않습니다.',
                    ),
                  ),
                );
              }
            },
            child: const Text('현재 알림 발송 테스트'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonal(
                onPressed: () async {
                  final result = await controller.exportBackup();
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
                child: const Text('백업 생성'),
              ),
              FilledButton.tonal(
                onPressed: () async {
                  final result = await controller.restoreSelectedBackup();
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
                child: const Text('백업 파일 선택'),
              ),
              FilledButton.tonal(
                onPressed: () async {
                  final result = await controller.restoreLatestBackup();
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
                child: const Text('최신 백업 복원'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '카테고리 관리',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () =>
                showCategoryFormSheet(context: context, controller: controller),
            child: const Text('카테고리 추가'),
          ),
          const SizedBox(height: 12),
          for (final status in snapshot.categories)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: status.category.color.withValues(
                      alpha: 0.12,
                    ),
                    child: Icon(
                      status.category.icon,
                      color: status.category.color,
                    ),
                  ),
                  title: Text(status.category.name),
                  subtitle: Text(
                    '${status.category.isFixed ? '고정 항목' : '변동 항목'} · 월 예산 ${Formatters.won(status.category.monthlyBudget)}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await showCategoryFormSheet(
                          context: context,
                          controller: controller,
                          existing: status.category,
                        );
                      }
                      if (value == 'delete') {
                        final success = await controller.deleteCategory(
                          status.category.id,
                        );
                        if (context.mounted && !success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('이미 사용 중인 카테고리는 삭제할 수 없습니다.'),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('수정')),
                      PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          Text(
            '연동 관리',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LinkManagementScreen(controller: controller),
                ),
              );
            },
            child: const Text('연동 인증 관리 열기'),
          ),
          const SizedBox(height: 12),
          for (final provider in snapshot.syncProviders)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.lastSyncedAt == null
                                      ? '아직 동기화 없음'
                                      : '최근 동기화 ${Formatters.monthDay(provider.lastSyncedAt!)} · ${_providerStatusLabel(provider.authStatus)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                                if (provider.statusMessage != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    provider.statusMessage!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: provider.isReadyToSync
                                ? () => controller.syncProvider(provider.id)
                                : null,
                            child: const Text('동기화'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: provider.isConnected,
                        onChanged: (value) {
                          controller.toggleProviderConnection(
                            provider.id,
                            value,
                          );
                        },
                        title: const Text('앱 연결'),
                        subtitle: const Text('연결을 꺼두면 데이터 동기화가 멈춥니다'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: provider.hasPermission,
                        onChanged: provider.isConnected
                            ? (value) {
                                controller.updateProviderPermission(
                                  provider.id,
                                  value,
                                );
                              }
                            : null,
                        title: const Text('정보 접근 허용'),
                        subtitle: const Text('거래내역/잔액/평가금액 조회 권한'),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => LinkManagementScreen(
                                  controller: controller,
                                ),
                              ),
                            );
                          },
                          child: const Text('인증 단계 자세히 보기'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          Text(
            '앱 동작',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: snapshot.settings.autoSyncEnabled,
                  onChanged: (value) {
                    controller.updateSettings(
                      snapshot.settings.copyWith(autoSyncEnabled: value),
                    );
                  },
                  title: const Text('자동 내역 동기화'),
                  subtitle: const Text('연결된 앱에서 거래 내역을 반영합니다'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: snapshot.settings.savingsTipsEnabled,
                  onChanged: (value) {
                    controller.updateSettings(
                      snapshot.settings.copyWith(savingsTipsEnabled: value),
                    );
                  },
                  title: const Text('절약 플랜 추천'),
                  subtitle: const Text('소비 패턴 기반 제안을 표시합니다'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: snapshot.settings.challengeReminderEnabled,
                  onChanged: (value) {
                    controller.updateSettings(
                      snapshot.settings.copyWith(
                        challengeReminderEnabled: value,
                      ),
                    );
                  },
                  title: const Text('챌린지 리마인더'),
                  subtitle: const Text('하루 목표 금액 초과 전에 알려줍니다'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('챌린지 하루 목표 금액'),
                  subtitle: Text(
                    Formatters.won(snapshot.settings.challengeDailyTarget),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      showAmountEditDialog(
                        context: context,
                        title: '하루 챌린지 목표 수정',
                        initialPrimaryAmount:
                            snapshot.settings.challengeDailyTarget,
                        onSave: (primary, _) {
                          return controller.updateSettings(
                            snapshot.settings.copyWith(
                              challengeDailyTarget: primary,
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.edit_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonal(
            onPressed: controller.resetToSeed,
            child: const Text('샘플 데이터로 초기화'),
          ),
        ],
      ),
    );
  }
}

Future<void> showCategoryFormSheet({
  required BuildContext context,
  required AppController controller,
  BudgetCategory? existing,
}) async {
  final nameController = TextEditingController(text: existing?.name ?? '');
  final budgetController = TextEditingController(
    text: existing?.monthlyBudget.toString() ?? '',
  );
  var isFixed = existing?.isFixed ?? false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
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
                  existing == null ? '카테고리 추가' : '카테고리 수정',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '카테고리명'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '월 예산'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isFixed,
                  onChanged: (value) {
                    setModalState(() {
                      isFixed = value;
                    });
                  },
                  title: const Text('고정 항목'),
                  subtitle: const Text('월세/비상금처럼 반복되는 항목'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final budget = int.tryParse(budgetController.text);
                      if (name.isEmpty || budget == null) {
                        return;
                      }

                      if (existing == null) {
                        await controller.addCategory(
                          name: name,
                          monthlyBudget: budget,
                          isFixed: isFixed,
                        );
                      } else {
                        await controller.updateCategory(
                          categoryId: existing.id,
                          name: name,
                          monthlyBudget: budget,
                          isFixed: isFixed,
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

String _providerStatusLabel(SyncAuthStatus status) {
  return switch (status) {
    SyncAuthStatus.disconnected => '연결 안 됨',
    SyncAuthStatus.authorizationRequired => '인증 필요',
    SyncAuthStatus.pendingConsent => '본인 확인 대기',
    SyncAuthStatus.permissionRequired => '권한 필요',
    SyncAuthStatus.connected => '연동 완료',
    SyncAuthStatus.error => '오류',
  };
}
