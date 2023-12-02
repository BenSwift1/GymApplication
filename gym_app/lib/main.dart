import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gym App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(95, 173, 86, 1),
        title: const Text('Gym App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontFamily: 'Futura',
            )),
      ),
      backgroundColor: const Color.fromRGBO(232, 241, 242, 1),
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromRGBO(242, 193, 78, 1),
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
          ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height *
                      0.25, // Getting size of screen and then making box 25% of the height of the specific screen
                  width: MediaQuery.of(context).size.width * 0.85),
              child: const Card(
                child: const Text(
                  'Workouts completed',
                  style: TextStyle(color: Colors.white),
                ),
                color: const Color.fromRGBO(180, 67, 108, 1),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height * 0.40,
                  width: MediaQuery.of(context).size.width * 0.85),
              child: const Card(
                child: const Text(
                  'Hello World!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Futura',
                    fontSize: 12,
                  ),
                ),
                color: const Color.fromRGBO(247, 129, 84, 1),
              ),
            )
          ],
        ),
      ),
    );
  }
}
