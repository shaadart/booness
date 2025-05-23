import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:booness/firebase_options.dart';
import 'package:booness/models/userData.dart';
import 'package:booness/services/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'pages/Diary UI/DairyUi.dart';
import 'pages/Set up and sign up/onboardoing.dart';
import 'pages/Read Write Edit/writeDiary.dart';
import 'pages/settings/setting_page.dart';
import 'provider/search_controller_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'daily_reminders',
        channelName: 'Daily Reminders',
        channelDescription:
            'Notifications for the Daily Reminders to write the Diary',
        defaultColor: const Color(0xFF9D50DD),
        channelShowBadge: true,
        importance: NotificationImportance.High,
        ledColor: Colors.white,
      ),
    ],
    debug: false,
  );

  currentUser == null ? print("uid is null") : checkAndRenewLives();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    ChangeNotifierProvider(
      create: (context) => SearchControllerProvider(),
      child: const MyApp(),
    ),
  );
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
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: theme,
            home: currentUser == null
                ? OnBoardingScreen(
                    onFinish: () {},
                  )
                : const HomeScreen(title: 'Daily Goodness')
            // : ResponsiveLayout(mobile: MobileBody(), tablet: DesktopBody())
            // home: const HomeScreen(title: 'Daily Goodness'),
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
    final searchController =
        Provider.of<SearchControllerProvider>(context).searchController;
    return Scaffold(
      appBar: AppBarWithSearchSwitch(
        titleTextStyle: GoogleFonts.silkscreen(fontSize: 21),
        customTextEditingController: searchController,
        toolbarTextStyle: GoogleFonts.silkscreen(
          fontWeight: FontWeight.bold,
        ),
        searchInputDecoration: InputDecoration(
          hintText: "Search Your Diary",
          hintStyle: GoogleFonts.silkscreen(),
          border: InputBorder.none,
        ),
        closeSearchIcon: PhosphorIcons.x,
        clearSearchIcon: PhosphorIcons.x,
        onChanged: (text) {
          setState(() {});
        },
        onCleared: () {
          setState(() {
            searchController.clear();
          });
        },
        clearOnClose: true,
        closeOnSubmit: false,
        onClosed: () {
          if (mounted) {
            setState(() {
              searchController.clear();
            });
          }
        },
        appBarBuilder: (context) {
          return AppBar(
            elevation: 4,
            leading: Row(
              children: [
                Text("  "),
                InkWell(
                  onTap: () => Navigator.push(
                      context,
                      PageTransition(
                        curve: Curves.fastEaseInToSlowEaseOut,
                        duration: const Duration(milliseconds: 200),
                        type: PageTransitionType.leftToRight,
                        child: const SettingsPage(),
                      )),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      photoUrl!,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.shortestSide * 0.05),
                child: IconButton(
                    onPressed: () {
                      searchController.clear();
                      if (mounted) {
                        AppBarWithSearchSwitch.of(context)!.startSearch();
                      }
                    },
                    icon: const Icon(PhosphorIcons.magnifying_glass)),
              ),
            ],
            title: GestureDetector(
              onTap: () {
                if (mounted) {
                  setState(() {
                    searchController.clear();
                    AppBarWithSearchSwitch.of(context)!.startSearch();
                  });
                }
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
