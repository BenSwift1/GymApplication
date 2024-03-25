import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_app/main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: socialPageMain(),
    );
  }
}

class socialPageMain extends StatefulWidget {
  // Called this because it replaces socialPage which wasnt working correctly
  @override
  _socialPageMainState createState() => _socialPageMainState();
}

class _socialPageMainState extends State<socialPageMain> {
  List<List<Map<String, dynamic>>> allWorkouts = [];

  @override
  void initState() {
    super.initState();
    getWorkoutData();
  }

  // Getting users friends email to then get their ID
  Future<String?> getEmailAndID(String email) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id; // Returning doc ID
      }
    } catch (e) {
      print("Error getting user ID by email: $e");
    }
    return null;
  }

  // Getting both user and users friends workouts, to be displayed on social page later
  Future<void> getWorkoutData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        // Getting workouts user has shared from user collection
        QuerySnapshot userWorkoutSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('shared_workouts')
            .get();

        // Getting users friend IDs
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        List<dynamic> friendIds =
            userData['friends'] ?? []; // Kaing sure not null
        print(friendIds); // Checking friends
        List<QuerySnapshot> friendWorkoutSnapshots = [];

        // Getting shared workouts from each of users friends
        for (var friendEmail in friendIds) {
          // Getting a users shared workout then looping for each friend
          String? friendUserId = await getEmailAndID(friendEmail);
          if (friendUserId != null) {
            QuerySnapshot friendSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(friendUserId)
                .collection('shared_workouts')
                .get();
            friendWorkoutSnapshots.add(friendSnapshot);
          }
        }

        // All workout data stored in one map. Logged in user and friends
        List<List<Map<String, dynamic>>> allWorkoutsData = [];

        // Add users shared workouts
        for (var doc in userWorkoutSnapshot.docs) {
          var workoutData = doc.data() as Map<String, dynamic>;
          if (workoutData.containsKey('workoutDetails')) {
            List<Map<String, dynamic>> exercisesList =
                List<Map<String, dynamic>>.from(workoutData['workoutDetails']);
            allWorkoutsData.add(exercisesList);
          }
        }

        // Add shared workouts from friends
        for (var snapshot in friendWorkoutSnapshots) {
          for (var doc in snapshot.docs) {
            var workoutData = doc.data() as Map<String, dynamic>;
            if (workoutData.containsKey('workoutDetails')) {
              List<Map<String, dynamic>> exercisesList =
                  List<Map<String, dynamic>>.from(
                      workoutData['workoutDetails']);
              allWorkoutsData.add(
                  exercisesList); // Adding friends workouts to allWorkoutData
            }
          }
        }

        setState(() {
          allWorkouts = allWorkoutsData;
        });
      }
    } catch (e) {
      print('Error reading exercise data from database: $e');
    }
  }

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddFriendsPage()),
                    );
                  },
                  child: Text("Add Friends"),
                ),
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
          ),
          Expanded(
            child: allWorkouts.isNotEmpty
                ? ListView.builder(
                    itemCount: allWorkouts.length,
                    itemBuilder: (context, index) {
                      final workoutBox = allWorkouts[index];
                      return Card(
                        color: Colours.mainBoxSimple,
                        elevation: 8,
                        margin: EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Workout ${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: workoutBox.length,
                                itemBuilder: (context, idx) {
                                  final details = workoutBox[idx];
                                  return Text(
                                    'Exercise: ${details['exercise']}\nReps: ${details['reps']}, Weight: ${details['weight']}\n',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'No workouts to display',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class AddFriendsPage extends StatefulWidget {
  @override
  _AddFriendsPageState createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  TextEditingController _emailController = TextEditingController();
  bool _emailExists = false;

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
              controller: _emailController,
              decoration:
                  InputDecoration(labelText: 'Enter friend\'s email...'),
            ),
            ElevatedButton(
              onPressed: () async {
                String email =
                    _emailController.text.trim(); // Getting email user entered
                bool exists =
                    await checkIfEmailExists(email); // Checking that email
                addFriend(
                    email); // If exists adding that email to list of friends
                setState(() {
                  _emailExists = exists;
                });
              },
              child: Text('Add'),
            ),
            if (_emailExists)
              Text(
                'Friend added',
                style:
                    TextStyle(color: const Color.fromARGB(255, 76, 116, 175)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

Future<bool> checkIfEmailExists(String email) async {
  try {
    // Looking for matching email
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1) // Stopping once found
        .get();

    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    // Handle any errors
    print('Error checking email existence: $e');
    return false;
  }
}

Future<void> addFriend(String email) async {
  try {
    // Checking email exists before adding friend
    bool emailExists = await checkIfEmailExists(email);

    if (emailExists) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('No user signed in');
        return;
      }

      final currentUserDocRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      // Adding email to list of friends
      await currentUserDocRef.update({
        'friends': FieldValue.arrayUnion([email])
      });

      // Updating database
      final friendDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      final friendDocRef = friendDocSnapshot.docs.first.reference;
      await friendDocRef.update({
        'friends': FieldValue.arrayUnion([currentUser.email])
      });

      print('Friend added successfully');
    } else {
      print('This user doesnt exist');
    }
  } catch (e) {
    print('Error adding friend: $e');
  }
}

class RequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
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
