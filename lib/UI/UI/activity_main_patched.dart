import 'package:flutter/material.dart';
import '../activity_main.dart';
import '../screens/screen_wrapper.dart';

class MainScreenPatched extends StatefulWidget {
  const MainScreenPatched({super.key});

  @override
  State<MainScreenPatched> createState() => _MainScreenPatchedState();
}

class _MainScreenPatchedState extends State<MainScreenPatched> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryWrapper(),   // ⭐ thay bằng bản có backend
    const ProfileWrapper(),   // ⭐ thay bằng bản có backend
  ];

  final List<String> _titles = [
    'Music Player',
    'Music Player',
    'Library',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF808080),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}