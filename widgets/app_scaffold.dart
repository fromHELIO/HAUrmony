import 'package:flutter/material.dart';
import 'app_drawer.dart';

const Color logoRed = Color(0xFFA32020);

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final bool showMenu; // show hamburger (default true)
  final bool centerTitle;
  final String title;

  const AppScaffold({
    super.key,
    required this.body,
    this.bottom,
    this.floatingActionButton,
    this.showMenu = true,
    this.centerTitle = true,
    this.title = 'HAUrmony',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: showMenu ? const AppDrawer() : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: centerTitle,
        iconTheme: const IconThemeData(color: logoRed), // back icon color
        automaticallyImplyLeading: showMenu ? true : false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('lib/assets/haurmony.png', width: 28, height: 28),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: logoRed, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        bottom: bottom,
        // right-side menu uses the Haurmony PNG instead of Icons.menu
        actions: showMenu
            ? [
                Builder(
                  builder: (ctx) {
                    return IconButton(
                      // use the PNG as the "hamburger" icon
                      icon: Image.asset('lib/assets/haurmony.png', width: 32, height: 32),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                      tooltip: 'Menu',
                    );
                  },
                ),
              ]
            : null,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}