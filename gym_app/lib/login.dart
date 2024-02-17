import 'package:flutter/material.dart';
import 'package:gym_app/auth.dart';
import 'package:gym_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  runApp(const MyApp());
}

class Login extends StatelessWidget {
  final Auth auth = Auth();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height * 0.50,
          width: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Card(
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
            SizedBox(height: 20),
            // User email input
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            // User password input
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Use the entered email and password
                  await auth.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  print('Sign in successful');
                } catch (e) {
                  print('Error signing in: $e');
                }
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
