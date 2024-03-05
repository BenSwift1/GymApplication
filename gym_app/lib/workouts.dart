import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app/create_workout.dart';
import 'package:gym_app/login.dart';
import 'package:gym_app/underway_workout.dart';

class WorkoutsPage extends StatefulWidget {
  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  int workoutBox = 0;
  List<String> workoutBoxes = ['Workout 1', 'Workout 2', 'Workout 3'];
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
            .collection('workouts')
            .doc(userId)
            .collection('completed_workouts')
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

  void switchWorkoutForward() {
    setState(() {
      workoutBox = (workoutBox + 1) % workoutBoxes.length;
    });
  }

  void switchWorkoutBackward() {
    setState(() {
      workoutBox = (workoutBox - 1) % allWorkouts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WORKOUT Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(255, 89, 94, 1),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Buttons for navigating to other pages
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateWorkouts()),
                ),
                child: Text('Create workout'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnderwayWorkoutPage(),
                  ),
                ),
                child: Text('Start workout'),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text('Delete workout'),
              ),
            ],
          ),
          SizedBox(height: 20), // Space between rows
          // Additional buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                ),
                child: Text('Login'),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text('Pull'),
              ),
              ElevatedButton(
                onPressed: null,
                child: Text('Legs'),
              ),
            ],
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
              color: const Color.fromARGB(255, 254, 183, 178),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Container(
              width: 250,
              height: 400,
              color: const Color.fromARGB(255, 193, 140, 136),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(25, 130, 196, 1),
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
