import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
      title: 'Login and register',
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
    return MyLoginPage(title: 'Login');
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
        title: Text(
          'Login & Register',
          style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontFamily: 'futura'),
        ),
        backgroundColor: Colours.headSimple,
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return TextButton(
              child: const Text(
                'Sign out',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
              onPressed: () async {
                User user;
                if (_auth.currentUser != null) {
                  user = _auth.currentUser as User;
                  await _auth.signOut();
                  final String uid = user.uid;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //content: Text(uid + ' has successfully signed out.'),
                    content: const Text('User successfully signed out.'),
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
          children: <Widget>[_EmailPasswordForm(), registerEmail()],
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
  String _regMessage = "";

  @override
  Widget build(BuildContext) {
    if (Firebase.apps.isNotEmpty) {
      print("Firebase successfully initialised.");
    } else {
      print("Firebase failed to intialise. Restart app.");
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Register',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Form(
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
                    /*child: const Text(
                'Register',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),*/
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _register();
                          //storeEmailDB('bob');
                        }
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(_regMessage),
                  ),
                ],
              ))
        ]);
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
          storeEmailDB(_emailController.text.trim());
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
            child: const Text(
              'Sign In',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            padding: const EdgeInsets.all(16),
            //alignment: Alignment.center,
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (String? value) {
              if (value!.isEmpty) {
                return 'Enter email...';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (String? value) {
              if (value!.isEmpty) {
                return 'Enter password...';
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
              child: const Text(
                'Log in',
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_loginMessage,
                style: TextStyle(color: Colours.mainBoxSimple)),
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

// Getting users email to store for friends functionality
Future<void> storeEmailDB(String email) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user signed in');
      return;
    }
    final userId = user.uid;

    // Storing email in a new collection called users
    final usersCollectionRef = FirebaseFirestore.instance.collection('users');
    // Adding email to users collection
    await usersCollectionRef.doc(userId).set({'email': email});

    print('Email stored successfully in database');
  } catch (e) {
    print('Error storing email: $e');
  }
}
