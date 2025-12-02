import 'package:flutter/material.dart';
import 'library_screen.dart' as backendLibrary;
import 'profile_screen.dart' as backendProfile;

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