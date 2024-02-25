import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app/main.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? user = FirebaseAuth.instance.currentUser;

  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: user != null ? MyHomePage(title: 'SWIFT') : MyApp(),
    ),
  );
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
            return Login();
          }

          if (snapshot.hasError) {
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
    return MyLoginPage(title: 'Firebase Auth Demo');
  }
}

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
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
          children: <Widget>[registerEmail(), _EmailPasswordForm()],
        );
      }),
    );
  }
}

class registerEmail extends StatefulWidget {
  final String title = 'Registration';
  @override
  State<StatefulWidget> createState() => registerEmailState();
}

class registerEmailState extends State<registerEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _userEmail = "";
  String _regMessage = "Hello";

  @override
  Widget build(BuildContext) {
    if (Firebase.apps.isNotEmpty) {
      print("Firebase successfully initialised.");
    } else {
      print("Firebase failed to intialise. Restart app.");
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
                  return 'Enter your email...';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Enter your password...';
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
      final userCreds = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = userCreds.user;
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

class _EmailPasswordForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _userEmail = "";
  String _loginMessage = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: const Text('Test sign in with email and password'),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
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
                  _signInWithEmailAndPassword();
                }
              },
              child: const Text('Submit'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_loginMessage, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signInWithEmailAndPassword() async {
    final user = (await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;

    if (user != null) {
      setState(() {
        _userEmail = user!.email as String;
        _loginMessage = "$_userEmail logged in successfully";
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyHomePage(title: 'SWIFT'),
          ),
        );
      });
    } else {
      setState(() {
        _loginMessage = "Error logging in";
      });
    }
  }
}
