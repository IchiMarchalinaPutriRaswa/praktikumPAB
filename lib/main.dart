import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const PreloWearApp());
}

class PreloWearApp extends StatelessWidget {
  const PreloWearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PreloWear',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF245C4A),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF245C4A),
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}
