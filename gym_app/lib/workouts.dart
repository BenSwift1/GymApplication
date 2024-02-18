import 'package:flutter/material.dart';
import 'package:gym_app/main.dart';
import 'package:gym_app/create_workout.dart';
import 'package:gym_app/login.dart';
import 'package:gym_app/start_workout.dart';

void main() {
  //runApp(const MyApp());
}

class workoutsPage extends StatefulWidget {
  @override
  _WorkoutsPageState createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<workoutsPage> {
  // Trak which box
  int workoutBox = 0;

  // Box for each workout
  List<String> workoutBoxes = [
    'Workout 1',
    'Workout 2',
    'Workout 3',
  ];

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                    MaterialPageRoute(builder: (context) => startWorkoutPage()),
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
            SizedBox(height: 20),
            Dismissible(
              key: UniqueKey(),
              // Used to dismiss workout widgets
              onDismissed: (DismissDirection direction) {
                setState(() {
                  // Swiping right on box changes to old workouts
                  if (direction == DismissDirection.endToStart) {
                    workoutBox = (workoutBox + 1) % workoutBoxes.length;
                  }
                  // Swiping left goes back
                  if (direction == DismissDirection.startToEnd) {
                    workoutBox = (workoutBox - 1) % workoutBoxes.length;
                  }
                });
              },
              // Design of the workout boxes
              background: Container(
                color: const Color.fromARGB(255, 254, 183, 178),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Container(
                width: 200,
                height: 200,
                color: const Color.fromARGB(255, 193, 140, 136),
                child: Center(
                  child: Text(
                    workoutBoxes[workoutBox],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Navbar
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
