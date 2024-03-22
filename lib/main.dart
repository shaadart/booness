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
    // options: const FirebaseOptions(
    //     // these are variable
    //     // for each firebase project
    //     apiKey: "AIzaSyAjlMBnRl09ld30ny6smrFhI6k-aVa81qM",
    //     authDomain: "dailygoodness-ad11f.firebaseapp.com",
    //     projectId: "dailygoodness-ad11f",
    //     databaseURL:
    //         "https://dailygoodness-ad11f-default-rtdb.asia-southeast1.firebasedatabase.app/",
    //     storageBucket: "dailygoodness-ad11f.appspot.com",
    //     messagingSenderId: "61474647326",
    //     appId: "1:61474647326:web:4629082b50efd3b7102d0f",
    //     measurementId: "G-P5Q8Y9CKTQ"));
  );

  runApp(MaterialApp(
      // debugShowCheckedModeBanner: true,
      // home: MyApp()
      home: currentUser != null ? MyApp() : const LoginScreen()));
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
              home: HomeScreen(title: 'Daily Goodness'),
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
        // fieldHintText: "Search your diary",
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
          setState(() {
            searchController.clear();
          });
        },

        appBarBuilder: (context) {
          return AppBar(
            elevation: 4,
            leading: Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.05),
              child: GestureDetector(
                onTap: () => AdaptiveTheme.of(context).setDark(),
                onDoubleTap: () => AdaptiveTheme.of(context).setLight(),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    photoUrl!,
                  ),
                  // Your CircleAvatar properties here
                ),
              ),
            ),

            // backgroundImage: NetworkImage(
            //     "https://i.pinimg.com/564x/3e/50/5d/3e505dcb08e5391247a279be59a5bdcf.jpg"),

            actions: [
              Padding(
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.05),
                child: IconButton(
                    onPressed: () {
                      AppBarWithSearchSwitch.of(context)!.startSearch();
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
                    },
                    icon: Icon(PhosphorIcons.magnifying_glass)),
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
      body: DiaryUI(),
    );
  }
}
