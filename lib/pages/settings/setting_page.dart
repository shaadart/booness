import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:booness/pages/settings/Settings/account_and_privacy.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/local_database_service.dart';
import '../../services/notification_services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? savedNotificationTime;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSavedNotificationTime();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> _loadSavedNotificationTime() async {
    final notificationTime = await dbHelper.getNotificationTime();
    if (notificationTime != null) {
      setState(() {
        int hour = notificationTime['hour'];
        int minute = notificationTime['minute'];
        savedNotificationTime =
            TimeOfDay(hour: hour, minute: minute).format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Settings', style: GoogleFonts.silkscreen()),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(PhosphorIcons.key),
            title: const Text('Account and Privacy'),
            subtitle: const Text('Privacy and Security'),
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  curve: Curves.fastEaseInToSlowEaseOut,
                  duration: const Duration(milliseconds: 200),
                  type: PageTransitionType.leftToRight,
                  child: const AccountAndPrivacyPage(),
                ),
              );
            },
          ),
InkWell(
  onTap: () {
    AdaptiveTheme.of(context).toggleThemeMode();
  },
  child: StatefulBuilder(
    builder: (context, setState) {
      return ListTile(
        title: const Text('Themes'),
        subtitle: 
        
        AdaptiveTheme.of(context).mode.isLight
            ? const Text('Tap to go Dark')
            : const Text('Double Tap to go Light'),

        leading: AdaptiveTheme.of(context).mode.isLight
            ? const Icon(PhosphorIcons.moon)
            : const Icon(PhosphorIcons.sun),
      );
    },
  ),
),

         
          ListTile(
            leading: const Icon(PhosphorIcons.bell),
               title: const Text('Notifications'),
            subtitle: const Text('Remind me to write daily at'),
            trailing: Text(savedNotificationTime ?? 'Not set'),
            onTap: () async {
              await createDailyNotification(context);
              checkAndPrintScheduledNotifications();
              _loadSavedNotificationTime(); // Reload saved time after setting
            },
          ),
          ListTile(
            leading: const Icon(PhosphorIcons.question),
            title: const Text('Help'),
            subtitle: const Text('Community and Support'),
            onTap: () {
              // Navigate to Help settings
            },
          ),
          ListTile(
            leading: const Icon(PhosphorIcons.user_plus),
            title: const Text('Invite a friend'),
            onTap: () {
              // Navigate to Invite a friend settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(PhosphorIcons.instagram_logo),
            title: const Text('Open Instagram'),
            onTap: () async {
              if (!await launchUrl(
                  Uri.parse("https://www.instagram.com/keerkeeet/"),
                  mode: LaunchMode.externalApplication)) {
                throw 'Could not launch ';
              }
            },
          ),
        ],
      ),
    );
  }
}
