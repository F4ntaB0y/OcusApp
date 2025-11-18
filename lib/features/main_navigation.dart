import 'package:flutter/material.dart';
import 'timer/timer_page.dart';
import 'tasks/tasks_page.dart';
import 'calendar/calendar_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // PERBAIKAN: List itu sendiri adalah const, jadi hapus 'const' dari tiap elemen.
  final List<Widget> _pages = const <Widget>[
    TimerPage(), // Hapus const
    CalendarPage(), // Hapus const
    TasksPage(), // Hapus const
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF00FF00);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tugas'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: activeColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
