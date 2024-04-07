import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app/main.dart';

class Workout {
  String name1;
  List<String> exercises;

  Workout({required this.name1, required this.exercises});
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
        // New firebase colleection to store finishd workouts
        final workoutDB = await workoutRef.collection('user_workouts').get();

        if (workoutDB.docs.isNotEmpty) {
          setState(() {
            workouts = workoutDB.docs.map((doc) {
              return Workout(
                name1: doc['workoutNumber'] as String,
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

  // Where user picks the workout they want to start. Then taken to tracking page
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
                    color: Colours.mainBoxSimple,
                    borderRadius: BorderRadius.circular(5.0)),
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(workouts[index].name1,
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExercisingPage(
                              exercises: workouts[index].exercises,
                            ),
                          ),
                        );
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

class TrackExercise extends StatefulWidget {
  final String exerciseName;
  final TextEditingController setsController;
  final TextEditingController repsController;
  final TextEditingController weightController;

  TrackExercise({
    // Getting everything that needs to be stored in databse
    required this.exerciseName,
    required this.setsController,
    required this.repsController,
    required this.weightController,
  });

  @override
  _TrackExerciseState createState() => _TrackExerciseState();
}

class _TrackExerciseState extends State<TrackExercise> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.exerciseName, style: TextStyle(color: Colors.black)),
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
              controller: widget.setsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Sets',
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: TextField(
              controller: widget.repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Reps',
              ),
            ),
          ),
          SizedBox(width: 10),
          Container(
              width: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: TextField(
                controller: widget.weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Weight',
                ),
              )),
        ],
      ),
    );
  }
}

class ExercisingPage extends StatefulWidget {
  final List<String> exercises;

  ExercisingPage({required this.exercises});

  @override
  _ExercisingPageState createState() => _ExercisingPageState();
}

class _ExercisingPageState extends State<ExercisingPage> {
  List<TextEditingController> setsControllers = [];
  List<TextEditingController> repsControllers = [];
  List<TextEditingController> weightControllers = [];

  @override
  void initState() {
    super.initState();

    for (var _ in widget.exercises) {
      setsControllers.add(TextEditingController());
      repsControllers.add(TextEditingController());
      weightControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in setsControllers) {
      controller.dispose();
    }
    for (var controller in repsControllers) {
      controller.dispose();
    }
    for (var controller in weightControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> storeWorkoutDB() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        // Store the reps sets and exercises completed
        List<Map<String, dynamic>> exerciseData = [];

        for (int i = 0; i < widget.exercises.length; i++) {
          exerciseData.add({
            'exercise': widget.exercises[i],
            'sets': setsControllers[i].text,
            'reps': repsControllers[i].text,
            'weight': weightControllers[i].text,
          });
        }

        final workoutData = {
          'exercises': exerciseData,
          'timestamp': FieldValue.serverTimestamp(),
          'exercises completed': '0',
          'shared': false // Added boolean field with initial value false
        };

        // Adding data to firebase database
        await FirebaseFirestore.instance
            .collection('workouts')
            .doc(userId)
            .collection('completed_workouts')
            .add(workoutData);

        print('Workout data stored in database');
      }
    } catch (e) {
      print('Error writing exercise data to database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercises'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.exercises.length,
                itemBuilder: (context, index) {
                  return TrackExercise(
                    exerciseName: widget.exercises[index],
                    setsController: setsControllers[index],
                    repsController: repsControllers[index],
                    weightController: weightControllers[index],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: storeWorkoutDB,
              child: Text("End workout"),
            ),
          ],
        ),
      ),
    );
  }
}
