import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_header.dart';
import 'menu.dart';
import 'user_detail_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];

  String _searchText = '';
  String _filter = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    try {
      final data = await supabase
          .from('user_info')
          .select('info_id, first_name, last_name, is_angelite');

      final users = (data as List)
          .map((user) => {
                'id': user['info_id'],
                'name': "${user['first_name']} ${user['last_name']}",
                'type': user['is_angelite'] == true
                    ? 'Angelite'
                    : 'Non - Angelite',
              })
          .toList();

      setState(() {
        allUsers = users;
        filteredUsers = users;
      });
    } catch (e) {
      debugPrint('Error Fetching Users: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void applySearchAndFilter() {
    setState(() {
      filteredUsers = allUsers.where((user) {
        final name = user['name'].toLowerCase();
        final type = user['type'];
        final matchesSearch = name.contains(_searchText.toLowerCase());
        final matchesFilter = _filter == 'All' || type == _filter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppHeader(
          title: "Users", 
          onMenuTap: () => Scaffold.of(context).openDrawer(),
        ),
      
        drawer: MenuScreen(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          _searchText = val;
                          applySearchAndFilter();
                        },
      
                        decoration: InputDecoration(
                          hintText: "Search...",
                          hintStyle: const TextStyle(color: Color(0xFF656565)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: const Color(0xFFD9D9D9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
      
                    const SizedBox(width: 12,),
      
                    DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
      
                        child: DropdownButton<String>(
                          value: _filter,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                          onChanged: (val) {
                            setState(() {
                              _filter = val!;
                              applySearchAndFilter();
                            });
                          },
      
                          items: const [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text('All', style: TextStyle(color: Colors.black)),
                            ),
      
                            DropdownMenuItem(
                              value: 'Angelite',
                              child: Text('Angelite', style: TextStyle(color: Colors.black)),
                            ),
      
                            DropdownMenuItem(
                              value: 'Non - Angelite',
                              child: Text('Non - Angelite', style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      
                const SizedBox(height: 16),
      
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredUsers.isEmpty
                          ? const Center(child: Text('No users found.'))
                          : ListView.separated(
                            itemCount: filteredUsers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black, width: 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
      
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _borderBox(Text(
                                        user["name"], 
                                        textAlign: TextAlign.center,
                                      )),
                                    ),
      
                                    const SizedBox(width: 6,),
      
                                    Expanded(
                                      flex: 2,
                                      child: _borderBox(Text(user["type"], textAlign: TextAlign.center)),
                                    ),
                                    const SizedBox(width: 6,),
      
                                    SizedBox(
                                      width: 70,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade600,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
      
                                        onPressed: () {
                                          Navigator.push(
                                            context, 
                                            MaterialPageRoute(
                                              builder: (_) => UserDetailScreen(
                                                infoId: user["id"],
                                              ),
                                            ),
                                          );
                                        },
      
                                        child: const Text(
                                          "View",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
      
                                    const SizedBox(width: 6),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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