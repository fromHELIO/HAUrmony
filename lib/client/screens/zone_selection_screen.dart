import 'package:flutter/material.dart';
import 'order_summary_screen.dart';
import '../widgets/app_drawer.dart'; // added to allow hamburger opening end drawer
import '../constants.dart';
import '../widgets/app_appbar.dart'; // ADDED
import 'ticket_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color ticketYellow = Color(0xFFF4B942);

class ZoneSelectionScreen extends StatefulWidget {
  const ZoneSelectionScreen({super.key});

  @override
  State<ZoneSelectionScreen> createState() => _ZoneSelectionScreenState();
}

class _ZoneSelectionScreenState extends State<ZoneSelectionScreen> {
  int zoneA = 0;
  int zoneB = 0;
  int zoneC = 0;

  final int price = 300;

  bool isLoading = false;
  String? errorMessage;
  String selectedZone = 'ZONE A';

  int get total => (zoneA + zoneB + zoneC) * price;

  final supabase = Supabase.instance.client;

  Future<bool> getAngelite() async {
    final user = supabase.auth.currentUser;
    final response = await supabase
    .from('user_info')
    .select()
    .eq('user_id', user!.id)
    .single();

    final bool? isAnge = response['is_angelite'] as bool?;

    if (isAnge ?? false) {
      return true;
    } else {
      return false;
    }
    
  }
  
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: getAngelite(),
      builder: (context, asyncSnapshot) {
        return Scaffold(
          // attach drawer to the right so hamburger opens it
          endDrawer: const AppDrawer(),
          appBar: appBarWithHamburger(context, showBack: true, openEndDrawer: true), // REPLACED AppBar
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select your zone!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Choose where you'd like to enjoy the concert.", style: TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          _zoneTopCard('ZONE A'),
                          _verticalDivider(),
                          _zoneTopCard('ZONE B'),
                          _verticalDivider(),
                          _zoneTopCard('ZONE C'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 16),
        
                  Center(
                    child: TicketSelector(
                      selectedZone: selectedZone,
                      checkAngelite: asyncSnapshot.data,
                    ),
                  ),
        
                  // _zoneSelector('Zone A', zoneA, (v) => setState(() => zoneA = v)),
                  // const SizedBox(height: 8),
                  // _zoneSelector('Zone B', zoneB, (v) => setState(() => zoneB = v)),
                  // const SizedBox(height: 8),
                  // _zoneSelector('Zone C', zoneC, (v) => setState(() => zoneC = v)),
        
                  const SizedBox(height: 24),
                  // Row(children: [
                  //   Expanded(
                  //     child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: ticketYellow,
                  //         padding: const EdgeInsets.symmetric(vertical: 16),
                  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  //         elevation: 4,
                  //       ),
                  //       onPressed: isLoading
                  //           ? null
                  //           : () {
                  //               if (zoneA + zoneB + zoneC == 0) {
                  //                 setState(() => errorMessage = "Please select at least one ticket.");
                  //                 return;
                  //               }
                  //               // navigate to the separate OrderSummaryScreen file and pass quantities
                  //               Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                   builder: (context) => OrderSummaryScreen(
                  //                     zoneAQty: zoneA,
                  //                     zoneBQty: zoneB,
                  //                     zoneCQty: zoneC,
                  //                   ),
                  //                 ),
                  //               );
                  //             },
                  //       child: isLoading
                  //           ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  //           : const Text('CHECK OUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2, color: Colors.white)),
                  //     ),
                  //   ),
                  // ]),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(children: [
                        const Icon(Icons.info_outline, color: kLogoColor, size: 32),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                          Text("Zone Info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text("Zone A is closest to the stage. Zone B is middle. Zone C is farthest. All zones are ₱300 per ticket. Angelites will have their first ticket discounted to ₱20", style: TextStyle(fontSize: 13, color: Colors.black87)),
                        ])),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _verticalDivider() => Container(width: 2, height: 120, color: Colors.grey.shade300);

  Widget _zoneTopCard(String label) {
    final isSelected = selectedZone == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedZone = label),
        child: Container(
          height: 200,
          alignment: Alignment.center,
          color: isSelected ? Colors.grey.shade200 : Colors.transparent,
          child: RotatedBox(quarterTurns: 3, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, letterSpacing: 4, color: isSelected ? kLogoColor : Colors.black))),
        ),
      ),
    );
  }

//   Widget _zoneSelector(String zone, int value, ValueChanged<int> onChanged) {
//     return Row(children: [
//       const Text("₱ 300", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//       const SizedBox(width: 12),
//       Container(decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(8)), child: Row(children: [
//         IconButton(icon: const Icon(Icons.remove), onPressed: value > 0 ? () => onChanged(value - 1) : null),
//         Text("$value", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         IconButton(icon: const Icon(Icons.add), onPressed: () => onChanged(value + 1)),
//       ])),
//     ]);
//   }
// }





}