import 'package:flutter/material.dart';
import 'package:gym_app/main.dart';
import 'package:gym_app/create_workout.dart';
import 'package:gym_app/login.dart';

void main() {
  //runApp(const MyApp());
}

class workoutsPage extends StatelessWidget {
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
                  onPressed: null,
                  child: Text('Edit workout'),
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
          ],
        ),
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
