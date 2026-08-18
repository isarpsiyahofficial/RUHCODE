import 'package:flutter/material.dart';

import '../ui/navigation/main_navigation_shell.dart';

class RuhCodeApp extends StatelessWidget {
  const RuhCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruh Code',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFBF8F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4C2A91),
          primary: const Color(0xFF4C2A91),
          secondary: const Color(0xFFC89338),
          surface: Colors.white,
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}
