import 'notification_service.dart';

abstract class LocalAlertServiceBase {
  Future<void> initialize();

  Future<bool> sendMessages(List<NotificationMessage> messages);
}
