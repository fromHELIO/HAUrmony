import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_header.dart';
import 'menu.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final supabase = Supabase.instance.client;

  bool discountWithID = true;
  bool enableGateway = false; //disabled
  bool isLoading = true;

  final int zoneCapacity = 100;

  final Map<String, Color> zoneColors = {
    "Zone A": Colors.red.shade700,
    "Zone B": const Color(0xFFE09B1E),
    "Zone C": const Color(0xFFDE8F4A),
  };

  Map<String, bool> zoneSoldOut = {
    "Zone A": false,
    "Zone B": false,
    "Zone C": false,
  };

  Map<String, Map<String, String>> prices = {
    "Zone A": {"angelite": "250", "srp": "300"},
    "Zone B": {"angelite": "250", "srp": "300"},
    "Zone C": {"angelite": "250", "srp": "300"},
  };

  @override
  void initState() {
    super.initState();
    _fetchZoneStatus();
  }

  Future<void> _fetchZoneStatus() async {
    try {
      // Sold tickets per zone
      final data = await supabase
          .from('tickets')
          .select('zone, is_sold')
          .eq('is_sold', true);

      // How many are sold per zone
      final Map<String, int> soldCount = {
        "ZONE A": 0,
        "ZONE B": 0,
        "ZONE C": 0,
      };

      for (final ticket in data) {
        final zone = ticket['zone'].toString().toUpperCase();
        if (soldCount.containsKey(zone)) {
          soldCount[zone] = soldCount[zone]! + 1;
        }
      }

      setState(() {
        zoneSoldOut = {
          "Zone A": soldCount["ZONE A"]! >= zoneCapacity,
          "Zone B": soldCount["ZONE B"]! >= zoneCapacity,
          "Zone C": soldCount["ZONE C"]! >= zoneCapacity,
        };
      });
    } catch (e) {
      debugPrint("Error fetching zone status: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Changes saved successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Builder(
          builder: (context) => AppHeader(
            title: "Settings",
            onMenuTap: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: MenuScreen(),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    const Text("Zone Set Up",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildCapacityBox("Zone A", "100", zoneColors["Zone A"]!),
                    _buildCapacityBox("Zone B", "100", zoneColors["Zone B"]!),
                    _buildCapacityBox("Zone C", "100", zoneColors["Zone C"]!),

                    const SizedBox(height: 20),

                    const Text("Ticket Pricing",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...prices.keys.map((zone) =>
                        _buildPriceBox(zone, prices[zone]!, zoneColors[zone]!)),
                    const SizedBox(height: 20),

                    const Text("Rules & Policies",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: RichText(
                        text: const TextSpan(
                          text: "Angelite users: ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: "1 discounted ticket max",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      value: discountWithID,
                      onChanged: (val) => setState(() => discountWithID = val!),
                    ),
                    CheckboxListTile(
                      title: const Text("Enable Payment Gateway"),
                      value: enableGateway,
                      onChanged: null, //disabled
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _saveChanges,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCapacityBox(String zone, String capacity, Color color) {
    final isSoldOut = zoneSoldOut[zone] ?? false;
    final zoneColor = isSoldOut ? color.withOpacity(0.4) : color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: zoneColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$zone Capacity: $capacity",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isSoldOut)
            const Text(
              "Sold Out",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceBox(String zone, Map<String, String> price, Color color) {
    final angelite = price["angelite"];
    final srp = price["srp"];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(zone,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("Angelite ₱$angelite | SRP ₱$srp",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}