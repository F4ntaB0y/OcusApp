import 'package:flutter/material.dart';
import 'features/timer/timer_page.dart';
import 'features/tasks/tasks_page.dart';
// Mengimpor file kalender yang sekarang berisi kelas StatisticsPage
import 'features/calendar/calendar_page.dart';
import 'core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key}); // PERBAIKAN: Tambahkan super.key

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    TimerPage(),
    StatisticsPage(), // Mengakses kelas StatisticsPage
    TasksPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.background,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tugas'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade700,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
