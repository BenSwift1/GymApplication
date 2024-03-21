import 'package:flutter/material.dart';
import 'package:gym_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

class socialPageMain extends StatefulWidget {
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

  Future<void> getWorkoutData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        // When user clicks share workout that workout is got here
        QuerySnapshot workoutSnapshot = await FirebaseFirestore.instance
            .collection('workouts')
            .doc(userId)
            .collection('completed_workouts')
            .where('shared', isEqualTo: true)
            .get();

        if (workoutSnapshot.docs.isNotEmpty) {
          List<List<Map<String, dynamic>>> allWorkoutsData = [];

          for (var doc in workoutSnapshot.docs) {
            var workoutData = doc.data() as Map<String, dynamic>;
            if (workoutData.containsKey('exercises')) {
              List<Map<String, dynamic>> exercisesList =
                  List<Map<String, dynamic>>.from(workoutData['exercises']);
              allWorkoutsData.add(exercisesList);
            }
          }

          setState(() {
            allWorkouts = allWorkoutsData;
          });
        } else {
          print('No shared workouts found');
        }
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
                                physics: NeverScrollableScrollPhysics(),
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
              onPressed: () {},
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
