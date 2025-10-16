import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_header.dart';
import 'menu.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final supabase = Supabase.instance.client;

  Map<String, int> zoneSales = {"A": 0, "B": 0, "C": 0};
  List<Map<String, dynamic>> dailyRevenue = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReportData();
    _subscribeToRealTimeUpdates();
  }

  Future<void> fetchReportData() async {
    try {
      setState(() => isLoading = true);

      final zoneData = await supabase
          .from('sales')
          .select('sale_id, tickets!inner(zone)');

      final zoneCount = {"A": 0, "B": 0, "C": 0};
      for (final row in zoneData) {
        final zone = row['tickets']['zone'].toString().toUpperCase();
        if (zone == 'A') zoneCount["A"] = zoneCount["A"]! + 1;
        if (zone == 'B') zoneCount["B"] = zoneCount["B"]! + 1;
        if (zone == 'C') zoneCount["C"] = zoneCount["C"]! + 1;
      }

      // Fetch daily revenue (past week)
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 6));
      final revenueData = await supabase
          .from('sales')
          .select('sale_price, timestamp')
          .gte('timestamp', sevenDaysAgo.toIso8601String());

      final Map<String, double> dailyTotals = {};
      for (final row in revenueData) {
        final date = DateTime.parse(row['timestamp']).toLocal();
        final dayLabel = "${date.month}/${date.day}";
        final price = (row['sale_price'] ?? 0).toDouble();
        dailyTotals[dayLabel] = (dailyTotals[dayLabel] ?? 0) + price;
      }

      if (!mounted) return;
      setState(() {
        zoneSales = zoneCount;
        dailyRevenue = dailyTotals.entries
            .map((e) => {"day": e.key, "revenue": e.value})
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching report data: $e');
    }
  }

  void _subscribeToRealTimeUpdates() {
    final tables = ['sales', 'tickets'];

    for (final table in tables) {
      supabase.channel(table).onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (payload) {
          debugPrint('Realtime update from $table: ${payload.eventType}');
          fetchReportData();
        },
      ).subscribe();
    }
  }

  @override
  void dispose() {
    supabase.removeAllChannels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: "Reports",
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: MenuScreen(),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: fetchReportData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sales Breakdown
                      const Text(
                        "Sales Breakdown",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceEvenly,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return const Text('Zone A');
                                      case 1:
                                        return const Text('Zone B');
                                      case 2:
                                        return const Text('Zone C');
                                      default:
                                        return const Text('');
                                    }
                                  },
                                ),
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [
                                BarChartRodData(
                                    toY: zoneSales["A"]!.toDouble(),
                                    color: const Color(0xFF941E1E))
                              ]),
                              BarChartGroupData(x: 1, barRods: [
                                BarChartRodData(
                                    toY: zoneSales["B"]!.toDouble(),
                                    color: const Color(0xFFE09B1E))
                              ]),
                              BarChartGroupData(x: 2, barRods: [
                                BarChartRodData(
                                    toY: zoneSales["C"]!.toDouble(),
                                    color: const Color(0xFFDE8F4A))
                              ]),
                            ],
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Daily Revenue
                      const Text(
                        "Daily Revenue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() < dailyRevenue.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          dailyRevenue[value.toInt()]['day'],
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: _getYAxisInterval(),
                                  getTitlesWidget: (value, meta) => Text(
                                    "₱${value.toStringAsFixed(0)}",
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: const Color(0xFFB33A2F),
                                spots: [
                                  for (int i = 0; i < dailyRevenue.length; i++)
                                    FlSpot(
                                      i.toDouble(),
                                      dailyRevenue[i]['revenue'],
                                    ),
                                ],
                                dotData: FlDotData(show: true),
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

  double _getYAxisInterval() {
    if (dailyRevenue.isEmpty) return 100;
    final values = dailyRevenue.map((e) => e['revenue'] as double).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    return (maxValue / 4).clamp(50, 500); 
  }
}
