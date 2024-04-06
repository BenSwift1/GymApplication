import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class userSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                changingColourScheme(context, {
                  'head': 0xFFE66E5E,
                  'mainBox': 0xFF4DD9EB,
                  'otherBox': 0xFF2DC8DD,
                  'nav': 0xFFFCCBC4,
                  'background': 0xFFF8F4E5,
                });
              },
              child: Text('Simple colours'),
            ),
            ElevatedButton(
              onPressed: () {
                changingColourScheme(context, {
                  'head': 0xFFCF4917,
                  'mainBox': 0xFFF9AC3D,
                  'otherBox': 0xFF2D758C,
                  'nav': 0xFF758C33,
                  'background': 0xFFFFEAC9,
                });
              },
              child: Text('Bold colours'),
            ),
            ElevatedButton(
              onPressed: () {
                changingColourScheme(context, {
                  'head': 0xFFE66E5E,
                  'mainBox': 0xFF4DD9EB,
                  'otherBox': 0xFF2DC8DD,
                  'nav': 0xFFFCCBC4,
                  'background': 0xFFF8F4E5,
                });
              },
              child: Text('3'),
            ),
            ElevatedButton(
              onPressed: () {
                changingColourScheme(context, {
                  'head': 0xFFE66E5E,
                  'mainBox': 0xFF4DD9EB,
                  'otherBox': 0xFF2DC8DD,
                  'nav': 0xFFFCCBC4,
                  'background': 0xFFF8F4E5,
                });
              },
              child: Text('4'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> changingColourScheme(
      BuildContext context, Map<String, int> colourNum) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // If user logged in
        String userId = user.uid;
        // Storing the new colour scheme in users collection
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);
        await userRef.set({'colourScheme': colourNum},
            SetOptions(merge: true)); // Setting colour schemes in db
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: userSettingsPage(),
  ));
}
