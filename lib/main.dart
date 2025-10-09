import 'package:flutter/material.dart';
import 'client/screens/launcher_screen.dart';
import 'auth/login_screen.dart';
import 'client/screens/signup_choice_screen.dart';
import 'client/screens/signup_angelite_screen.dart';
import 'client/screens/signup_non_angelite_screen.dart';
import 'client/screens/forgot_password_screen.dart';
import 'client/screens/home_screen.dart';
import 'client/screens/zone_selection_screen.dart';
import 'client/screens/my_tickets_screen.dart';
import 'client/screens/profile_screen.dart';
import 'admin/Admin screens/dashboard.dart';
import 'admin/Admin screens/tickets.dart';
import 'admin/Admin screens/users.dart';
import 'admin/Admin screens/reports.dart';
import 'admin/Admin screens/menu.dart';

void main() {
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
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        // Client-side routes
        '/': (context) => LauncherScreen(),
        '/login': (context) => LoginScreen(),
        '/signup_choice': (context) => SignupChoiceScreen(),
        '/signup_angelite': (context) => SignupAngeliteScreen(),
        '/signup_non_angelite': (context) => SignupNonAngeliteScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/home_screen': (context) => HomeScreen(),
        '/zone_selection': (context) => ZoneSelectionScreen(),
        '/my_tickets': (context) => MyTicketsScreen(),
        '/profile': (context) => const ProfileScreen(),

        // Admin-side routes
        '/admin': (context) => const AdminMainPage(),
      },
    );
  }
}

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  _AdminMainPageState createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    TicketsScreen(),
    UsersScreen(),
    ReportsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuScreen(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
        ],
      ),
    );
  }
}