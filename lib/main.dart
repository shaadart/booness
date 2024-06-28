import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:booness/firebase_options.dart';
import 'package:booness/models/userData.dart';
import 'package:booness/services/notification_services.dart';
import 'package:booness/services/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'pages/DairyUi.dart';
import 'pages/Write and Edit/writeDiary.dart';
import 'pages/settings/setting_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelKey: 'daily_reminders',
            channelName: 'Basic notifications',
            channelDescription:
                'Notifications for the Daily Reminders to write the Diary',
            defaultColor: Color(0xFF9D50DD),
            channelShowBadge: true,
            importance: NotificationImportance.High,
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'daily_reminders',
            channelGroupName: 'Daily Reminder')
      ],
      debug: true);
  await checkAndRenewLives();

  runApp(MaterialApp(
      // debugShowCheckedModeBanner: false,
      home: MyApp()
      // home: currentUser != null ? const MyApp() : OnBoardingScreen()
      ));
}

final currentUser = FirebaseAuth.instance.currentUser;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: lightTheme(),
        dark: darkTheme(),
        initial: AdaptiveThemeMode.dark,
        builder: (theme, darkTheme) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: theme,

              home: const HomeScreen(
                title: '',
              ),
              //  home: const HomeScreen(title: 'Daily Goodness'),
            ));
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearchSwitch(
        titleTextStyle: GoogleFonts.silkscreen(fontSize: 21),
        customTextEditingController: searchController,
        toolbarTextStyle: GoogleFonts.silkscreen(
          fontWeight: FontWeight.bold,
        ),
        searchInputDecoration: InputDecoration(
          hintText: "Search Diary",
          hintStyle: GoogleFonts.silkscreen(),
          border: InputBorder.none,
        ),
        closeSearchIcon: PhosphorIcons.x,
        clearSearchIcon: PhosphorIcons.x,
        onChanged: (text) {
          setState(() {
            print(text);
          });
        },
        onCleared: () {
          setState(() {
            searchController.clear();
          });
        },
        clearOnClose: true,
        closeOnSubmit: false,
        onClosed: () {
          setState(() {
            searchController.clear();
          });
        },
        appBarBuilder: (context) {
          return AppBar(
            elevation: 4,
            leading: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.03),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        PageTransition(
                          curve: Curves.fastEaseInToSlowEaseOut,
                          duration: const Duration(milliseconds: 200),
                          type: PageTransitionType.leftToRight,
                          child: SettingPage(),
                        )),
                    onDoubleTap: () => AdaptiveTheme.of(context).setLight(),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        photoUrl!,
                      ),
                    ),

                    // Your CircleAvatar properties here
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.05),
                child: IconButton(
                    onPressed: () {
                      searchController.clear();
                      AppBarWithSearchSwitch.of(context)!.startSearch();

                      // Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
                    },
                    icon: const Icon(PhosphorIcons.magnifying_glass)),
              ),
            ],
            title: GestureDetector(
              onTap: () {
                setState(() {
                  searchController.clear();
                  AppBarWithSearchSwitch.of(context)!.startSearch();
                });
              },
              child: Text(
                "Booness",
                style: GoogleFonts.silkscreen(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            centerTitle: true,
          );
        },
      ),
      body: const DiaryUI(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(PhosphorIcons.plus),
        onPressed: () {
          createDailyNotification(context);

          Navigator.push(
              context,
              PageTransition(
                curve: Curves.fastEaseInToSlowEaseOut,
                duration: const Duration(milliseconds: 200),
                type: PageTransitionType.bottomToTop,
                child: const WriteDiary(),
              ));
        },
      ),
    );
  }
}
