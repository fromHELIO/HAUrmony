import 'dart:io';
import 'package:flutter/material.dart';
import '../services/profile_repository.dart';

const Color logoRed = Color(0xFFA32020);


Widget haurmonyHamburger({bool end = false}) {
  return Builder(
    builder: (ctx) {
      return IconButton(
        icon: Image.asset('lib/assets/haurmony.png', width: 32, height: 32),
        onPressed: () {
          if (end) {
            Scaffold.of(ctx).openEndDrawer();
          } else {
            Scaffold.of(ctx).openDrawer();
          }
        },
        tooltip: 'Menu',
      );
    },
  );
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _menuRow(BuildContext context, Widget iconWidget, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: logoRed, width: 1.3),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: ProfileRepository.instance.profileNotifier,
          builder: (context, dynamic profile, _) {
            // profile is expected to be a Profile instance
            final name = profile?.name ?? '';
            final email = profile?.email ?? '';

            return Column(
              children: [
                const SizedBox(height: 12),
                // brand row (icon + HAUrmony)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // box with haumony.png
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: logoRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset('lib/assets/haurmony.png', fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('HAUrmony', style: TextStyle(color: logoRed, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Removed avatar widget
                // Display only name and email
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                const Divider(height: 1),

                // Profile menu item
                _menuRow(
                  context,
                  const Icon(Icons.person, color: logoRed, size: 22),
                  'Profile',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),

                const Divider(height: 1),
                const Spacer(),

                // Log out at bottom
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, top: 6.0),
                  child: _menuRow(
                    context,
                    const Icon(Icons.logout, color: logoRed, size: 22),
                    'Log Out',
                    () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}