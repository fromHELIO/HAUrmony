import 'package:flutter/material.dart';

class AttendeesScreen extends StatelessWidget {
  final String zoneName;

  AttendeesScreen({required this.zoneName});

  // Sample attendee names 
  final List<String> attendees = [
    "Kim Mingyu",
    "Choi Seungcheol",
    "Jeon Wonwoo",
    "Yoon Jeonghan",
    "Xu Minghao",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$zoneName Attendees"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red.shade900,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: attendees.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.person, color: Colors.red.shade900),
            title: Text(attendees[index]),
          );
        },
      ),
    );
  }
}

