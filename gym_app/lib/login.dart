import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Firebase initialized successfully
            return Login();
          }

          if (snapshot.hasError) {
            // Error initializing Firebase
            return Scaffold(
              body: Center(
                child: Text('Error initializing Firebase: ${snapshot.error}'),
              ),
            );
          }

          // Firebase is still initializing
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage(title: 'Firebase Auth Demo');
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return TextButton(
              child: const Text('Sign out'),
              onPressed: () async {
                User user;
                if (_auth.currentUser != null) {
                  user = _auth.currentUser as User;
                  await _auth.signOut();
                  final String uid = user.uid;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(uid + ' has successfully signed out.'),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('No one has signed in.'),
                  ));
                  return;
                }
              },
            );
          })
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(16),
          children: <Widget>[_RegisterEmailSection()],
        );
      }),
    );
  }
}

class _RegisterEmailSection extends StatefulWidget {
  final String title = 'Registration';
  @override
  State<StatefulWidget> createState() => _RegisterEmailSectionState();
}

class _RegisterEmailSectionState extends State<_RegisterEmailSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _userEmail = "";
  String _regMessage = "Hello";

  @override
  Widget build(BuildContext) {
    if (Firebase.apps.isNotEmpty) {
      print("Firebase is initialized.");
    } else {
      print("Firebase is not initialized.");
    }
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _register();
                  }
                },
                child: const Text('Submit'),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(_regMessage),
            ),
          ],
        ));
  }

  void _register() async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = userCredential.user;
      if (user != null) {
        setState(() {
          _userEmail = user.email!;
          _regMessage = "$_userEmail successfully registered";
        });
      } else {
        setState(() {
          _regMessage = "Registration error: User is null";
        });
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      setState(() {
        _regMessage = "Registration error: ${e.message}";
      });
    } catch (e) {
      print("Unexpected error: $e");
      setState(() {
        _regMessage = "An unexpected error occurred. Please try again later.";
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
