import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:booness/firebase_options.dart';
import 'package:booness/models/userData.dart';
import 'package:booness/pages/signin.dart';
import 'package:booness/services/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/DairyUi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
      // debugShowCheckedModeBanner: true,
      // home: MyApp()
      home: currentUser != null ? const MyApp() : const LoginScreen()));
}

final currentUser = FirebaseAuth.instance.currentUser;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
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
              home: const HomeScreen(title: 'Daily Goodness'),
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
  get builder => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearchSwitch(
        customTextEditingController: searchController,
        toolbarTextStyle: GoogleFonts.cedarvilleCursive(
          fontWeight: FontWeight.bold,
        ),
        searchInputDecoration: InputDecoration(
          hintText: "Search your diary",
          hintStyle: GoogleFonts.cedarvilleCursive(
            fontWeight: FontWeight.bold,
          ),
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
            leading: GestureDetector(
              onTap: () => AdaptiveTheme.of(context).setDark(),
              onDoubleTap: () => AdaptiveTheme.of(context).setLight(),
              child: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  scale: 0.5,
                  photoUrl!,
                ),
              ),

              // Your CircleAvatar properties here
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
            title: Text(
              "Booness",
              style: GoogleFonts.cedarvilleCursive(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          );
        },
      ),
      body: const DiaryUI(),
    );
  }
}
