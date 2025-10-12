import 'package:flutter/material.dart';
import '../models/ticket.dart';
import 'order_success_screen.dart';
import '../widgets/app_drawer.dart'; // added to allow opening drawer
import '../constants.dart';

const Color ticketYellow = Color(0xFFF4B942);

class OrderSummaryScreen extends StatefulWidget {
  final int zoneAQty;
  final int zoneBQty;
  final int zoneCQty;

  const OrderSummaryScreen({
    super.key,
    required this.zoneAQty,
    required this.zoneBQty,
    required this.zoneCQty,
  });

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  int selectedPayment = 2; // 1 = card, 2 = e-wallet
  int get total => (widget.zoneAQty + widget.zoneBQty + widget.zoneCQty) * 300;

  String _computeSectionLabel() {
    final a = widget.zoneAQty > 0;
    final b = widget.zoneBQty > 0;
    final c = widget.zoneCQty > 0;
    if (a && !b && !c) return 'Zone A';
    if (!a && b && !c) return 'Zone B';
    if (!a && !b && c) return 'Zone C';
    return 'Mixed Zones';
  }

  String _sectionDetails() {
    final parts = <String>[];
    if (widget.zoneAQty > 0) parts.add('Zone A: ${widget.zoneAQty}');
    if (widget.zoneBQty > 0) parts.add('Zone B: ${widget.zoneBQty}');
    if (widget.zoneCQty > 0) parts.add('Zone C: ${widget.zoneCQty}');
    return parts.isEmpty ? 'No tickets' : parts.join('\n');
  }

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
                        if (widget.zoneAQty > 0) _zoneListTile('Zone A', widget.zoneAQty, widget.zoneAQty * 300),
                        if (widget.zoneBQty > 0) _zoneListTile('Zone B', widget.zoneBQty, widget.zoneBQty * 300),
                        if (widget.zoneCQty > 0) _zoneListTile('Zone C', widget.zoneCQty, widget.zoneCQty * 300),

                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Total displayed below the zone list inside the card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('₱ $total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      _paymentTile(Icons.money, 'Cash', 3),
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
                          content: Text('Confirm purchase of ₱ $total?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // close dialog

                                // build the Ticket from the current order data
                                final ticket = Ticket(
                                  title: 'HAU UDays Concert 2026',
                                  name: 'Buyer Name', // replace with real buyer info if available
                                  section: _sectionDetails(), // explicit per-zone quantities
                                  qty: widget.zoneAQty + widget.zoneBQty + widget.zoneCQty,
                                  queue: 'Queue Nos: TBD',
                                  date: 'Saturday, January 24, 2026',
                                  time: '3:00 PM to 10:00 PM',
                                );

                                // navigate to success screen with the constructed ticket
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => OrderSuccessScreen(ticket: ticket)),
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

  Widget _zoneListTile(String title, int qty, int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('qty: $qty', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₱ $price', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  // optional: show details for this zone or navigate to summary/my tickets
                  Navigator.pushNamed(context, '/my_tickets');
                },
                child: const Text('View Ticket', style: TextStyle(fontSize: 12)),
              ),
            ],
          )
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