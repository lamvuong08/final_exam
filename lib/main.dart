import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'UI/activity_login_options.dart';
import 'UI/controllers/library_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LibraryController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng Nhạc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginOptionsScreen(),
    );
  }
}
