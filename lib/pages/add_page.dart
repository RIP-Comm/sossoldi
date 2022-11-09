import 'package:flutter/material.dart';
import 'package:sossoldi/model/CircularMenuItemWrap.dart';
import 'package:sossoldi/pages/settings_page.dart';
import 'package:circular_menu/circular_menu.dart';

class AddPage extends StatefulWidget {
  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  GlobalKey<CircularMenuState> key = GlobalKey<CircularMenuState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      key.currentState?.forwardAnimation();
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(204, 204, 204, 1),
        centerTitle: true,
        title: Text(
          "DASHBOARD",
          style: Theme.of(context).textTheme.displayMedium,
        ),
        leading: IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {}),
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
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 36),
            Container(
                color: Color.fromRGBO(217, 217, 217, 1), width: 80, height: 80),
            const SizedBox(height: 24),
            const Text("Select type of transaction",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24.0,
                    fontFamily: 'SF Pro Text',
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              width: 100,
              height: 100,
              child: CircularMenu(
                key: key,
                alignment: Alignment.bottomCenter,
                animationDuration: const Duration(),
                toggleButtonColor: const Color.fromRGBO(179, 179, 179, 1),
                startingAngleInRadian: 0.785 + 3.14,
                endingAngleInRadian: 2.355 + 3.14,
                toggleButtonSize: 48.0,
                toggleButtonOnPressed: () {
                  Navigator.pop(context);
                },
                toggleButtonIconColor: const Color.fromRGBO(93, 93, 93, 1),
                items: [
                  CircularMenuItemWrap(
                    onTap: () {},
                    text: 'Income',
                    icon: Icons.arrow_downward_outlined,
                    iconColor: const Color.fromRGBO(93, 93, 93, 1),
                    color: const Color.fromRGBO(179, 179, 179, 1),
                  ),
                  CircularMenuItemWrap(
                    onTap: () {},
                    text: 'Transfer',
                    icon: Icons.compare_arrows_outlined,
                    iconColor: const Color.fromRGBO(93, 93, 93, 1),
                    color: const Color.fromRGBO(179, 179, 179, 1),
                  ),
                  CircularMenuItemWrap(
                    onTap: () {},
                    text: 'Expense',
                    icon: Icons.arrow_upward_outlined,
                    iconColor: const Color.fromRGBO(93, 93, 93, 1),
                    color: const Color.fromRGBO(179, 179, 179, 1),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
