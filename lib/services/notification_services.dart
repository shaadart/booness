import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'local_database_service.dart'; // Import the DatabaseHelper

int? scheduledNotificationId;

Future<void> createDailyNotification(BuildContext context) async {
  try {
    if (scheduledNotificationId != null) {
      await AwesomeNotifications().cancel(scheduledNotificationId!);
      scheduledNotificationId = null;
    }

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      await AwesomeNotifications().cancelAll();
      await DatabaseHelper()
          .saveNotificationTime(selectedTime.hour, selectedTime.minute);

      scheduledNotificationId =
          DateTime.now().millisecondsSinceEpoch & 0x3FFFFFFF;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: scheduledNotificationId!,
          channelKey: 'daily_reminders',
          title: 'Daily Reminder',
          body: 'Tap to write your daily diary',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar(
          repeats: true,
          preciseAlarm: false,
          allowWhileIdle: true,
          hour: selectedTime.hour,
          minute: selectedTime.minute,
          second: 1,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'write',
            label: 'Write',
          ),
        ],
      );

      print(
          "Daily Reminder Notification set for ${selectedTime.format(context)}");
    }
  } catch (e) {
    print('Error scheduling notification: $e');
  }
}

Future<void> checkAndPrintScheduledNotifications() async {
  try {
    List<NotificationModel> scheduledNotifications =
        await AwesomeNotifications().listScheduledNotifications();
    print(
        "Number of scheduled notifications: ${scheduledNotifications.length}");
  } catch (e) {
    print("Error checking scheduled notifications: $e");
  }
}
