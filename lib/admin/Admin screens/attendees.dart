import 'package:flutter/material.dart';
import 'user_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendeesScreen extends StatefulWidget {

  final String? initialZone;
  const AttendeesScreen({super.key, this.initialZone});

  @override
  State<AttendeesScreen> createState() => _AttendeesScreenState();
  
}

class _AttendeesScreenState extends State<AttendeesScreen> {
  final supabase = Supabase.instance.client;
  late String selectedZone;
  List<Map<String, dynamic>> attendees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedZone = widget.initialZone ?? 'A';
    fetchAttendees();
  }

  Future<void> fetchAttendees() async {
    setState(() => isLoading = true);

    try {
      final tableName = 'zone_${selectedZone.toLowerCase()}_queue';

      final data = await supabase
      .from(tableName)
      .select('queue_num, sales(sale_id, buyer_id, user_info(first_name, last_name))');

      setState(() {
        attendees = (data as List)
            .map((item) => {
                'queue_num': item['queue_num'],
                'first_name': item['sales']['user_info']['first_name'],
                'last_name': item['sales']['user_info']['last_name'],
                'buyer_id': item['sales']['buyer_id'],
            })
          .toList();
      });
    } catch (e) {
      debugPrint('Error Fetching Attendees: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void navigateToUserDetail(Map<String, dynamic> attendee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserDetailScreen(infoId: attendee['buyer_id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Zone $selectedZone Attendees"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.red.shade900,
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12, top: 5, bottom: 5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedZone,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      dropdownColor: Colors.white,
                      alignment: Alignment.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      items: ['A', 'B', 'C']
                          .map((zone) => DropdownMenuItem<String>(
                                value: zone,
                                child: Text('Zone $zone'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedZone = value);
                          fetchAttendees();
                        }
                      },
                      selectedItemBuilder: (context) {
                        return ['A', 'B', 'C'].map((zone) {
                          return Center(
                            child: Text(
                              'Zone $zone',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : attendees.isEmpty
                  ? const Center(child: Text('No Attendees found.'))
                  : ListView.builder(
                    itemCount: attendees.length,
                    itemBuilder: (context, index) {
                      final attendee = attendees[index];
                      return ListTile(
                        leading: Icon(Icons.person, color: Colors.red.shade900),
                        title: Text("${attendee['first_name']} ${attendee['last_name']}"),
                        subtitle: Text("Queue #${attendee['queue_num']}"),
                        onTap: () => navigateToUserDetail(attendee),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}