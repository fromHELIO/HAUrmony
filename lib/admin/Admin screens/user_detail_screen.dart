import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import 'menu.dart';

class UserDetailScreen extends StatelessWidget {
  final String name;

  const UserDetailScreen({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: "User Detail",
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: MenuScreen(),
      body: SafeArea(
        child: Center(
          child: Text(
            "Details for $name",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}


