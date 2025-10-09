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
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qfgdezwllzrtxbilnrqh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFmZ2RlendsbHpydHhiaWxucnFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5ODkzNjQsImV4cCI6MjA3NTU2NTM2NH0.iDmZeNR7JkXlj4qEYKvUmyJtK21fdxjZ2ch7skXrtKQ',
  );
  runApp(const HAUrmonyApp());
}

class HAUrmonyApp extends StatelessWidget {
  const HAUrmonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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