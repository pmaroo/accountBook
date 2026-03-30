import '../models/finance_models.dart';

class NotificationMessage {
  const NotificationMessage({
    required this.title,
    required this.body,
    required this.severity,
  });

  final String title;
  final String body;
  final NotificationSeverity severity;
}

enum NotificationSeverity { info, warning, critical }

class NotificationService {
  List<NotificationMessage> buildMessages(DashboardSnapshot snapshot) {
    final messages = <NotificationMessage>[];

    if (snapshot.settings.challengeReminderEnabled &&
        !snapshot.challenge.isSuccessful) {
      messages.add(
        NotificationMessage(
          title: '챌린지 초과',
          body:
              '오늘 ${snapshot.challenge.todaySpent - snapshot.challenge.dailyTarget}원 초과했어요. 남은 오늘 지출을 잠시 멈춰보세요.',
          severity: NotificationSeverity.critical,
        ),
      );
    }

    for (final status in snapshot.categories) {
      if (status.isOverBudget) {
        messages.add(
          NotificationMessage(
            title: '${status.category.name} 예산 초과',
            body: '${status.remaining.abs()}원 초과되었습니다. 다음 소비 전 조정이 필요해요.',
            severity: NotificationSeverity.critical,
          ),
        );
      } else if (status.isWarning) {
        messages.add(
          NotificationMessage(
            title: '${status.category.name} 예산 80% 도달',
            body:
                '남은 기간 하루 ${status.dailyAllowance > 0 ? status.dailyAllowance : 0}원 수준으로 관리해보세요.',
            severity: NotificationSeverity.warning,
          ),
        );
      }
    }

    if (snapshot.settings.autoSyncEnabled && snapshot.autoSyncRate < 50) {
      messages.add(
        const NotificationMessage(
          title: '자동 연동 비율 낮음',
          body: '수동 입력 비율이 높아요. 연결 앱 권한과 동기화 상태를 점검해보세요.',
          severity: NotificationSeverity.info,
        ),
      );
    }

    return messages;
  }
}
