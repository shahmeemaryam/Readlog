import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ReadLogApp());
}

class ReadLogApp extends StatelessWidget {
  const ReadLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4F8F5B);
    const creamBackground = Color(0xFFFFF8E7);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReadLog',

      // Light theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryGreen,
          secondary: primaryGreen,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: creamBackground,
        useMaterial3: true,
      ),

      // Dark theme
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF78B982),
          secondary: const Color(0xFF78B982),
          surface: const Color(0xFF202A22),
        ),
        scaffoldBackgroundColor: const Color(0xFF141B16),
        useMaterial3: true,
      ),

      // Automatically follows the device's light/dark mode
      themeMode: ThemeMode.system,

      home: const LoginScreen(),
    );
  }
}