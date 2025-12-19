import 'package:flutter/material.dart';
import 'library_screen.dart' as backendlibrary;
import 'profile_screen.dart' as backendprofile;

class LibraryWrapper extends StatelessWidget {
  const LibraryWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const backendlibrary.LibraryScreen();
  }
}

class ProfileWrapper extends StatelessWidget {
  const ProfileWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const backendprofile.ProfileScreen();
  }
}