import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app/workouts.dart';
import 'package:gym_app/underway_workout.dart';

class startWorkoutPage extends StatefulWidget {
  @override
  _StartWorkoutPageState createState() => _StartWorkoutPageState();
}

class _StartWorkoutPageState extends State<startWorkoutPage> {
  // Storing workouts
  List<String> workouts = [];

  @override
  void initState() {
    super.initState();
    gettingWorkouts();
  }

  Future<void> gettingWorkouts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userId = user.uid;

        // Getting workouts from databse collection
        final workoutRef =
            FirebaseFirestore.instance.collection('workouts').doc(userId);

        // When in collection getting the user workouts
        final workoutDB = await workoutRef.collection('user_workouts').get();

        if (workoutDB.docs.isNotEmpty) {
          setState(() {
            workouts = workoutDB.docs
                .map((doc) => doc['workoutNumber'] as String)
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error geetting data needed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Start workout',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(255, 89, 94, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[],
            ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height *
                      0.75, // Getting size of screen and then making box 25% of the height of the specific screen
                  width: MediaQuery.of(context).size.width * 0.70),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: ListView.builder(
                  // List so there can be infinite space
                  itemCount: workouts.length, // getting amount of workouts
                  itemBuilder: (context, index) {
                    return ListTile(
                        title: Text(
                          workouts[index],
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          // When text is clicked it returns you to workouts page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UnderwayWorkoutPage()),
                          );
                        });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
