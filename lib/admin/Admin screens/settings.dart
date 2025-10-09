import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import 'menu.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool discountWithID = true;
  bool allowVoucher = false;
  bool enableGateway = true;

  /// Zone capacities
  final Map<String, String> capacities = {
    "Zone A": "200",
    "Zone B": "200",
    "Zone C": "200",
  };

  /// Ticket prices: each zone has Angelite (discount) & SRP
  final Map<String, Map<String, String>> prices = {
    "Zone A": {"angelite": "250", "srp": "300"},
    "Zone B": {"angelite": "250", "srp": "300"},
    "Zone C": {"angelite": "250", "srp": "300"},
  };

  final Map<String, Color> zoneColors = {
    "Zone A": Colors.red,
    "Zone B": Colors.orange,
    "Zone C": Colors.brown,
  };

  // ---------- Dialogs ----------

  /// Add or Edit a zone (name + capacity)
  Future<void> _addOrEditZoneDialog({String? currentName}) async {
    final nameController = TextEditingController(text: currentName ?? "");
    final capacityController = TextEditingController(
      text: currentName != null ? capacities[currentName] : "",
    );
    final isEdit = currentName != null;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Zone" : "Add Zone"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Zone name"),
            ),
            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Capacity"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black), // black text
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;

              setState(() {
                if (isEdit && newName != currentName) {
                  capacities.remove(currentName);
                  final color = zoneColors.remove(currentName);
                  final oldPrice = prices.remove(currentName);
                  if (color != null) zoneColors[newName] = color;
                  if (oldPrice != null) prices[newName] = oldPrice;
                }
                capacities[newName] = capacityController.text.trim();
                zoneColors.putIfAbsent(newName, () => Colors.blueGrey);
                prices.putIfAbsent(newName, () => {"angelite": "0", "srp": "0"});
              });
              Navigator.pop(context);
            },
            child: Text(
              isEdit ? "Save" : "Add",
              style: const TextStyle(color: Colors.black), // black text
            ),
          ),
        ],
      ),
    );
  }

  /// Edit ticket prices (Angelite & SRP)
  Future<void> _editPriceDialog(String zone) async {
    final angeliteController =
        TextEditingController(text: prices[zone]!["angelite"]);
    final srpController =
        TextEditingController(text: prices[zone]!["srp"]);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Prices - $zone"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: angeliteController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Angelite Price"),
            ),
            TextField(
              controller: srpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "SRP Price"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black), // black text
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                prices[zone]!["angelite"] = angeliteController.text.trim();
                prices[zone]!["srp"] = srpController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.black), // black text
            ),
          ),
        ],
      ),
    );
  }

  /// Confirm delete with black text on Cancel/Delete
  Future<void> _confirmDeleteZone(String zone) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Zone"),
        content: Text("Are you sure you want to delete $zone?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black), // black text
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                capacities.remove(zone);
                prices.remove(zone);
                zoneColors.remove(zone);
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.black), // black text
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: "Settings",
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: MenuScreen(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Zone Set Up",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...capacities.keys.map(
              (zone) =>
                  _buildCapacityBox(zone, capacities[zone]!, zoneColors[zone]!),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey),
              ),
              onPressed: () => _addOrEditZoneDialog(),
              child: const Text("+ Add Zone"),
            ),
            const SizedBox(height: 20),
            const Text("Ticket Pricing",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...prices.keys.map(
              (zone) => _buildPriceBox(zone, prices[zone]!, zoneColors[zone]!),
            ),
            const SizedBox(height: 20),
            const Text("Rules & Policies",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: RichText(
                text: const TextSpan(
                  text: "Angelites users: ",
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
              title: const Text("Allow voucher PDF download"),
              value: allowVoucher,
              onChanged: (val) => setState(() => allowVoucher = val!),
            ),
            CheckboxListTile(
              title: const Text("Enable Payment Gateway"),
              value: enableGateway,
              onChanged: (val) => setState(() => enableGateway = val!),
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
    );
  }

  // ---------- Helpers ----------

  Widget _buildCapacityBox(String zone, String value, Color color) {
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
          Text("$zone Capacity:",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(value,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (choice) {
                  if (choice == 'edit') {
                    _addOrEditZoneDialog(currentName: zone);
                  } else if (choice == 'delete') {
                    _confirmDeleteZone(zone);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox(String zone, Map<String, String> price, Color color) {
    final angelite = price["angelite"] ?? "0";
    final srp = price["srp"] ?? "0";

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
              Text(
                zone,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Angelite ₱$angelite | SRP ₱$srp",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (choice) {
              if (choice == 'edit') {
                _editPriceDialog(zone);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Prices'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Changes saved successfully")),
    );
  }
}

