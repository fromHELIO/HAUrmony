import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_title.dart';
import '../models/ticket.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/ticket_repository.dart'; // added

const Color logoRed = Color(0xFFA32020);
const Color ticketYellow = Color(0xFFF4B942);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _loadPurchasedTickets() async {
    //necessary information
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final userInfo = await supabase
      .from('user_info')
      .select()
      .eq('user_id', user!.id)
      .single()
      ;
    
    List<Ticket> tickets = []; // list of tickets

    // get buy history
    final buyHistory = await supabase
      .from('sales')
      .select()
      .eq('buyer_id', userInfo['info_id'])
      ;

      // add past tickets to list
      for (int i = 0; i < buyHistory.length; i++) {

        final fetchZone = await supabase
        .from('tickets')
        .select('zone')
        .eq('ticket_id', buyHistory[i]['ticket_id'])
        .single()
        ;

        final Ticket ticket = Ticket(
        name: '${userInfo["first_name"]} ${userInfo["last_name"]}',
        section: 'ZONE ${fetchZone['zone']}',
        );

        tickets.add(ticket);
      }

      // add to ticket repo
      for (int i = 0; i < tickets.length; i++) {
        TicketRepository.instance.add(tickets[i]);
      }
  }

  @override
  Widget build(BuildContext context) {

    TicketRepository.instance.clear();
    _loadPurchasedTickets();

    return Scaffold(
      // put the drawer on the right and use the hamburger helper to open it
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        centerTitle: true, // center the title
        title: const AppTitle(), // uses global kLogoSize and kTitleFontSize
        actions: [
          // right side hamburger (three-line icon) that opens the endDrawer
          Builder(
            builder: (ctx) {
              return IconButton(
                icon: const Icon(Icons.menu),
                color: logoRed,
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                tooltip: 'Menu',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome to\nHAUrmony!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Secure your UDays concert ticket today.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "UDays Concert\n2026",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '"EVENT BANNER"',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'lib/assets/haurmony.png',
                          width: 56,
                          height: 56,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.confirmation_num, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoRed,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      shadowColor: logoRed.withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/zone_selection');
                    },
                    label: const Text(
                      'GET TICKET',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.event_available, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ticketYellow,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      shadowColor: ticketYellow.withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/my_tickets');
                    },
                    label: const Text(
                      'MY TICKETS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: logoRed, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "How to use your ticket?",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tap 'Get Ticket' to purchase. View your tickets in 'My Tickets'. Show your ticket QR code at the event entrance.",
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.contact_support, color: logoRed, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Need help?",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Contact support at haurmony@gmail.com.",
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
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
      ),
    );
  }
}