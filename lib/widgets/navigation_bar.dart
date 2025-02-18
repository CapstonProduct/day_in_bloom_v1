import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavigationBar({super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Screen 1'),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Screen 2'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Screen 3'),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }
}
