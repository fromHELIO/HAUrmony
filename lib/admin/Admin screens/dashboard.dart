import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import 'menu.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: "Dashboard",
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: MenuScreen(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Top Stat Cards ----
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: "Ticket Sold Today",
                      value: "999 / 1500",
                      color: const Color(0xFFE09B1E),
                      showArrow: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard(
                      title: "Total Revenue",
                      value: "₱ 8000.23",
                      color: const Color(0xFFB33A2F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
        
              // ---- Zone Cards ----
              _zoneCard("Zone A", "180 / 200", const Color(0xFF941E1E)),
              _zoneCard("Zone B", "180 / 200", const Color(0xFFE09B1E)),
              _zoneCard("Zone C", "180 / 200", const Color(0xFFD3B9A3)),
              const SizedBox(height: 24),
        
              // ---- Circular indicators ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _CirclePercent(label: "Zone A", percent: 0.75, color: Color(0xFF941E1E)),
                  _CirclePercent(label: "Zone B", percent: 0.75, color: Color(0xFFE09B1E)),
                  _CirclePercent(label: "Zone C", percent: 0.75, color: Color(0xFFD3B9A3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Widgets ----------

  Widget _statCard({
    required String title,
    required String value,
    required Color color,
    bool showArrow = false,
  }) {
    return Container(
      height: 150, // 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
              ],
            )
      );
  }

  Widget _zoneCard(String zone, String stats, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(zone,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Text(stats,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }
}

// ---- Circular percent widgets ----
class _CirclePercent extends StatelessWidget {
  final String label;
  final double percent; // 0.0–1.0
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
    final sweep = 2 * 3.14159 * percent;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2, sweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
