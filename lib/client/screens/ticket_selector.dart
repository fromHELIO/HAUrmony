import 'package:flutter/material.dart';
import 'order_summary_screen.dart';

// example color — replace with your own constant if defined elsewhere
const Color ticketYellow = Color(0xFFFFC107);

class TicketSelector extends StatefulWidget {
  final String selectedZone; // zone the user picked
  final bool? checkAngelite;  // if true, first ticket = ₱20

  const TicketSelector({
    Key? key,
    required this.selectedZone,
    required this.checkAngelite,
  }) : super(key: key);

  @override
  State<TicketSelector> createState() => _TicketSelectorState();
}

class _TicketSelectorState extends State<TicketSelector> {
  int ticketCount = 0;
  bool isLoading = false;
  String? errorMessage;

  static const int maxTickets = 3;
  static const int regularPrice = 150;
  static const int angeliteDiscountPrice = 20;

  int get totalPrice {
    if (ticketCount == 0) return 0;
    if (widget.checkAngelite ?? false) {
      if (ticketCount == 1) return angeliteDiscountPrice;
      return angeliteDiscountPrice + (ticketCount - 1) * regularPrice;
    }
    return ticketCount * regularPrice;
  }

  void increment() {
    if (ticketCount < maxTickets) {
      setState(() {
        ticketCount++;
        errorMessage = null;
      });
    }
  }

  void decrement() {
    if (ticketCount > 0) {
      setState(() {
        ticketCount--;
        errorMessage = null;
      });
    }
  }

  void handleCheckout() async {
    if (ticketCount == 0) {
      setState(() => errorMessage = "Please select at least one ticket.");
      return;
    }

    setState(() => isLoading = true);

    // simulate loading
    await Future.delayed(const Duration(seconds: 1));

    // navigate to your order summary screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummaryScreen(
          zoneName: widget.selectedZone,
          quantity: ticketCount,
          totalPrice: totalPrice.toDouble(),
        ),
      ),
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedZone.isEmpty) {
      return const Text(
        "Please select a zone first.",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ticket counter UI
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: decrement,
              ),
              Text(
                '$ticketCount',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: increment,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Zone info and total
        Text(
          'Zone: ${widget.selectedZone}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          'Total: ₱${totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 16),

        // Checkout button
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ticketYellow,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                onPressed: isLoading ? null : handleCheckout,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'CHECK OUT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
