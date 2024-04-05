import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_app/login.dart';
import 'package:gym_app/main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swift',
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
  String? userEmail;

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

        // Start of etting user email to be displayed later
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        // Storing user email in a variable
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userEmail = userData['email'];

        // Getting workouts user has shared from user collection
        QuerySnapshot userWorkoutSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('shared_workouts')
            .get();

        List<String> usersEmails = []; // Storing users emails in list

        // Adding those email to the list
        usersEmails.addAll(List.filled(userWorkoutSnapshot.size, userEmail!));

        // Getting users friend IDs
        List<dynamic> friendIds =
            userData['friends'] ?? []; // Making sure not null
        print(friendIds); // Checking friends

        // Getting shared workouts from each of users friends
        for (var friendEmail in friendIds) {
          // Getting a user's shared workout then looping for each friend
          String? friendUserId = await getEmailAndID(friendEmail);
          if (friendUserId != null) {
            QuerySnapshot friendSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(friendUserId)
                .collection('shared_workouts')
                .get();

            // Adding friends email to the list for the workouts theyve shared
            usersEmails.addAll(List.filled(friendSnapshot.size, friendEmail));
          }
        }

        // All workout data stored in one map. Logged in user and friends
        List<List<Map<String, dynamic>>> allWorkoutsData = [];

        // Add users shared workouts
        for (var docIndex = 0;
            docIndex < userWorkoutSnapshot.docs.length;
            docIndex++) {
          var doc = userWorkoutSnapshot.docs[docIndex];
          var workoutData = doc.data() as Map<String, dynamic>;
          if (workoutData.containsKey('workoutDetails')) {
            List<Map<String, dynamic>> exercisesList =
                List<Map<String, dynamic>>.from(workoutData['workoutDetails']);
            // Adding the users email to their workouts to later be shared
            exercisesList.forEach((exercise) {
              exercise['usersEmailShared'] = usersEmails[docIndex];
            });
            allWorkoutsData.add(exercisesList);
          }
        }

        // Add shared workouts from friends
        for (var friendEmail in friendIds) {
          // Getting a user's shared workout then looping for each friend
          String? friendUserId = await getEmailAndID(friendEmail);
          if (friendUserId != null) {
            QuerySnapshot friendSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(friendUserId)
                .collection('shared_workouts')
                .get();

            for (var doc in friendSnapshot.docs) {
              var workoutData = doc.data() as Map<String, dynamic>;
              if (workoutData.containsKey('workoutDetails')) {
                List<Map<String, dynamic>> exercisesList =
                    List<Map<String, dynamic>>.from(
                        workoutData['workoutDetails']);
                // Associate each workout with the corresponding email
                exercisesList.forEach((exercise) {
                  exercise['usersEmailShared'] =
                      friendEmail; // Getting email of the user whos workout is shared
                });
                allWorkoutsData.add(exercisesList);
              }
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  // Add friends page
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddFriendsPage()),
                    );
                  },
                  child: Text("Add Friends"),
                ),
                ElevatedButton(
                  // Requests page (not yet implemented - currentnly log out page)
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyLoginPage(
                                title: 'Login',
                              )),
                    );
                  },
                  child: Text("Requests"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allWorkouts.length,
              itemBuilder: (context, index) {
                final workoutList = allWorkouts[index];
                // Displaying workouts of all shared workouts by user and their friends
                return Card(
                  margin: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical:
                          10), // Padding from side and above and below other workouts
                  color: Colours.mainBoxSimple,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Workout: ${workoutList.isNotEmpty ? workoutList[0]['usersEmailShared'] : 'User workout'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Displaying exercises
                      // ... is spread
                      ...workoutList.map((exercise) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Exercise: ${exercise['exercise']}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Reps: ${exercise['reps']}, Weight: ${exercise['weight']}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
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
              child: const Text('Add'),
            ),
            if (_emailExists) // Letting user know it was successful
              const Text(
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
