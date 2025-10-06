import 'package:flutter/material.dart';
import '../constants.dart';
import 'app_title.dart';

PreferredSizeWidget appBarWithHamburger(
  BuildContext context, {
  bool showBack = true,
  bool openEndDrawer = true, // true -> opens endDrawer, false -> opens drawer
}) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 1,
    automaticallyImplyLeading: false, // we handle leading
    leading: showBack
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            color: kLogoColor,
            onPressed: () => Navigator.maybePop(context),
          )
        : null,
    centerTitle: true,
    title: const AppTitle(),
    actions: [
      Builder(builder: (ctx) {
        return IconButton(
          icon: const Icon(Icons.menu), // proper hamburger icon
          color: kLogoColor,
          onPressed: () {
            if (openEndDrawer) {
              Scaffold.of(ctx).openEndDrawer();
            } else {
              Scaffold.of(ctx).openDrawer();
            }
          },
          tooltip: 'Menu',
        );
      })
    ],
  );
}