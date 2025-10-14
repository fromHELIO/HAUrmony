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
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); //ADDED

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qfgdezwllzrtxbilnrqh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFmZ2RlendsbHpydHhiaWxucnFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5ODkzNjQsImV4cCI6MjA3NTU2NTM2NH0.iDmZeNR7JkXlj4qEYKvUmyJtK21fdxjZ2ch7skXrtKQ',
  );

  final supabase = Supabase.instance.client; //ADDED

  // Email Redirection Handling
  final uri = Uri.base;
  if (uri.scheme == 'io.supabase.haurmony' && uri.host == 'login-callback') {
    try {
      await supabase.auth.exchangeCodeForSession(uri.toString());
      debugPrint('Session restored from verification email.');
    } catch (e, st) {
      debugPrint('Failed to restore session: $e\n$st');
    }
  } //ADDED

  // Listening for Authentication State Changes
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;
    final session = data.session;

    if (event == AuthChangeEvent.signedIn && session != null) {
      final supabase = Supabase.instance.client;
      final userId = session.user.id;

      final userInfo = await supabase
      .from('user_info')
      .select('is_admin')
      .eq('user_id', userId)
      .maybeSingle();

      final isAdmin = userInfo?['is_admin'] == true;

      debugPrint('User ${session.user.email} verified and signed in. Admin: $isAdmin');

      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        isAdmin ? '/admin' : '/home_screen',
        (route) => false,
      );
    } else if (event == AuthChangeEvent.signedOut) {
      debugPrint('User signed out.');
    }
  }); //ADDED
  
  runApp(const HAUrmonyApp());
}

class HAUrmonyApp extends StatelessWidget {
  const HAUrmonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, //ADDED
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
  State<AdminMainPage> createState() => _AdminMainPageState(); //MODIFIED
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
