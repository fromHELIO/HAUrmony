import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_repository.dart';
import 'my_tickets_screen.dart';
import '../widgets/app_drawer.dart'; // add drawer so hamburger can open it
import '../constants.dart';
import '../widgets/app_appbar.dart'; // ADDED

const Color ticketYellow = Color(0xFFF4B942);

class OrderSuccessScreen extends StatelessWidget {
  final Ticket ticket;
  const OrderSuccessScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // attach the drawer to the right so the hamburger opens it
      endDrawer: const AppDrawer(),
      appBar: appBarWithHamburger(context, showBack: true, openEndDrawer: true), // REPLACED AppBar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.topLeft,
                child: Text('Success!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.topLeft,
                child: Text('Your e-ticket is now available.', style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kLogoColor, width: 18),
                    ),
                    child: Center(child: Icon(Icons.check, color: kLogoColor, size: 80)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Thank you for your order.\nWe\'ve saved your spot, see you at the event!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ticketYellow,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 3,
                    shadowColor: ticketYellow.withOpacity(0.4),
                  ),
                  onPressed: () {
                    // add to repository (this will update MyTicketsScreen)
                    TicketRepository.instance.add(ticket);

                    // navigate to My Tickets (user will see the new ticket with correct qty)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
                    );
                  },
                  child: const Text(
                    'VIEW TICKET',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, letterSpacing: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

