import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDetailScreen extends StatefulWidget {
  final int infoId;

  const UserDetailScreen({super.key, required this.infoId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? userInfo;
  List<Map<String, dynamic>> userSales = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _subscribeToUserChanges();
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await supabase
          .from('user_info')
          .select()
          .eq('info_id', widget.infoId)
          .maybeSingle();

      final salesData = await supabase
          .from('sales')
          .select('sale_id, sale_price, timestamp, tickets!inner(zone, is_sold)')
          .eq('buyer_id', widget.infoId);

      if (!mounted) return;
      setState(() {
        userInfo = userData;
        userSales = List<Map<String, dynamic>>.from(salesData);
      });
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    }
  }

  void _subscribeToUserChanges() {
    final channel = supabase.channel('user_detail_${widget.infoId}');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'sales',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'buyer_id',
            value: widget.infoId.toString(),
          ),
          callback: (payload) {
            debugPrint('Realtime sales update for user ${widget.infoId}');
            _fetchUserData();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'user_info',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'info_id',
            value: widget.infoId.toString(),
          ),
          callback: (payload) {
            debugPrint('Realtime user info update for ${widget.infoId}');
            _fetchUserData();
          },
        )
        .subscribe();
  }

  Future<void> _deleteUser() async {
    try {
      await supabase.from('sales').delete().eq('buyer_id', widget.infoId);
      await supabase.from('user_info').delete().eq('info_id', widget.infoId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error deleting user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $e')),
      );
    }
  }

  @override
  void dispose() {
    supabase.removeAllChannels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userInfo == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: const Color(0xFF941E1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Name:',
                '${userInfo!['first_name']} ${userInfo!['last_name']}'),
            _infoRow('Contact:', userInfo!['contact'] ?? 'N/A'),
            _infoRow('Student Number:', userInfo!['student_number']),
            _infoRow('Angelite:', userInfo!['is_angelite'] ? 'Yes' : 'No'),
            const SizedBox(height: 24),
            const Text(
              'Transactions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: userSales.isEmpty
                  ? const Center(child: Text('No transactions found'))
                  : ListView.builder(
                      itemCount: userSales.length,
                      itemBuilder: (context, index) {
                        final sale = userSales[index];
                        final ticket = sale['tickets'];
                        final bool isSold = ticket?['is_sold'] ?? false;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              'Zone ${ticket?['zone']} - ₱${sale['sale_price'] ?? 0}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${sale['timestamp'].toString()}'),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${isSold ? 'Sold' : 'Available'}',
                                  style: TextStyle(
                                    color: isSold
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                  onPressed: _deleteUser,
                  child: const Text('Delete User'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE3A72F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature coming soon')),
                    );
                  },
                  child: const Text('View Transactions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
