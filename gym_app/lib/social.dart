import 'package:flutter/material.dart';
import 'package:gym_app/main.dart';

void main() {
  runApp(const MyApp());
}

class socialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(255, 89, 94, 1),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // TEXT BOX
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height *
                      0.10, // Getting size of screen and then making box 25% of the height of the specific screen
                  width: MediaQuery.of(context).size.width * 0.85),
              child: const Card(
                color: Color.fromRGBO(255, 202, 58, 1),
                child: Text(
                  'Create workout',
                  style: TextStyle(color: Colors.white, fontFamily: 'Futura'),
                ),
              ),
            ),

            // TEXT BOX
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height * 0.50,
                  width: MediaQuery.of(context).size.width * 0.85),
              child: const Card(
                color: Color.fromRGBO(138, 201, 38, 1),
                child: Text(
                  'Hello World!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Futura',
                    fontSize: 12,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
