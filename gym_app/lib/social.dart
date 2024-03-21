import 'package:flutter/material.dart';
import 'package:gym_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

class socialPage extends StatelessWidget {
  final List<Map<String, dynamic>> workoutDetails;

  socialPage({required this.workoutDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social',
          style: TextStyle(color: Colors.white, fontFamily: 'Futura'),
        ),
        backgroundColor: Colours.headSimple,
      ),
      backgroundColor: Colours.backgroundSimple,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colours.navSimple,
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
            const Padding(padding: EdgeInsets.only(top: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddFriendsPage()),
                    );
                  },
                  child: Text("Add friends"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RequestsPage()),
                    );
                  },
                  child: Text("Requests"),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height * 0.50,
                width: MediaQuery.of(context).size.width * 0.85,
              ),
              child: Card(
                color: Colours.mainBoxSimple,
                child: ListView.builder(
                  itemCount: workoutDetails.length,
                  itemBuilder: (context, index) {
                    final exercise = workoutDetails[index]['exercise'];
                    final reps = workoutDetails[index]['reps'];
                    final weight = workoutDetails[index]['weight'];
                    return ListTile(
                      title: Text(
                          'Exercise: $exercise\nReps: $reps, Weight: $weight\n'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Where user adds friends
class AddFriendsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friends'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Enter friends email...'),
            ),
            ElevatedButton(
              onPressed: () => readEmailDB(),
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// Where user manages friend requests
class RequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Futura',
            )),
        backgroundColor: Colours.headSimple,
      ),
      backgroundColor: Colours.backgroundSimple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddFriendsPage()),
                    );
                  },
                  child: Text("Accept"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RequestsPage()),
                    );
                  },
                  child: Text("Decline"),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height * 0.50,
                width: MediaQuery.of(context).size.width * 0.85,
              ),
              child: const Card(
                color: Colours.mainBoxSimple,
                child: Center(
                  child: Text(
                    'Username1',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Futura',
                      fontSize: 12,
                    ),
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

// checks database to see if email user enters is attached to an account
Future<void> checkEmailExists(String email) async {
  try {
    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('workouts').get();

    print('Total user documents found: ${querySnapshot.docs.length}');

    bool emailExists = false;

    for (final QueryDocumentSnapshot userDoc in querySnapshot.docs) {
      final data = userDoc.data() as Map<String, dynamic>;
      final userEmail = data['email'] as String?;

      print('Checking user document: ${userDoc.id}, Email: $userEmail');

      if (userEmail == email) {
        emailExists = true;
        print('Email exists for user: ${userDoc.id}');
        break;
      }
    }

    if (!emailExists) {
      print('Email does not exist for any user');
    }
  } catch (e) {
    print('Error checking email existence: $e');
  }
}

// Reads email of logged in user
Future<void> readEmailDB() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user signed in');
      return;
    }
    final userId = user.uid;

    final QuerySnapshot<Map<String, dynamic>> workoutsSnapshot =
        await FirebaseFirestore.instance
            .collection('workouts')
            .doc(userId)
            .collection('data')
            .get();

    // Loop through documents until there are no more documents left
    for (final workoutDoc in workoutsSnapshot.docs) {
      final email = workoutDoc.data()['email'] as String?;
      if (email != null) {
        print('Email retrieved successfully from database: $email');
      } else {
        print('Email field is null or empty for workout: ${workoutDoc.id}');
      }
    }
  } catch (e) {
    print('Error reading email: $e');
  }
}
