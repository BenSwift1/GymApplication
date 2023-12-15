import 'package:flutter/material.dart';
import 'package:gym_app/main.dart';

void main() {
  runApp(const MyApp());
}

class SocialPage extends StatelessWidget {
  const SocialPage({super.key, Key? key2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social Page')),
      body: const Center(
        child: Text(
          'This is the Social Page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}

class socialPage extends StatefulWidget {
  const socialPage({super.key, required this.title});

  final String title;

  @override
  State<socialPage> createState() => _socialPageState();
}

class _socialPageState extends State<socialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
