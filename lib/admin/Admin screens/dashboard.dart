import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_header.dart';
import 'menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;

  int ticketsSoldToday = 0;
  double totalRevenue = 0.0;
  int zoneASold = 0;
  int zoneBSold = 0;
  int zoneCSold = 0;

  final int zoneCapacity = 100;
  final int totalCapacity = 300;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _subscribeToRealTimeUpdates();
  }

  Future<void> _fetchDashboardData() async {
    try {
      // Total Tickets Sold
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final salesToday = await supabase
        .from('sales')
        .select('sale_id')
        .gte('timestamp', startOfDay.toIso8601String())
        .lt('timestamp', endOfDay.toIso8601String());

      final revenueData = await supabase
        .from('sales')
        .select('sale_price')
        .not('sale_price', 'is', null);

      final totalRevenueValue = revenueData.fold<double>(
        0.0, 
        (sum, row) => sum + ((row['sale_price'] ?? 0) as num).toDouble()
      );

      // Zone Count
      final zoneAData = await supabase.from('zone_a_queue').select('queue_num');
      final zoneBData = await supabase.from('zone_b_queue').select('queue_num');
      final zoneCData = await supabase.from('zone_c_queue').select('queue_num');

      if (!mounted) return;

      setState(() {
        ticketsSoldToday = salesToday.length;
        totalRevenue = totalRevenueValue;
        zoneASold = zoneAData.length;
        zoneBSold = zoneBData.length;
        zoneCSold= zoneCData.length;
      });
    } catch (e) {
      debugPrint('Error Fetching Dashboard Data: $e');
    }
  }

  void _subscribeToRealTimeUpdates() {
    final tables = ['sales', 'zone_a_queue', 'zone_b_queue', 'zone_c_queue'];

    for (final table in tables) {
      supabase.channel(table).onPostgresChanges(
        event: PostgresChangeEvent.all, 
        schema: 'public',
        table: table,
        callback: (payload) {
          debugPrint('Realtime update from $table: ${payload.eventType}');
          _fetchDashboardData();
        },
      ).subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double zoneAPercent = zoneASold / zoneCapacity;
    final double zoneBPercent = zoneBSold / zoneCapacity;
    final double zoneCPercent = zoneCSold / zoneCapacity;
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppHeader(
          title: "Dashboard", 
          onMenuTap: () => Scaffold.of(context).openDrawer(),
        ),
        drawer: MenuScreen(),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          title: "Tickets Sold Today",
                          value: "$ticketsSoldToday / $totalCapacity",
                          color: const Color(0xFFE09B1E),
                          shadowArrow: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _statCard(
                          title: "Total Revenue",
                          value: "₱ ${totalRevenue.toStringAsFixed(2)}",
                          color: const Color(0xFFB33A2F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
      
                  // Zone Cards
                  _zoneCard("Zone A", "$zoneASold / $zoneCapacity", const Color(0xFF941E1E)),
                  _zoneCard("Zone B", "$zoneBSold / $zoneCapacity", const Color(0xFFE09B1E)),
                  _zoneCard("Zone C", "$zoneCSold / $zoneCapacity", const Color(0xFFDE8F4A)),
                  const SizedBox(height: 24),
      
                  // Circular Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CirclePercent(label: "Zone A", percent: zoneAPercent, color: Color(0xFF941E1E)),
                      _CirclePercent(label: "Zone B", percent: zoneBPercent, color: Color(0xFFE09B1E)),
                      _CirclePercent(label: "Zone C", percent: zoneCPercent, color: Color(0xFFDE8F4A)),
                    ],
                  ),
                ],
              ),
            ),          
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required Color color,
    bool shadowArrow = false,
  }) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _zoneCard(String zone, String stats, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 3)),
        ],
      ),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(zone, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(stats, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    supabase.removeAllChannels();
    super.dispose();
  }
}

class _CirclePercent extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _CirclePercent({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: CustomPaint(
            painter: _CirclePainter(percent: percent, color: color),
            child: Center(
              child: Text(
                "${(percent * 100).round()}%",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double percent;
  final Color color;
  _CirclePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.0;
    final radius = (size.width - strokeWidth) / 2;

    final base = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, base);
    final sweep = 2 * 3.14 * percent;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
      -3.14 / 2, sweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}