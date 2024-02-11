import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class createWorkouts extends StatefulWidget {
  const createWorkouts({Key? key}) : super(key: key);

  @override
  _CreateWorkoutsState createState() => _CreateWorkoutsState();
}

class _CreateWorkoutsState extends State<createWorkouts> {
  final List<String> exercises = [
    'Deadlift',
    'Bench Press',
    'Squats',
    'Pull-ups'
  ];

  final List<String> workouts = [
    'Workout 1',
    'Workout 2',
    'Workout 3',
  ];

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
            onPressed: () {
              setState(() {
                exercises.add(myController.text);
                myController.clear(); // Clear text field
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
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Handle click on exercise
                            print('Clicked on exercise: ${exercises[index]}');
                          },
                          child: ListTile(
                            title: Text(
                              exercises[index],
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
                        // Allows you to click an item in the list
                        return GestureDetector(
                          onTap: () {
                            print('Clicked on workout: ${workouts[index]}');
                          },
                          child: ListTile(
                            title: Text(
                              workouts[index],
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
      home: const createWorkouts(),
    );
  }
}
