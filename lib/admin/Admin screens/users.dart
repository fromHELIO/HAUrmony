import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import 'menu.dart';
import 'user_detail_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Original data
  final List<Map<String, String>> _allUsers = [
    {"name": "Kim Mingyu", "type": "Angelite"},
    {"name": "Jeon Wonwoo", "type": "Non - Angelite"},
    {"name": "Xu Minghao", "type": "Angelite"},
  ];

  // Current filter/search
  String _searchText = '';
  String _filter = 'All'; // All, Angelite, Non - Angelite

  @override
  Widget build(BuildContext context) {
    // Apply search + filter
    final filteredUsers = _allUsers.where((user) {
      final name = user['name']!.toLowerCase();
      final type = user['type']!;
      final matchesSearch = name.contains(_searchText.toLowerCase());
      final matchesFilter = _filter == 'All' || type == _filter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: "Users",
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      drawer: MenuScreen(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---- Search + Filter Row ----
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchText = val),
                    decoration: InputDecoration(
                      hintText: "Search ...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ---- Filter Dropdown ----
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB22727),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _filter,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      onChanged: (val) => setState(() => _filter = val!),
                      items: const [
                        DropdownMenuItem(
                            value: 'All',
                            child: Text('All',
                                style: TextStyle(color: Colors.black))),
                        DropdownMenuItem(
                            value: 'Angelite',
                            child: Text('Angelite',
                                style: TextStyle(color: Colors.black))),
                        DropdownMenuItem(
                            value: 'Non - Angelite',
                            child: Text('Non - Angelite',
                                style: TextStyle(color: Colors.black))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---- User List ----
            Expanded(
              child: ListView.separated(
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        // Name
                        Expanded(
                          flex: 2,
                          child: _borderBox(Text(
                            user["name"] ?? "",
                            textAlign: TextAlign.center,
                          )),
                        ),
                        const SizedBox(width: 6),

                        // Type
                        Expanded(
                          flex: 2,
                          child: _borderBox(Text(
                            user["type"] ?? "",
                            textAlign: TextAlign.center,
                          )),
                        ),
                        const SizedBox(width: 6),

                        // View Button
                        SizedBox(
                          width: 70,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB22727),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UserDetailScreen(
                                    name: user["name"] ?? "",
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "View",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Delete Icon
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color(0xFFB22727)),
                          onPressed: () {
                            // Delete logic here if needed
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Draw inner bordered cell
  Widget _borderBox(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(child: child),
    );
  }
}


