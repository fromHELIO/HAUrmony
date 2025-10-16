import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket.dart';
import 'order_success_screen.dart';
import '../widgets/app_drawer.dart'; // added to allow opening drawer
import '../constants.dart';

const Color ticketYellow = Color(0xFFF4B942);

class OrderSummaryScreen extends StatefulWidget {

  final String zoneName;
  final int quantity;
  final double totalPrice;

  const OrderSummaryScreen({
    super.key,
    required this.zoneName,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  int selectedPayment = 2; // 1 = card, 2 = e-wallet

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // attach drawer to the right so hamburger opens it
      endDrawer: const AppDrawer(),

      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false, // provide custom leading so we can color it
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: kLogoColor, // make the back arrow red using global constant
          onPressed: () => Navigator.pop(context),
        ),
        // centered HAUrmony icon + text (use global sizes)
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('lib/assets/haurmony.png', width: kLogoSize, height: kLogoSize),
            const SizedBox(width: 8),
            Text(
              'HAUrmony',
              style: TextStyle(color: kLogoColor, fontWeight: FontWeight.bold, fontSize: kTitleFontSize),
            ),
          ],
        ),

        // right-side hamburger to open endDrawer
        actions: [
          Builder(
            builder: (ctx) {
              return IconButton(
                icon: const Icon(Icons.menu), // proper hamburger icon
                color: kLogoColor,
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Review your tickets before checkout.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 18),

                // Card with zone items and total placed directly below zone list
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        _zoneListTile(widget.zoneName, widget.quantity, widget.totalPrice),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Total displayed below the zone list inside the card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('₱ ${widget.totalPrice}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Payment Methods', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      _paymentTile(Icons.credit_card, 'Credit / Debit Card', 1),
                      const Divider(height: 0),
                      _paymentTile(Icons.account_balance_wallet, 'E - Wallet', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                const Divider(thickness: 1),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kLogoColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Place Order'),
                          content: Text('Confirm purchase of ₱ ${widget.totalPrice}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () async {

                                // necessary constants
                                final supabase = Supabase.instance.client;
                                final user = supabase.auth.currentUser;
                                final userInfo = await supabase
                                .from('user_info')
                                .select()
                                .eq('user_id', user!.id)
                                .single();

                                List<Ticket> tickets = []; // list of tickets

                                // add newly purchased tickets to tickets[] and add them to queue
                                for (int i = 0; i < widget.quantity; i++)
                                {
                                final fetchTix = await supabase
                                .from('tickets')
                                .select()
                                .eq('zone', widget.zoneName.substring(5).toUpperCase())
                                .eq('is_sold', false)
                                .order('ticket_id', ascending: true)
                                .limit(1)
                                .single()
                                ;

                                await supabase
                                .from('sales')
                                .insert({
                                  'ticket_id': fetchTix['ticket_id'],
                                  'buyer_id': userInfo['info_id'],
                                  'sale_price': widget.totalPrice,
                                })
                                ;

                                final saleID = await supabase
                                .from('sales')
                                .select('sale_id')
                                .eq('ticket_id', fetchTix['ticket_id'])
                                .single()
                                ;

                                final zoneQueue = 'zone_${(widget.zoneName).substring(5).toLowerCase()}_queue';

                                await supabase
                                .from(zoneQueue)
                                .insert({
                                  'sale_id': saleID['sale_id'],
                                })
                                ;

                                await supabase
                                .from('tickets')
                                .update({'is_sold': true})
                                .eq('ticket_id', fetchTix['ticket_id'])
                                ;
                                

                                final Ticket ticket = Ticket(
                                  name: '${userInfo["first_name"]} ${userInfo["last_name"]}',
                                  section: widget.zoneName,
                                );

                                tickets.add(ticket);

                                }



                                // navigate to success screen with the constructed ticket
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => OrderSuccessScreen(tickets: tickets)),
                                );
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('PLACE ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _zoneListTile(String title, int qty, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 4),
              Text('qty: $qty', style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(IconData icon, String label, int value) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.grey.shade100),
        child: Icon(icon, color: Colors.black54, size: 20),
      ),
      title: Text(label),
      trailing: Radio<int>(
        value: value,
        groupValue: selectedPayment,
        onChanged: (v) => setState(() => selectedPayment = v ?? selectedPayment),
      ),
      onTap: () => setState(() => selectedPayment = value),
    );
  }
}