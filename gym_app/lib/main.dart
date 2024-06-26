import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/social.dart';
import 'package:gym_app/workouts.dart';
import 'package:gym_app/login.dart';
import 'package:gym_app/progress.dart';
import 'package:gym_app/social_main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:gym_app/user_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

int totalReppMain = 0;
int totalSetsMain = 0;
int totalWeightMain = 0;
int weeksConsecutive = 0;
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

// Creating a graph showing users reps over days
class displayingRepsGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FutureBuilder<List<Map<DateTime, int>>>(
        future: countingUserReps(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data ?? [];
            return LineChart(
              LineChartData(
                minX: // Setting it so table is over days. X axis is days of the month
                    data.isNotEmpty ? data.first.keys.first.day.toDouble() : 0,
                maxX: data.isNotEmpty ? data.last.keys.first.day.toDouble() : 0,
                minY: 0,
                maxY: data
                        .isNotEmpty // If reps isnt empty the max number is set to highest amount of reps
                    ? data
                        .map((e) => e.values.first)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble()
                    : 0,
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .map((entry) => FlSpot(entry.keys.first.day.toDouble(),
                            entry.values.first.toDouble()))
                        .toList(),
                    isCurved: false,
                    color: Colours.headSimple,
                  ),
                ],
                titlesData: const FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class displayingSetsGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FutureBuilder<List<Map<DateTime, int>>>(
        future: countingUserSets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data ?? [];
            return LineChart(
              LineChartData(
                minX: // Setting it so table is over days. X axis is days of the month
                    data.isNotEmpty ? data.first.keys.first.day.toDouble() : 0,
                maxX: data.isNotEmpty ? data.last.keys.first.day.toDouble() : 0,
                minY: 0,
                maxY: data
                        .isNotEmpty // If reps isnt empty the max number is set to highest amount of reps
                    ? data
                        .map((e) => e.values.first)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble()
                    : 0,
                lineBarsData: [
                  LineChartBarData(
                    // Mapping the spots on graph
                    spots: data
                        .map((entry) => FlSpot(entry.keys.first.day.toDouble(),
                            entry.values.first.toDouble()))
                        .toList(),
                    isCurved: false,
                    color: Colours.headSimple,
                  ),
                ],
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
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
  int workoutsCompleted = 0;
  late Timer periodicTimer;
  late Map<String, Color> userPreferences;

  @override
  void initState() {
    super.initState();
    Colours.changingColours().then((preferences) {
      setState(() {
        userPreferences = preferences; // Setting colours when screen loads
      });
      countingUserReps();
      countingUserSets();
      countingUserWeight();
    });

    workoutCounter(FirebaseAuth.instance.currentUser!.uid);

    consecDays(FirebaseAuth.instance.currentUser!.uid).then((consecutiveWeeks) {
      setState(() {
        weeksConsecutive = consecutiveWeeks;
      });
    });

    periodicTimer = Timer.periodic(
      const Duration(seconds: 3), // Timer called every 3 seconds to change text
      (timer) {
        setState(() {
          practiceText = (['Test 1', 'Test 2', 'Test 3', 'Test 4']
            ..shuffle()); // Gets random text from array
          workoutCounter(FirebaseAuth.instance.currentUser!
              .uid); // Updating amount of workouts completed
        });
      },
    );
  }

  // Counts how many workouts user has completed at stores in variable
  Future<int> workoutCounter(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(userId)
          .collection('completed_workouts')
          .get();
      workoutsCompleted = querySnapshot.size;
      return querySnapshot.size;
    } catch (e) {
      print('Error counting completed workouts: $e');
      return 0;
    }
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
        backgroundColor: userPreferences['head'] ?? Colours.headSimple,
        title: const Text('SWIFT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontFamily: 'Futura',
            )),
      ),
      backgroundColor:
          userPreferences['background'] ?? Colours.backgroundSimple,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: userPreferences['nav'] ?? Colours.navSimple,
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
              child: Card(
                color: userPreferences['otherBox'] ?? Colours.otherBoxSimple,
                child: Text(
                  'Workouts completed:  $workoutsCompleted\n Reps completed: $totalReppMain\nSets completed: $totalSetsMain\nWeight lifted: $totalWeightMain \nConsecutive days exercised: $weeksConsecutive',
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
                color: userPreferences['mainBox'] ?? Colours.mainBoxSimple,
                child: displayingSetsGraph(), // Displaying graph in box
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
            MaterialPageRoute(builder: (context) => socialPageMain()),
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

  // Fucntion to set colour scheme user selected
  static Future<Map<String, Color>> changingColours() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        DocumentSnapshot userPreferences = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        // Getting colours from colour scheme field
        if (userPreferences.exists && userPreferences['colourScheme'] != null) {
          // Turning colours into int to then be written to database
          Map<String, dynamic> colourScheme =
              userPreferences['colourScheme'] as Map<String, dynamic>;
          Color headColor = Color(colourScheme['head'] as int);
          Color mainBoxColor = Color(colourScheme['mainBox'] as int);
          Color otherBoxColor = Color(colourScheme['otherBox'] as int);
          Color navColor = Color(colourScheme['nav'] as int);
          Color backgroundColor = Color(colourScheme['background'] as int);

          // Setting the colours
          return {
            'head': headColor,
            'mainBox': mainBoxColor,
            'otherBox': otherBoxColor,
            'nav': navColor,
            'background': backgroundColor,
          };
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    // Basic start colours when user hasnt chose theyre scheme yet
    return {
      'head': Color.fromARGB(255, 33, 58, 244),
      'mainBox': const Color.fromARGB(255, 63, 144, 211),
      'otherBox': const Color.fromARGB(255, 75, 180, 79),
      'nav': Color.fromARGB(255, 112, 3, 3),
      'background': const Color.fromARGB(255, 255, 255, 255),
    };
  }
}

// Tracks consecutive days user has exercised
Future<int> consecDays(String userId) async {
  try {
    final completedWorkoutsSnapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .doc(userId)
        .collection('completed_workouts')
        .orderBy(
            'timestamp') // Getting time workouts were completed of user logged in
        .get();

    // If they havent completed any workouts yet
    if (completedWorkoutsSnapshot.docs.isEmpty) {
      return 0;
    }

    // Storing in workout dates
    List<DateTime> workoutDates = completedWorkoutsSnapshot.docs.map((doc) {
      final timestamp = (doc['timestamp'] as Timestamp).toDate();
      return timestamp;
    }).toList();

    // Initialize variables
    int consecDaysNum = 0;
    DateTime? lastDate;

    // For every workout
    for (var date in workoutDates) {
      // Works out difference of last date workout was completed and current date
      if (lastDate?.difference(date).inDays.abs() == 1) {
        consecDaysNum++;
      } else {
        break;
      }
      lastDate = date;
    }

    return consecDaysNum;
  } catch (e) {
    print("Error calculating consecutive days: $e");
    return 0;
  }
}

Future<List<Map<DateTime, int>>> countingUserReps() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      final completedWorkoutsSnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(userId)
          .collection('completed_workouts')
          .get();

      List<Map<DateTime, int>> data = [];

      // For every completed workout a user has, accessing the reps
      for (var doc in completedWorkoutsSnapshot.docs) {
        final timestamp = (doc['timestamp'] as Timestamp).toDate();
        final exercises = doc['exercises'] as List<dynamic>;
        int totalReps = 0;
        for (var exercise in exercises) {
          final reps = exercise['reps'] as String;
          totalReps += int.tryParse(reps) ?? 0;
          totalReppMain = totalReps;
        }
        data.add({
          timestamp: totalReps
        }); // Getting timestamp of when reps were complted
      }

      // Sorting data
      data.sort((a, b) => a.keys.first.compareTo(b.keys.first));

      return data;
    }
  } catch (e) {
    print('Reps eror $e');
  }

  return [];
}

Future<List<Map<DateTime, int>>> countingUserSets() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      final completedWorkoutsSnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(userId)
          .collection('completed_workouts')
          .get();

      List<Map<DateTime, int>> data = [];

      // For every completed workout a user has, accessing the sets
      for (var doc in completedWorkoutsSnapshot.docs) {
        final timestamp = (doc['timestamp'] as Timestamp).toDate();
        final exercises = doc['exercises'] as List<dynamic>;
        int totalSets = 0;
        for (var exercise in exercises) {
          final sets = exercise['sets'] as String;
          totalSets += int.tryParse(sets) ?? 0;
          totalSetsMain = totalSets;
        }
        data.add({
          timestamp: totalSets
        }); // Getting timestamp of when reps were complted
      }

      // Sorting data
      data.sort((a, b) => a.keys.first.compareTo(b.keys.first));

      return data;
    }
  } catch (e) {
    print('Sets error $e');
  }

  return [];
}

Future<List<Map<DateTime, int>>> countingUserWeight() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      final completedWorkoutsSnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(userId)
          .collection('completed_workouts')
          .get();

      List<Map<DateTime, int>> data = [];

      // For every completed workout a user has, accessing the weight
      for (var doc in completedWorkoutsSnapshot.docs) {
        final timestamp = (doc['timestamp'] as Timestamp).toDate();
        final exercises = doc['exercises'] as List<dynamic>;
        int totalWeight = 0;
        for (var exercise in exercises) {
          final weight = exercise['weight'] as String;
          totalWeight +=
              int.tryParse(weight) ?? 0; // Adding weight to previous weight
          totalWeightMain =
              totalWeight; // Setting it as final weight to be displayed
        }
        data.add({
          timestamp: totalWeight
        }); // Getting timestamp of when reps were complted
      }

      // Sorting data
      data.sort((a, b) => a.keys.first.compareTo(b.keys.first));

      return data;
    }
  } catch (e) {
    //print('Sets error $e');
  }

  return [];
}
