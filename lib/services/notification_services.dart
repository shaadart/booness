import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

// Global variable to store the scheduled notification ID
int? scheduledNotificationId;


// Function to create or update daily notification
Future<void> createDailyNotification(BuildContext context) async {
  try {
    // Cancel any existing notification before scheduling a new one
    if (scheduledNotificationId != null) {
      AwesomeNotifications().cancel(scheduledNotificationId!);
      scheduledNotificationId = null;
    }




    // Show time picker to select notification time with 24-hour format
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
      // Generate a unique notification id for each notification
      scheduledNotificationId = DateTime.now().millisecondsSinceEpoch & 0x3FFFFFFF;

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
          preciseAlarm: true,
          allowWhileIdle: true,
          hour: selectedTime.hour,
          minute: selectedTime.minute,
          second: 0,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'write',
            label: 'Write',
          ),
        ],
      );

      // Print confirmation message after notification is scheduled
      print(
          "Daily Reminder Notification set for ${selectedTime.format(context)}");
    }
  } catch (e) {
    print('Error scheduling notification: $e');
  }
}
