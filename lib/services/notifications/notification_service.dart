import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Low-level notification helper — initialises the plugin and exposes
/// convenience methods for instant and repeating notifications.
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  Future<void> showInstantNotification(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'mental_wellness_channel', 'Mental Wellness',
        channelDescription: 'Notifications for mental wellness reminders',
        importance: Importance.high, priority: Priority.high,
      ),
    );
    await _plugin.show(0, title, body, details);
  }

  Future<void> scheduleDailyReminder() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder_channel', 'Daily Reminders',
        channelDescription: 'Daily mood check reminders',
      ),
    );
    await _plugin.periodicallyShow(
      1, 'Mental Wellness Check',
      'How are you feeling today? Take a moment for yourself',
      RepeatInterval.daily, details,
    );
  }

  Future<void> cancelAllNotifications() => _plugin.cancelAll();
}
