import 'package:flutter/material.dart';
import 'settings.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: const Color(0xFF941E1E)),
            accountName: Text("Admin"),
            accountEmail: Text("user@school.edu.ph"),
            currentAccountPicture:
                CircleAvatar(child: Icon(Icons.person, size: 40)),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Log Out"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Logged out successfully")),
              );
            },
          ),
        ],
      ),
    );
  }
}
