import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/task_model.dart';

class DeadlineHandler {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultAction: 'Open app');

    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios, linux: linux),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    tz.initializeTimeZones();
  }

  static Future<void> schedule(Task task) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime.from(task.dueDate, tz.local);

    if (scheduled.isBefore(now)) {
      debugPrint(
          'DeadlineHandler: past due date, not scheduling notifications.');
      return;
    }

    final android = AndroidNotificationDetails(
      'goingtodoit_deadlines',
      'Deadlines',
      channelDescription: 'Task deadline notifications',
      importance: task.isFullForce ? Importance.max : Importance.high,
      priority: task.isFullForce ? Priority.max : Priority.high,
    );

    const ios = DarwinNotificationDetails(
      presentSound: true,
      presentBadge: true,
      presentAlert: true,
    );

    const details = NotificationDetails(android: android, iOS: ios);

    await _notifications.zonedSchedule(
      task.id.hashCode,
      task.title,
      task.isFullForce
          ? '⏰ Full Force: tap to launch'
          : '📋 Task due now',
      scheduled,
      details,
      payload: task.id,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('DeadlineHandler: scheduled "${task.title}" at $scheduled');
  }

  static Future<void> cancel(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }

  static void _onNotificationTap(NotificationResponse response) {
    final taskId = response.payload;
    debugPrint('DeadlineHandler: notification tapped, payload=$taskId');
  }
}
