import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/social.dart';
import 'package:gym_app/workouts.dart';
import 'package:gym_app/login.dart';
import 'package:gym_app/progress.dart';
import 'package:firebase_core/firebase_core.dart';

import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

List<String> practiceText = ['Test'];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: MyLoginPage(title: 'Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  late Timer periodicTimer;

  @override
  void initState() {
    super.initState();

    periodicTimer = Timer.periodic(
      const Duration(seconds: 3), // Timer called every 3 seconds to change text
      (timer) {
        setState(() {
          practiceText = (['Test 1', 'Test 2', 'Test 3', 'Test 4']
            ..shuffle()); // Gets random text from array
        });
      },
    );
  }

  @override
  void dispose() {
    periodicTimer.cancel(); // if UI disposed timer stops
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APP BAR
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colours.headSimple,
        title: const Text('SWIFT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontFamily: 'Futura',
            )),
      ),
      backgroundColor: Colours.backgroundSimple,

      // BOTTOM NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colours.navSimple,
        elevation: 10,
        currentIndex: _currentIndex,
        onTap: (index) => _onBottomNavigationBarItemTapped(context, index),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.call,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Workouts',
          ),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Prog',
          ),*/
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // TEXT BOX
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height *
                      0.25, // Getting size of screen and then making box 25% of the height of the specific screen
                  width: MediaQuery.of(context).size.width * 0.85),
              child: const Card(
                color: Colours.mainBoxSimple,
                child: Text(
                  'Workouts completed: 0',
                  style: TextStyle(color: Colors.white, fontFamily: 'Futura'),
                ),
              ),
            ),

            // TEXT BOX
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height * 0.40,
                  width: MediaQuery.of(context).size.width * 0.85),
              child: Card(
                color: Colours.otherBoxSimple,
                child: Text(
                  practiceText.first,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Futura',
                    fontSize: 12,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onBottomNavigationBarItemTapped(BuildContext context, int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => socialPage()),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WorkoutsPage()),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => progressPage()),
          );
          break;
      }
    });
  }
}

class Colours {
  static const Color head = Color.fromRGBO(207, 73, 23, 1);
  static const Color mainBox = Color.fromRGBO(249, 172, 61, 1);
  static const Color otherBox = Color.fromRGBO(45, 117, 140, 1);
  static const Color nav = Color.fromRGBO(117, 140, 51, 1);
  static const Color background = Color.fromRGBO(255, 234, 202, 1);

  static const Color head90s = Color.fromRGBO(231, 111, 81, 1);
  static const Color mainBox90s = Color.fromRGBO(42, 157, 143, 1);
  static const Color otherBox90s = Color.fromRGBO(38, 70, 83, 1);
  static const Color nav90s = Color.fromRGBO(38, 70, 83, 1);
  static const Color background90s = Color.fromRGBO(233, 196, 106, 1);

  static const Color headSimple = Color.fromRGBO(230, 110, 94, 1);
  static const Color mainBoxSimple = Color.fromRGBO(77, 217, 235, 1);
  static const Color otherBoxSimple = Color.fromRGBO(45, 200, 221, 1);
  static const Color navSimple = Color.fromRGBO(252, 203, 196, 1);
  static const Color backgroundSimple = Color.fromRGBO(248, 244, 229, 1);
}
