import 'package:flutter/material.dart';
import 'package:outfitter/app/menu.dart';
import 'package:outfitter/app/menu_controller.dart';
import 'package:outfitter/app/zoom_scaffold.dart';
import 'package:outfitter/models/outfitter_model.dart';
import 'package:outfitter/services/location_service.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> with TickerProviderStateMixin {
  late MenuController menuController;

  @override
  void initState() {
    super.initState();
    menuController = MenuController(
      vsync: this,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationService =
        Provider.of<LocationService>(context, listen: false);

    locationService.requestPermission();

    return ChangeNotifierProvider<MenuController>.value(
      value: menuController,
      child: ZoomScaffold(
        menuScreen: MenuScreen(),
        contentScreen:
            Layout(contentBuilder: (BuildContext cc) => _buildLayout()),
      ),
    );
  }

  Widget _buildLayout() {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: const Color(0xFF201E1E),
            padding: const EdgeInsets.only(top: 20.0),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                Container(
                  color: const Color(0xFF201E1E),
                  child: Container(
                    child: Center(
                      child: determinePageContent(),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget determinePageContent() {
    return Consumer<OutfitterModel>(
        builder: (BuildContext context, OutfitterModel model, Widget? child) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 17.0, top: 15.0, bottom: 8.0, right: 15.0),
              child: Text(
                'Welcome ${model.getUser!.name}',
                style: const TextStyle(fontSize: 20.0, color: Colors.white),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                  left: 20.0, top: 10.0, bottom: 8.0, right: 15.0),
              child: Text(
                "Let's get you setup!",
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            )
          ]);
    });
  }
}
