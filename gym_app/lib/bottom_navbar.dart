import 'package:flutter/material.dart';

class CommonBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onItemSelected;

  const CommonBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromRGBO(25, 130, 196, 1),
      elevation: 0,
      currentIndex: currentIndex,
      onTap: onItemSelected,
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
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Progress',
        ),
      ],
    );
  }
}
