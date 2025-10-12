import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_repository.dart';
import 'ticket_details_screen.dart';
import '../widgets/app_drawer.dart'; // added so we can open the end drawer
import '../constants.dart';
import '../widgets/app_appbar.dart'; // ADDED

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // attach drawer to the right so the hamburger opens it
      endDrawer: const AppDrawer(),
      appBar: appBarWithHamburger(context, showBack: true, openEndDrawer: true), // REPLACED AppBar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("My Tickets", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("View and download your tickets anytime.", style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 24),
              Expanded(
                child: ValueListenableBuilder<List<Ticket>>(
                  valueListenable: TicketRepository.instance.ticketsNotifier,
                  builder: (context, tickets, _) {
                    if (tickets.isEmpty) {
                      return const Center(child: Text("No tickets yet. Tap + to add."));
                    }
                    return ListView.separated(
                      itemCount: tickets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final t = tickets[index];
                        return _ticketCard(context, t);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketCard(BuildContext context, Ticket t) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),

                // Show section lines (each zone on its own line)
                Text(
                  t.section,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 6),

                // Show total quantity on its own line (below the zones)
                Text(
                  'Total Tickets: ${t.qty}',
                  style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 6),

                // Queue on its own line
                Text(
                  t.queue,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ]),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TicketDetailsScreen(ticket: t)),
                    );
                  },
                  child: const Text("View Details", style: TextStyle(fontSize: 12)),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Download PDF
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF Downloaded')),
                    );
                  },
                  child: const Text("Download PDF", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}