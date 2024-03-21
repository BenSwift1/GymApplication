import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app/create_workout.dart';
import 'package:gym_app/login.dart';
import 'package:gym_app/social.dart';
import 'package:gym_app/social_main.dart';
import 'package:gym_app/underway_workout.dart';
import 'package:gym_app/main.dart';

class WorkoutsPage extends StatefulWidget {
  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  int workoutBox = 0;
  List<String> workoutBoxes = [
    'Workout 1',
    'Workout 2',
    'Workout 3',
    'Workout 4',
    'Workout 5'
  ];
  List<List<Map<String, dynamic>>> allWorkouts = [];

  @override
  void initState() {
    super.initState();
    getWorkoutData();
  }

  Future<void> getWorkoutData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        QuerySnapshot workoutSnapshot = await FirebaseFirestore.instance
            .collection('workouts') // Workouts user has choice of
            .doc(userId)
            .collection('completed_workouts') // Workouts the user has finished
            .get();

        if (workoutSnapshot.docs.isNotEmpty) {
          List<List<Map<String, dynamic>>> allWorkoutsData = [];

          workoutSnapshot.docs.forEach((DocumentSnapshot document) {
            Map<String, dynamic> workoutData =
                document.data() as Map<String, dynamic>;
            List<dynamic> exercises = workoutData['exercises'];

            List<Map<String, dynamic>> mappedExercises = [];
            for (var exercise in exercises) {
              mappedExercises.add(exercise as Map<String, dynamic>);
            }

            allWorkoutsData.add(mappedExercises);
          });

          setState(() {
            allWorkouts = allWorkoutsData;
          });
        } else {
          print('User hasnt completed any workouts');
        }
      }
    } catch (e) {
      print('Error reading exercise data from database: $e');
    }
  }

  // Sends workout to social page
  void shareWorkout() {
    if (allWorkouts.isNotEmpty && allWorkouts[workoutBox].isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              socialPage(workoutDetails: allWorkouts[workoutBox]),
        ),
      );
    }
  }

  /*Future<void> getSharedWorkouts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        QuerySnapshot workoutSnapshot = await FirebaseFirestore.instance
            .collection('workouts')
            .doc(userId)
            .collection('completed_workouts')
            .where('shared', isEqualTo: true) // Filter by shared workouts
            .get();

        if (workoutSnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> sharedWorkoutsData = []; // Flat list

          workoutSnapshot.docs.forEach((DocumentSnapshot document) {
            Map<String, dynamic> workoutData =
                document.data() as Map<String, dynamic>;
            List<dynamic> exercises = workoutData['exercises'];

            exercises.forEach((exercise) {
              sharedWorkoutsData.add(exercise as Map<String, dynamic>);
            });
          });

          // Navigate to social page with shared workouts
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  socialPage(workoutDetails: sharedWorkoutsData),
            ),
          );
        } else {
          print('No shared workouts found');
        }
      }
    } catch (e) {
      print('Error fetching shared workouts: $e');
    }
  }*/

  void switchWorkoutForward() {
    setState(() {
      workoutBox = (workoutBox + 1) % workoutBoxes.length;
    });
  }

  void switchWorkoutBackward() {
    setState(() {
      workoutBox = (workoutBox - 1) % workoutBoxes.length;
      if (workoutBox < 0) {
        workoutBox = workoutBoxes.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workouts',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: Colours.headSimple,
      ),
      backgroundColor: Colours.backgroundSimple,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Buttons for navigating to other pages
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateWorkouts()),
                  ),
                  child: Text('Create workout'),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UnderwayWorkoutPage(),
                    ),
                  ),
                  child: Text('Start workout'),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => socialPageMain(),
                    ),
                  ),
                  child: Text('Start workout'),
                ),
              ),
            ],
          ),

          SizedBox(height: 20), // Space between rows
          // Additional buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[],
          ),
          SizedBox(height: 40), // Padding above
          // Dismissible widget for workout box so can switch between workout data
          Dismissible(
            key: UniqueKey(),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                switchWorkoutForward();
              }
              if (direction == DismissDirection.startToEnd) {
                switchWorkoutBackward();
              }
            },
            background: Container(
              color: Colours.mainBoxSimple,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Container(
              width: 250,
              height: 400,
              color: Colours.mainBoxSimple,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      workoutBoxes[workoutBox],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Getting workouts from firebase and putting in box
                    if (allWorkouts.isNotEmpty &&
                        allWorkouts[workoutBox].isNotEmpty)
                      for (var details in allWorkouts[workoutBox])
                        Text(
                          'Exercise: ${details['exercise']}\nReps: ${details['reps']}, Weight: ${details['weight']}\n',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                    ElevatedButton(
                        onPressed: sharingWorkoutBool,
                        child: Text("Share workout"))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colours.navSimple,
        elevation: 0,
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
    );
  }
}

Future<void> sharingWorkoutBool() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      QuerySnapshot workoutSnapshot = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(userId)
          .collection('completed_workouts')
          .get();

      if (workoutSnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot document in workoutSnapshot.docs) {
          Map<String, dynamic> workoutData =
              document.data() as Map<String, dynamic>;
          bool shared = workoutData['shared'] ?? false;

          // Setting bool true
          if (!shared) {
            await document.reference.update({'shared': true});
            print("Bool set to true");
          }
        }
      } else {
        print('Bool couldnt be set to true');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
