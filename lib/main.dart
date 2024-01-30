import 'package:booness/pages/open_dairy.dart';
import 'package:booness/pages/signin.dart';
import 'package:booness/pages/splashScreen.dart';
import 'package:booness/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'services/realtime_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          // these are variable
          // for each firebase project
          apiKey: "AIzaSyAjlMBnRl09ld30ny6smrFhI6k-aVa81qM",
          authDomain: "dailygoodness-ad11f.firebaseapp.com",
          projectId: "dailygoodness-ad11f",
          databaseURL:
              "https://dailygoodness-ad11f-default-rtdb.asia-southeast1.firebasedatabase.app/",
          storageBucket: "dailygoodness-ad11f.appspot.com",
          messagingSenderId: "61474647326",
          appId: "1:61474647326:web:4629082b50efd3b7102d0f",
          measurementId: "G-P5Q8Y9CKTQ"));
  runApp(MaterialApp(
      home: user != null
          ? HomeScreen(
              title: '',
            )
          : const GoogleSignIn()));
}

User? user = FirebaseAuth.instance.currentUser;

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
        textTheme: GoogleFonts.workSansTextTheme(
          Theme.of(context).textTheme,
        ),
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0000ff),
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
      bottomNavigationBar: BottomAppBar(
          //color: Colors.white,
          child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          IconButton(
              onPressed: () {
                OpenDairy(context);
              },
              icon: const Icon(Icons.add)),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.web_stories_outlined),
            onPressed: () {},
          ),
        ],
      )),

      appBar: AppBar(
        leading: CircleAvatar(
          backgroundImage: NetworkImage('${user!.photoURL}', scale: 0.5),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the HomeScreen object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FirebaseAnimatedList(
        query: ref,
        itemBuilder: (context, snapshot, animation, index) {
          return Card(
            child: ListTile(
                title: Text(snapshot.child('title').value.toString()),
                subtitle: Text(snapshot.child('entry').value.toString()),
                trailing: Text(snapshot.child('date').value.toString())),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          signOut(context);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
