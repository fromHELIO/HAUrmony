import 'package:flutter/material.dart';
import 'screens/launcher_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_choice_screen.dart';
import 'screens/signup_angelite_screen.dart';
import 'screens/signup_non_angelite_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/zone_selection_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/profile_screen.dart';
void main() {
  runApp(const HAUrmonyApp());
}

class HAUrmonyApp extends StatelessWidget {
  const HAUrmonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HAUrmony',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LauncherScreen(),
        '/login': (context) => LoginScreen(),
        '/signup_choice': (context) => SignupChoiceScreen(),
        '/signup_angelite': (context) => SignupAngeliteScreen(),
        '/signup_non_angelite': (context) => SignupNonAngeliteScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/home_screen': (context) => HomeScreen(),
        '/zone_selection': (context) => ZoneSelectionScreen(),
        '/my_tickets': (context) => MyTicketsScreen(),
        '/profile': (c) => const ProfileScreen(),
      },
    );
  }
}