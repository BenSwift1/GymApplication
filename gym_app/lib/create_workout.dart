import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class CreateWorkouts extends StatefulWidget {
  const CreateWorkouts({Key? key}) : super(key: key);

  @override
  _CreateWorkoutsState createState() => _CreateWorkoutsState();
}

class _CreateWorkoutsState extends State<CreateWorkouts> {
  // Storing certain exercises in speficic workouts
  Map<String, List<String>> workouts = {
    'Workout 1': ['Deadlift', 'Bench Press'],
    'Workout 2': ['Squats', 'Pull-ups'],
    'Workout 3': ['Deadlift', 'Squats', 'Pull-ups'],
    'Workout 4': ['Rows', 'Pull downs', 'Bicep curls'],
  };

  String selectedWorkout = 'Workout 1';

  TextEditingController myController = TextEditingController();

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
            // Adding exercise button
            onPressed: () {
              setState(() {
                final exercise = myController.text;
                if (workouts.containsKey(selectedWorkout)) {
                  workouts[selectedWorkout]!.add(exercise);
                } else {
                  workouts[selectedWorkout] = [exercise];
                }
                myController.clear(); // Clearing text
              });
            },
            child: const Text('Add Exercise'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.60,
                    maxHeight: MediaQuery.of(context).size.height * 0.60,
                  ),
                  child: Card(
                    color: const Color.fromRGBO(255, 202, 58, 1),
                    child: ListView.builder(
                      itemCount: workouts[selectedWorkout]?.length ?? 0,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            print(
                                'Clicked on exercise: ${workouts[selectedWorkout]![index]}');
                          },
                          child: ListTile(
                            title: Text(
                              workouts[selectedWorkout]![index],
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
              const SizedBox(width: 16),
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
                            // Clicking on workout
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
            ],
          ),
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
