import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import 'menu.dart';
import 'attendees.dart';

class TicketsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> zones = const [
    {"name": "ZONE A", "sold": 180, "total": 200},
    {"name": "ZONE B", "sold": 180, "total": 200},
    {"name": "ZONE C", "sold": 180, "total": 200},
  ];

  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: "Tickets",
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: MenuScreen(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: zones.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            final zone = zones[i];
            final sold = zone['sold'] as int;
            final total = zone['total'] as int;
            final percent = (sold / total * 100).round();

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zone name and sold numbers
                  Text(
                    "${zone['name']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "$sold/$total sold",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),

                  // Progress bar + percentage
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: sold / total,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              const AlwaysStoppedAnimation(Color(0xFF8B1A1A)),
                          minHeight: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$percent%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AttendeesScreen(zoneName: zone['name']),
                              ),
                            );
                          },
                          child: const Text(
                            "View Attendees",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("${zone['name']} closed successfully"),
                              ),
                            );
                          },
                          child: const Text(
                            "Close Zone",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
