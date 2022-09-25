// Custom AppBar widget to remain consistent between pages.

import 'package:flutter/material.dart';
import 'package:sossoldi/pages/settings_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Sossoldi"),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        SettingsPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ));
            },
            icon: Icon(Icons.settings)),
      ],
    );
  }
}
