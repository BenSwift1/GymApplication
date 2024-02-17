import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/social.dart';
import 'package:gym_app/workouts.dart';
import 'package:gym_app/login.dart';
import 'package:gym_app/progress.dart';

import 'dart:async';

void main() {
  runApp(const MyApp());
}

List<String> practiceText = ['Test'];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gym App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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
        backgroundColor: const Color.fromRGBO(255, 89, 94, 1),
        title: const Text('SWIFT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontFamily: 'Futura',
            )),
      ),
      backgroundColor: const Color.fromRGBO(232, 241, 242, 1),

      // BOTTOM NAV BAR
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(25, 130, 196, 1),
        elevation: 0,
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
                color: Color.fromRGBO(255, 202, 58, 1),
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
                color: const Color.fromRGBO(138, 201, 38, 1),
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
            MaterialPageRoute(builder: (context) => workoutsPage()),
          );
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
