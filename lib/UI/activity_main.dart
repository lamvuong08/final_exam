import 'package:flutter/material.dart';
import 'screens/library_screen.dart' as backendLibrary;
import 'screens/profile_screen.dart' as backendProfile;
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';

class LibraryWrapper extends StatelessWidget {
  const LibraryWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const backendLibrary.LibraryScreen();
  }
}

class ProfileWrapper extends StatelessWidget {
  const ProfileWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const backendProfile.ProfileScreen();
  }
}

class MainScreen extends StatefulWidget {
  final int userId; // userId từ login
  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userId: widget.userId), // Truyền userId vào HomeScreen
      const SearchScreen(),
      const LibraryWrapper(),
      const ProfileWrapper(),
    ];
  }

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
        type: BottomNavigationBarType.fixed,
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
