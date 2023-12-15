import 'package:flutter/material.dart';
import 'package:gym_app/main.dart';

void main() {
  runApp(const MyApp());
}

class workoutsPage extends StatelessWidget {
  const workoutsPage({super.key, Key? key3});

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
      body: const Center(
        child: Text(
          'This is the WORKOUT Page',
          style: TextStyle(fontSize: 24.0),
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

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key, required this.title});

  final String title;

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
