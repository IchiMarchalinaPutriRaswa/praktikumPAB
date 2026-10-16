import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'pages/app_shell.dart';

void main() => runApp(const PreloWearApp());

class PreloWearApp extends StatelessWidget {
  const PreloWearApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PreloWear',
    debugShowCheckedModeBanner: false,
    theme: buildPreloTheme(),
    home: const PreloWearShell(),
  );
}
