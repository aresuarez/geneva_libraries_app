
import 'package:flutter/material.dart';
import 'package:geneva_libraries_app/screens/home_screen.dart';
import 'package:timezone/data/latest.dart' as tz;


void main() {
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geneva Library Hours',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(title: 'Geneva Library Hours'),
    );
  }
}

