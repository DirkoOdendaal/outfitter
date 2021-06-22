import 'package:outfitter/app/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:outfitter/services/navigation_service.dart';
import 'package:outfitter/services/parse_service.dart';
import 'package:provider/provider.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

import '../service_locator.dart';

class MenuScreen extends StatelessWidget {
  final List<MenuItem> options = <MenuItem>[
    MenuItem(Typicons.home, 'HOME', '/home'),
    MenuItem(Typicons.mail, 'EMAIL', '/email-address')
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (DragUpdateDetails details) {
        //on swiping left
        if (details.delta.dx < -1) {
          Provider.of<MenuController>(context, listen: false).toggle();
        }
      },
      child: Container(
        padding: EdgeInsets.only(
            top: 62,
            left: 32,
            bottom: 8,
            right: MediaQuery.of(context).size.width / 2.9),
        color: Colors.grey.shade500,
        child: Column(
          children: <Widget>[
            Column(
              children: options.map((MenuItem item) {
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: Colors.black,
                    size: 20,
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  onTap: () async {
                    await locator<NavigationService>()
                        .navigateToReplacement(item.page);
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            // ListTile(
            //   onTap: () {},
            //   leading: Icon(
            //     Typicons.cog,
            //     color: Colors.black,
            //     size: 20,
            //   ),
            //   title: Text('SETTINGS',
            //       style: TextStyle(
            //           fontSize: 14,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.black)),
            // ),
            Column(
              children: <ListTile>[
                ListTile(
                  onTap: () async {
                    try {
                      final authService =
                          Provider.of<ParseService>(context, listen: false);
                      await authService.signOut();
                      await locator<NavigationService>()
                          .navigateToReplacement('/login');
                    } catch (e) {
                      print(e);
                    }
                  },
                  leading: const Icon(
                    Typicons.export,
                    color: Colors.black,
                    size: 20,
                  ),
                  title: const Text('LOGOUT',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  MenuItem(this.icon, this.title, this.page);

  String title;
  IconData icon;
  String page;
}
