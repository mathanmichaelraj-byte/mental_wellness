import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(initSettings);
  }

  Future<void> showInstantNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'mental_wellness_channel',
      'Mental Wellness',
      channelDescription: 'Notifications for mental wellness reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(0, title, body, details);
  }

  Future<void> scheduleDailyReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily mood check reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _notifications.periodicallyShow(
      1,
      'Mental Wellness Check',
      'How are you feeling today? Take a moment for yourself',
      RepeatInterval.daily,
      details,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
