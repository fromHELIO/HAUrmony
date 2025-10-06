import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../widgets/app_drawer.dart';
import '../constants.dart';
import '../widgets/app_appbar.dart'; // ADDED

class TicketDetailsScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // attach the drawer to the end (right side)
      endDrawer: const AppDrawer(),
      appBar: appBarWithHamburger(context, showBack: true, openEndDrawer: true), // REPLACED AppBar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ticket Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Show this ticket upon entry.', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 18),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade100,
                        ),
                        child: const Center(child: Text('*EVENT BANNER*', style: TextStyle(fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(height: 12),
                      Text('Name', style: TextStyle(color: Colors.black54)),
                      Text(ticket.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Event', style: TextStyle(color: Colors.black54)),
                      Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Section', style: TextStyle(color: Colors.black54)),
                      Text(ticket.section, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Queue', style: TextStyle(color: Colors.black54)),
                      Text(ticket.queue, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Venue', style: TextStyle(color: Colors.black54)),
                      const Text('Holy Angel University', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Date & Time', style: TextStyle(color: Colors.black54)),
                      Text('${ticket.date}\n${ticket.time}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text('Event Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: const Text(
                          '- Don\'t forget to save or bring a copy of your e-ticket.\n- Bring your HAU ID when presenting your ticket. (For Angelites)',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}