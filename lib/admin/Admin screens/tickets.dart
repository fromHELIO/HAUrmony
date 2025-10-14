import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_header.dart';
import 'menu.dart';
import 'attendees.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final supabase = Supabase.instance.client;
  
  Map<String, int> soldTickets = {"ZONE A": 0, "ZONE B": 0, "ZONE C": 0};
  Map<String, bool> zoneClosed = {"ZONE A": false, "ZONE B": false, "ZONE C": false,};
  final int totalPerZone = 200;

  @override
  void initState() {
    super.initState();
    fetchTicketsData();
    subscribeToRealTime();
  }

  Future<void> fetchTicketsData() async {
    try {
      // Ignore yellow squiggles here...
      final a = await supabase.from('zone_a_queue').select() ?? [];
      final b = await supabase.from('zone_b_queue').select() ?? [];
      final c = await supabase.from('zone_c_queue').select() ?? [];

      if (!mounted) return;
      setState(() {
        soldTickets = {
          "ZONE A": a.length,
          "ZONE B": b.length,
          "ZONE C": c.length,
        };

        for (var zone in soldTickets.keys) {
          zoneClosed[zone] = soldTickets[zone]! >= totalPerZone;
        }
      });
    } catch (e) {
      debugPrint("Error Fetching Ticket Data: $e");
    }
  }

  void subscribeToRealTime() {
    for (var zone in ['zone_a_queue', 'zone_b_queue', 'zone_c_queue']) {
      supabase
        .channel(zone)
        .onPostgresChanges(
          event: PostgresChangeEvent.all, 
          schema: 'public',
          table: zone,
          callback: (payload) {
            fetchTicketsData();
          },
        ).subscribe();
    }
  }

  void closeZone(String zoneName) {
    setState(() {
      zoneClosed[zoneName] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$zoneName has been closed.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zones = ["ZONE A", "ZONE B", "ZONE C"];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: "Tickets", 
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),

      drawer: MenuScreen(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchTicketsData,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: zones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final name = zones[i];
                final sold = soldTickets[name] ?? 0;
                final percent = (sold / totalPerZone * 100).clamp(0, 100).round();
                final isFull = sold >= totalPerZone;
                final isClosed = zoneClosed[name] ?? false;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name, 
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        "$sold / $totalPerZone sold",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: sold / totalPerZone,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF8B1A1A)),
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

                      const SizedBox(height: 12),

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
                                    builder: (_) => AttendeesScreen(zoneName: name),
                                  ),
                                );
                              },
                              
                              child: const Text("View Attendees"),
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: 
                                  isClosed || isFull ? Colors.grey : Colors.black,
                                side: BorderSide(
                                  color: isClosed || isFull ? Colors.grey : Colors.black,
                                ),
                              ),

                              onPressed: (isClosed || isFull)
                                ? null
                                : () {
                                  closeZone(name);
                                },

                              child: Text(
                                isFull
                                  ? "Zone Full"
                                  : isClosed
                                    ? "Closed"
                                    : "Close Zone",
                                style: const TextStyle(fontWeight: FontWeight.w600),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    supabase.removeAllChannels();
    super.dispose();
  }
}
