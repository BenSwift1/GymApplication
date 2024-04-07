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
    'Workout 5',
    'Workout 6',
    'Workout 7',
    'Workout 8',
    'Workout 9',
    'Workout 10'
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

  Future<void> shareWorkoutToFriends() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not signed in.');
      return;
    }

    if (allWorkouts.isNotEmpty && allWorkouts[workoutBox].isNotEmpty) {
      final userId = user.uid;
      final workoutDetails = allWorkouts[workoutBox];

      final workoutId = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('shared_workouts')
            .doc(workoutId)
            .set({
          'workoutId': workoutId,
          'workoutDetails': workoutDetails,
        });
        sharingWorkoutBool();
        print('Workout shared successfully.');
      } catch (e) {
        print('Error sharing workout: $e');
      }
    } else {
      print('No workout to share or workout details are empty.');
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Create workout',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 60, 60, 60),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Start workout',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 60, 60, 60),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Delete workout',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 60, 60, 60),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
              width: 280,
              height: 420,
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
                    SizedBox(height: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            // Getting workouts from firebase and putting in box
                            if (allWorkouts.isNotEmpty &&
                                allWorkouts[workoutBox].isNotEmpty)
                              for (var details in allWorkouts[workoutBox])
                                Text(
                                  'Exercise: ${details['exercise']}\nReps: ${details['reps']}, Weight: ${details['weight']}, Sets: ${details['sets']}\n',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: shareWorkoutToFriends,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 8), // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        "Share workout",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 60, 60, 60),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
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

// Using a boolean to track wether workout should be shared or not
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
