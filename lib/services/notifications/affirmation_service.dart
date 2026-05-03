import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../core/constants/app_constants.dart';
import '../cloud/auth_service.dart';

/// Schedules and cancels the daily affirmation push notification.
///
/// Notification content is chosen randomly from [AppConstants.generalAffirmations].
/// The schedule time is read from the user's Firestore profile via [AuthService].
///
/// Android 12+ requires the SCHEDULE_EXACT_ALARM permission for exact alarms.
/// This service checks permission at runtime and falls back to an inexact alarm
/// so the app never crashes when the permission is absent or revoked.
class AffirmationService {
  static final AffirmationService instance = AffirmationService._init();
  AffirmationService._init();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Random _rng = Random();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _plugin.initialize(settings);
    await _createChannel();
  }

  Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      AppConstants.affirmationChannelId,
      AppConstants.affirmationChannelName,
      description: AppConstants.affirmationChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ── Permission check ───────────────────────────────────────────────────────

  /// Returns true if the device can schedule exact alarms.
  /// Always returns true on iOS and non-Android platforms.
  Future<bool> _canUseExactAlarms() async {
    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl == null) return true; // iOS / desktop
      final result = await androidImpl.canScheduleExactNotifications();
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  // ── Schedule ───────────────────────────────────────────────────────────────

  Future<void> scheduleDailyAffirmation({int? hour, int? minute}) async {
    try {
      final userData = await AuthService.instance.getUserData();
      if (userData == null || userData['affirmationsEnabled'] != true) {
        await cancelAffirmations();
        return;
      }

      final timeMap = userData['affirmationTime'] as Map<String, dynamic>?;
      final h = hour   ?? timeMap?['hour']   ?? AppConstants.defaultAffirmationHour;
      final m = minute ?? timeMap?['minute'] ?? AppConstants.defaultAffirmationMinute;

      await cancelAffirmations();

      final now       = tz.TZDateTime.now(tz.local);
      var scheduled   = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      const notifDetails = NotificationDetails(
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
      );

      // Prefer exact alarms; fall back to inexact if permission is missing.
      final useExact = await _canUseExactAlarms();
      final scheduleMode = useExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      if (!useExact) {
        debugPrint(
          '[AffirmationService] SCHEDULE_EXACT_ALARM not granted — '
          'falling back to inexact scheduling.',
        );
      }

      await _plugin.zonedSchedule(
        AppConstants.affirmationNotificationId,
        'Daily Affirmation 💙',
        _randomAffirmation(),
        scheduled,
        notifDetails,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } on PlatformException catch (e) {
      // Catch any residual platform errors (e.g. exact_alarm_not_permitted)
      // and log rather than crash — the rest of the app continues normally.
      debugPrint('[AffirmationService] scheduling error: ${e.message}');
    } catch (e) {
      debugPrint('[AffirmationService] unexpected error: $e');
    }
  }

  // ── Test ───────────────────────────────────────────────────────────────────

  Future<void> sendTestAffirmation() async {
    try {
      const details = NotificationDetails(
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
      );
      await _plugin.show(999, 'Daily Affirmation 💙', _randomAffirmation(), details);
    } catch (e) {
      debugPrint('[AffirmationService] sendTestAffirmation error: $e');
    }
  }

  // ── Cancel ─────────────────────────────────────────────────────────────────

  Future<void> cancelAffirmations() async {
    try {
      await _plugin.cancel(AppConstants.affirmationNotificationId);
    } catch (e) {
      debugPrint('[AffirmationService] cancelAffirmations error: $e');
    }
  }

  // ── Permissions ────────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final a = await android?.requestNotificationsPermission() ?? true;
      final i = await ios?.requestPermissions(
            alert: true, badge: true, sound: true) ?? true;
      return a && i;
    } catch (e) {
      debugPrint('[AffirmationService] requestPermissions error: $e');
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _randomAffirmation() => AppConstants
      .generalAffirmations[_rng.nextInt(AppConstants.generalAffirmations.length)];
}
