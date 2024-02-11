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
              border: UnderlineInputBorder(),
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
          ConstrainedBox(
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height * 0.60,
              width: MediaQuery.of(context).size.width * 0.85,
            ),
            child: Card(
              color: const Color.fromRGBO(255, 202, 58, 1),
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(exercises[index]),
                  );
                },
              ),
            ),
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
