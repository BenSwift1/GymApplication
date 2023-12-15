import 'package:flutter/material.dart';
import 'package:gym_app/main.dart';

void main() {
  runApp(const MyApp());
}

class socialPage extends StatelessWidget {
  const socialPage({super.key, Key? key2});

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
      body: const Center(
        child: Text(
          'This is the social Page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}

class SocialPage extends StatefulWidget {
  const SocialPage({super.key, required this.title});

  final String title;

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
