import 'local_alert_service_base.dart';
import 'notification_service.dart';

class LocalAlertService implements LocalAlertServiceBase {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> sendMessages(List<NotificationMessage> messages) async {
    return false;
  }
}
