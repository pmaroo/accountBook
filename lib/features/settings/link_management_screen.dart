import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/finance_models.dart';

class LinkManagementScreen extends StatelessWidget {
  const LinkManagementScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final providers = controller.syncProviders;

        return Scaffold(
          appBar: AppBar(title: const Text('연동 인증 관리')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(
                '은행/카드/투자 앱 인증 상태를 한 곳에서 관리하세요.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 18),
              for (final provider in providers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ProviderCard(
                    provider: provider,
                    onManage: () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return _AuthorizationSheet(
                            controller: controller,
                            provider: provider,
                          );
                        },
                      );
                    },
                    onSync: provider.isReadyToSync
                        ? () => controller.syncProvider(provider.id)
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.onManage,
    required this.onSync,
  });

  final SyncProvider provider;
  final VoidCallback onManage;
  final VoidCallback? onSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _statusMeta(provider.authStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: status.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status.label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: status.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: onManage,
                  child: const Text('인증 관리'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(provider.statusMessage ?? '아직 인증 이력이 없습니다.'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoChip(
                  icon: provider.isConnected
                      ? Icons.link_rounded
                      : Icons.link_off_rounded,
                  label: provider.isConnected ? '앱 연결됨' : '앱 연결 안 됨',
                ),
                _InfoChip(
                  icon: provider.hasPermission
                      ? Icons.verified_user_rounded
                      : Icons.rule_folder_outlined,
                  label: provider.hasPermission ? '권한 승인됨' : '권한 미승인',
                ),
                _InfoChip(
                  icon: Icons.schedule_rounded,
                  label: provider.lastAuthorizedAt == null
                      ? '인증 기록 없음'
                      : '최근 인증 ${Formatters.monthDay(provider.lastAuthorizedAt!)}',
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onSync,
                child: const Text('지금 동기화'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorizationSheet extends StatefulWidget {
  const _AuthorizationSheet({required this.controller, required this.provider});

  final AppController controller;
  final SyncProvider provider;

  @override
  State<_AuthorizationSheet> createState() => _AuthorizationSheetState();
}

class _AuthorizationSheetState extends State<_AuthorizationSheet> {
  late final TextEditingController _customerCodeController;
  late bool _grantTransactions;
  late bool _grantBalance;
  late bool _grantInvestments;

  @override
  void initState() {
    super.initState();
    _customerCodeController = TextEditingController();
    _grantTransactions = widget.provider.hasPermission;
    _grantBalance = widget.provider.hasPermission;
    _grantInvestments =
        widget.provider.type == SyncProviderType.investment &&
        widget.provider.hasPermission;
  }

  @override
  void dispose() {
    _customerCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.controller.syncProviders.firstWhere(
      (item) => item.id == widget.provider.id,
      orElse: () => widget.provider,
    );
    final status = _statusMeta(provider.authStatus);

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
            '${provider.name} 인증 플로우',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.statusMessage ?? '실제 API를 붙이기 전 단계의 인증 흐름입니다.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(status.icon, color: status.color),
              const SizedBox(width: 8),
              Text(
                status.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customerCodeController,
            decoration: const InputDecoration(
              labelText: '회원 식별코드 또는 마지막 4자리',
              hintText: '예: 4821',
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _grantTransactions,
            onChanged: (value) {
              setState(() {
                _grantTransactions = value ?? false;
              });
            },
            title: const Text('거래내역 접근 허용'),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _grantBalance,
            onChanged: (value) {
              setState(() {
                _grantBalance = value ?? false;
              });
            },
            title: Text(
              provider.type == SyncProviderType.investment
                  ? '평가금액 접근 허용'
                  : '잔액 접근 허용',
            ),
          ),
          if (provider.type == SyncProviderType.investment)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _grantInvestments,
              onChanged: (value) {
                setState(() {
                  _grantInvestments = value ?? false;
                });
              },
              title: const Text('보유 종목/수익률 접근 허용'),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: () async {
                  if (_customerCodeController.text.trim().isEmpty) {
                    await widget.controller.markProviderAuthorizationError(
                      provider.id,
                      '회원 식별코드가 비어 있어 인증을 시작할 수 없습니다.',
                    );
                    return;
                  }
                  await widget.controller.startProviderAuthorization(
                    provider.id,
                  );
                },
                child: const Text('1. 인증 요청'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  widget.controller.completeProviderAuthorization(
                    provider.id,
                    grantTransactions: _grantTransactions,
                    grantBalance: _grantBalance,
                    grantInvestments: _grantInvestments,
                  );
                },
                child: const Text('2. 권한 승인 반영'),
              ),
              OutlinedButton(
                onPressed: () {
                  widget.controller.toggleProviderConnection(
                    provider.id,
                    false,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('연결 해제'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4B5563)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _StatusMeta {
  const _StatusMeta({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

_StatusMeta _statusMeta(SyncAuthStatus status) {
  return switch (status) {
    SyncAuthStatus.disconnected => const _StatusMeta(
      label: '연결 안 됨',
      color: Color(0xFF6B7280),
      icon: Icons.link_off_rounded,
    ),
    SyncAuthStatus.authorizationRequired => const _StatusMeta(
      label: '인증 필요',
      color: Color(0xFF2563EB),
      icon: Icons.shield_outlined,
    ),
    SyncAuthStatus.pendingConsent => const _StatusMeta(
      label: '본인 확인 대기',
      color: Color(0xFFE67E22),
      icon: Icons.hourglass_top_rounded,
    ),
    SyncAuthStatus.permissionRequired => const _StatusMeta(
      label: '권한 승인 필요',
      color: Color(0xFFD97706),
      icon: Icons.fact_check_outlined,
    ),
    SyncAuthStatus.connected => const _StatusMeta(
      label: '연동 완료',
      color: Color(0xFF0F9D58),
      icon: Icons.verified_rounded,
    ),
    SyncAuthStatus.error => const _StatusMeta(
      label: '오류',
      color: Color(0xFFDC2626),
      icon: Icons.error_outline_rounded,
    ),
  };
}
