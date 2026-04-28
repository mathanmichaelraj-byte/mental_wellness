import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mental_wellness/services/firebase/auth_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../core/constants/app_constants.dart';

class AffirmationService {
  static final AffirmationService instance = AffirmationService._init();
  AffirmationService._init();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Random _random = Random();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      AppConstants.affirmationChannelId,
      AppConstants.affirmationChannelName,
      description: AppConstants.affirmationChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> scheduleDailyAffirmation({int? hour, int? minute}) async {
    final userData = await AuthService.instance.getUserData();
    
    if (userData == null || userData['affirmationsEnabled'] != true) {
      await cancelAffirmations();
      return;
    }

    final affirmationTime = userData['affirmationTime'] as Map<String, dynamic>?;
    final scheduleHour = hour ?? affirmationTime?['hour'] ?? AppConstants.defaultAffirmationHour;
    final scheduleMinute = minute ?? affirmationTime?['minute'] ?? AppConstants.defaultAffirmationMinute;

    await cancelAffirmations();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduleHour,
      scheduleMinute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      AppConstants.affirmationNotificationId,
      'Daily Affirmation 💙',
      _getRandomAffirmation(),
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.affirmationChannelId,
          AppConstants.affirmationChannelName,
          channelDescription: AppConstants.affirmationChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> sendTestAffirmation() async {
    await _notifications.show(
      999,
      'Daily Affirmation 💙',
      _getRandomAffirmation(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.affirmationChannelId,
          AppConstants.affirmationChannelName,
          channelDescription: AppConstants.affirmationChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelAffirmations() async {
    await _notifications.cancel(AppConstants.affirmationNotificationId);
  }

  String _getRandomAffirmation() {
    return AppConstants.dailyAffirmations[
      _random.nextInt(AppConstants.dailyAffirmations.length)
    ];
  }

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    final androidGranted = await android?.requestNotificationsPermission() ?? true;
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    ) ?? true;

    return androidGranted && iosGranted;
  }
}
