import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

class CreateWorkouts extends StatefulWidget {
  const CreateWorkouts({Key? key}) : super(key: key);

  @override
  _CreateWorkoutsState createState() => _CreateWorkoutsState();
}

class _CreateWorkoutsState extends State<CreateWorkouts> {
  Map<String, List<String>> workouts = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedWorkout = 'Workout 1';
  TextEditingController myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWorkoutsData();
  }

  void initializeDefaultWorkouts() {
    // Basic workouts
    workouts = {
      'Workout 1': ['Deadlift', 'Bench Press'],
      'Workout 2': ['Pull-ups', 'Dumbell Row'],
      'Workout 3': ['Squat', 'Leg press'],
    };
    selectedWorkout = workouts.keys.first;
  }

  Future<void> loadWorkoutsData() async {
    final user = _auth.currentUser;
    if (user != null) {
      print('User ID: ${user.uid}');

      final userId = user.uid;
      final workoutRef =
          FirebaseFirestore.instance.collection('workouts').doc(userId);

      try {
        final workoutData = await workoutRef.collection('user_workouts').get();
        if (workoutData.docs.isEmpty) {
          initializeDefaultWorkouts();
          saveDefaultWorkoutsToFirestore(userId);
        } else {
          print('Workout data loaded successfully.');
          workouts.clear(); // Clear existing data to reload from Firestore
          for (final doc in workoutData.docs) {
            final workoutNumber = doc['workoutNumber'] as String;
            final exercises =
                List<String>.from(doc['exercises'] as List<dynamic>);
            workouts[workoutNumber] = exercises;
          }
          if (workouts.isNotEmpty) {
            selectedWorkout = workouts.keys.first;
          }
        }
        setState(() {});
      } catch (e) {
        print('Error loading workout data: $e');
      }
    } else {
      print('User is not authenticated. Redirect to login page.');
    }
  }

  Future<void> saveDefaultWorkoutsToFirestore(String userId) async {
    final workoutRef =
        FirebaseFirestore.instance.collection('workouts').doc(userId);
    try {
      workouts.forEach((workoutNumber, exercises) async {
        await workoutRef.collection('user_workouts').doc(workoutNumber).set({
          'workoutNumber': workoutNumber,
          'exercises': exercises,
        });
      });
    } catch (e) {
      print('Error saving default workout $e');
    }
  }

  Future<void> saveWorkoutData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      final workoutRef =
          FirebaseFirestore.instance.collection('workouts').doc(userId);

      final workoutDoc = await workoutRef
          .collection('user_workouts')
          .doc(selectedWorkout)
          .get();

      try {
        if (workoutDoc.exists) {
          await workoutRef
              .collection('user_workouts')
              .doc(selectedWorkout)
              .update({
            'exercises': FieldValue.arrayUnion(workouts[selectedWorkout]!),
          });
        } else {
          await workoutRef
              .collection('user_workouts')
              .doc(selectedWorkout)
              .set({
            'workoutNumber': selectedWorkout,
            'exercises': workouts[selectedWorkout],
          });
        }

        print('Workout data updated for: $selectedWorkout');
      } catch (e) {
        print('Error saving workout data: $e');
      }
    }
  }

  Future<void> saveRemovedWorkoutData(String removedExercise) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      final workoutRef =
          FirebaseFirestore.instance.collection('workouts').doc(userId);

      try {
        if (workouts[selectedWorkout]!.contains(removedExercise)) {
          await workoutRef
              .collection('user_workouts')
              .doc(selectedWorkout)
              .update({
            'exercises': FieldValue.arrayRemove([removedExercise]),
          });
        }

        setState(() {
          workouts[selectedWorkout]!.remove(removedExercise);
        });

        print('Workout data updated for: $selectedWorkout');
      } catch (e) {
        print('Error saving workout data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Workouts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(255, 89, 94, 1),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: myController,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              hintText: 'Enter an exercise:',
            ),
          ),
          ElevatedButton(
            // Adding exercises to database
            onPressed: () async {
              final exercise = myController.text;
              if (workouts.containsKey(selectedWorkout)) {
                workouts[selectedWorkout]!.add(exercise);
                await saveWorkoutData();
              } else {
                workouts[selectedWorkout] = [exercise];
              }
              myController.clear();
            },
            child: const Text('Add Exercise'),
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.35,
                maxHeight: MediaQuery.of(context).size.height * 0.60,
              ),
              child: Card(
                color: Color.fromRGBO(138, 201, 38, 1),
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedWorkout = workouts.keys.toList()[index];
                        });
                        print('Clicked on workout: $selectedWorkout');
                      },
                      child: ListTile(
                        title: Text(
                          workouts.keys.toList()[index],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.60,
                maxHeight: MediaQuery.of(context).size.height * 0.60,
              ),
              child: Card(
                color: const Color.fromRGBO(255, 202, 58, 1),
                child: ListView.builder(
                  itemCount: workouts[selectedWorkout]?.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            workouts[selectedWorkout]![index],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            color: Color.fromARGB(255, 255, 255, 255),
                            onPressed: () async {
                              final removedExercise =
                                  workouts[selectedWorkout]![index];
                              setState(() {
                                workouts[selectedWorkout]!
                                    .remove(removedExercise);
                              });
                              await saveRemovedWorkoutData(removedExercise);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const CreateWorkouts(),
    );
  }
}
