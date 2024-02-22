import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Workout {
  String name;
  List<String> exercises;

  Workout({required this.name, required this.exercises});
}

class UnderwayWorkoutPage extends StatefulWidget {
  @override
  _UnderwayWorkoutPageState createState() => _UnderwayWorkoutPageState();
}

class _UnderwayWorkoutPageState extends State<UnderwayWorkoutPage> {
  List<Workout> workouts = [];

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
        final workoutRef =
            FirebaseFirestore.instance.collection('workouts').doc(userId);
        final workoutDB = await workoutRef.collection('user_workouts').get();

        if (workoutDB.docs.isNotEmpty) {
          setState(() {
            workouts = workoutDB.docs.map((doc) {
              return Workout(
                name: doc['workoutNumber'] as String,
                exercises: List<String>.from(doc['exercises'] as List<dynamic>),
              );
            }).toList();
          });
        }
      }
    } catch (e) {
      print('Error getting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Start workout', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(255, 89, 94, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: MediaQuery.of(context).size.width * 0.70),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5.0)),
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(workouts[index].name,
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => exercisingPage(
                                    exercises: workouts[index].exercises)));
                      },
                    );
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

class trackExercise extends StatelessWidget {
  final String exerciseName;

  trackExercise({required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(exerciseName, style: TextStyle(color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 30),
          Container(
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: TextField(
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}

class exercisingPage extends StatelessWidget {
  final List<String> exercises;

  exercisingPage({required this.exercises});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Exercises'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height * 0.80,
              width: MediaQuery.of(context).size.height * 0.40,
            ),
            child: Container(
              color: Colors.red,
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      trackExercise(exerciseName: exercises[index]),
                    ],
                  );
                },
              ),
            ),
          ),
        ));
  }
}
