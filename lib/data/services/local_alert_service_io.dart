import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'local_alert_service_base.dart';
import 'notification_service.dart';

class LocalAlertService implements LocalAlertServiceBase {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _initialized = true;
  }

  @override
  Future<bool> sendMessages(List<NotificationMessage> messages) async {
    await initialize();
    if (messages.isEmpty) {
      return false;
    }

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      await _plugin.show(
        i,
        message.title,
        message.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'money_book_alerts',
            'Money Book Alerts',
            importance: switch (message.severity) {
              NotificationSeverity.info => Importance.defaultImportance,
              NotificationSeverity.warning => Importance.high,
              NotificationSeverity.critical => Importance.max,
            },
            priority: switch (message.severity) {
              NotificationSeverity.info => Priority.defaultPriority,
              NotificationSeverity.warning => Priority.high,
              NotificationSeverity.critical => Priority.max,
            },
          ),
          iOS: const DarwinNotificationDetails(),
          macOS: const DarwinNotificationDetails(),
        ),
      );
    }

    return true;
  }
}
