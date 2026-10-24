import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'subscription_reminders',
      'Subscription Reminders',
      channelDescription: 'Reminders for upcoming subscription payments',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
  );

  Future<void> init() async {
    tz.initializeTimeZones();

    // flutter_timezone 5.x returns a TimezoneInfo object; use .identifier for the IANA name
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);

    // Request permissions (Android 12+ / 13+)
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
    >();

    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
  }

  /// Schedule a reminder [daysBefore] days before [billingDate]
  /// at [timeOfDayMinutes] minutes from midnight (e.g. 540 = 9:00 AM).
  Future<void> scheduleSubscriptionReminder({
    required int notificationId,
    required String subscriptionName,
    required DateTime billingDate,
    required int daysBefore,
    required int timeOfDayMinutes,
  }) async {
    final reminderDate = billingDate.subtract(Duration(days: daysBefore));
    final scheduledDateTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      timeOfDayMinutes ~/ 60,
      timeOfDayMinutes % 60,
    );

    // Don't schedule notifications in the past
    if (scheduledDateTime.isBefore(DateTime.now())) return;

    await scheduleAt(
      id: notificationId,
      title: '💳 $subscriptionName renews soon',
      body:
      '$subscriptionName will renew in $daysBefore day${daysBefore == 1 ? '' : 's'}.',
      when: scheduledDateTime,
      payload: scheduledDateTime.toIso8601String(),
    );
  }

  /// Schedule a notification at an exact [when] (seconds are respected).
  /// If exact alarms are not permitted, falls back to an inexact alarm
  /// so the notification still shows (maybe a few minutes late).
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    final scheduledDate = tz.TZDateTime.from(when, tz.local);

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      } else {
        rethrow;
      }
    }
  }

  /// Show a notification immediately (useful to test permission/channel).
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details,
    );
  }

  /// Abhi kaun kaun si notifications schedule hain (debug list ke liye).
  Future<List<PendingNotificationRequest>> getPending() {
    return _plugin.pendingNotificationRequests();
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}