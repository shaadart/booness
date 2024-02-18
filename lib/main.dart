import 'package:booness/firebase_options.dart';
import 'package:booness/models/userData.dart';
import 'package:booness/pages/signin.dart';
import 'package:booness/pages/splashScreen.dart';
import 'package:booness/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import 'pages/DairyUi.dart';
import 'pages/writeDiary.dart';
import 'services/realtime_database.dart';

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
      // home: MyApp()
      home: currentUser != null
          ? HomeScreen(
              title: '',
            )
          : const LoginScreen()));
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 241, 96, 0),
          // primary: Color(0xff103783),
          // secondary: Color(0xff9bafd9)
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(title: 'Daily Goodness'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  get builder => null;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              photoUrl!,
            ),
            // Your CircleAvatar properties here
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
                  signOut(context);
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
      ),
      body: SingleChildScrollView(child: const DiaryUI()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // signOut(context);
          void readData() {
            ref.onValue.listen((event) {
              DataSnapshot dataSnapshot = event.snapshot;
              Object? values = dataSnapshot.value;
              (values as Map<dynamic, dynamic>).forEach((key, values) {
                // Import the necessary library

                // ...

                print(dataSnapshot
                    .value); // Access the "title" key from the JSON data

                print('title: ${values['title']}');
                print('entry: ${values['entry']}');
                print('date: ${values['date']}');
                print("this is the ${currentUser!.providerData[0].uid}");
              });
            });
          }

          readData();

          Navigator.push(
              context,
              PageTransition(
                curve: Curves.fastEaseInToSlowEaseOut,
                duration: const Duration(milliseconds: 200),
                type: PageTransitionType.bottomToTop,
                child: const WriteDiary(),
              ));
        },
        tooltip: 'Increment',
        child: const Icon(PhosphorIcons.plus),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
