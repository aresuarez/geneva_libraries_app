import 'package:flutter/material.dart';
import 'package:geneva_libraries_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geneva Library Opening Hours',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(
        title: 'Geneva Library Opening Hours',
        libraryService: null, // Use default service
      ),
    );
  }
}

