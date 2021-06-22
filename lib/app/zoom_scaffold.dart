import 'package:flutter/material.dart';
import 'package:outfitter/app/custom_shape_border.dart';
import 'package:outfitter/app/menu_controller.dart';
import 'package:provider/provider.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'package:wiredash/wiredash.dart';

import '../service_locator.dart';

class Choice {
  const Choice({required this.title, required this.icon, required this.route});

  final String title;
  final Icon icon;
  final String route;
}

class ZoomScaffold extends StatefulWidget {
  const ZoomScaffold(
      {required this.menuScreen,
      required this.contentScreen,
      this.appBarTitle = ''});

  final Widget menuScreen;
  final Layout contentScreen;
  final String appBarTitle;

  @override
  _ZoomScaffoldState createState() => _ZoomScaffoldState();
}

class _ZoomScaffoldState extends State<ZoomScaffold>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  Curve scaleDownCurve = const Interval(0.0, 0.5, curve: Curves.easeOut);
  Curve scaleUpCurve = const Interval(0.0, 0.5, curve: Curves.easeOut);
  Curve slideOutCurve = const Interval(0.0, 0.8, curve: Curves.easeOut);
  Curve slideInCurve = const Interval(0.0, 0.8, curve: Curves.easeOut);

  Widget createContentDisplay() {
    return zoomAndSlideContent(Container(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueAccent.shade200,
            onPressed: () => Wiredash.of(context)!.show(),
            child: const Icon(
              Typicons.message,
              color: Colors.white,
            ),
          ),
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.blueAccent.shade200,
                    offset: const Offset(0, 3.0),
                    blurRadius: 4.0,
                  )
                ],
              ),
              child: AppBar(
                title: Text(widget.appBarTitle),
                elevation: 5.0,
                backgroundColor: const Color(0xFF121111),
                shape: CustomShapeBorder(),
                leading: IconButton(
                    icon: Icon(
                      _getIcon(),
                      color: Colors.white,
                      size: 30.0,
                    ),
                    onPressed: () {
                      Provider.of<MenuController>(context, listen: false)
                          .toggle();
                    }),
              ),
            ),
          ),
          body: widget.contentScreen.contentBuilder(context)),
    ));
  }

  IconData _getIcon() {
    switch (Provider.of<MenuController>(context, listen: true).state) {
      case MenuState.closed:
        return Typicons.th_menu;
      case MenuState.open:
        return Typicons.arrow_left;
      case MenuState.opening:
        return Typicons.arrow_left;
      case MenuState.closing:
        return Typicons.arrow_left;
      default:
        return Typicons.th_menu;
    }
  }

  Widget zoomAndSlideContent(Widget content) {
    double slidePercent;
    double scalePercent;

    switch (Provider.of<MenuController>(context, listen: true).state) {
      case MenuState.closed:
        slidePercent = 0.0;
        scalePercent = 0.0;
        break;
      case MenuState.open:
        slidePercent = 1.0;
        scalePercent = 1.0;
        break;
      case MenuState.opening:
        slidePercent = slideOutCurve.transform(
            Provider.of<MenuController>(context, listen: true).percentOpen);
        scalePercent = scaleDownCurve.transform(
            Provider.of<MenuController>(context, listen: true).percentOpen);
        break;
      case MenuState.closing:
        slidePercent = slideInCurve.transform(
            Provider.of<MenuController>(context, listen: true).percentOpen);
        scalePercent = scaleUpCurve.transform(
            Provider.of<MenuController>(context, listen: true).percentOpen);
        break;
    }

    final slideAmount = 275.0 * slidePercent;
    final contentScale = 1.0 - (0.2 * scalePercent);
    final cornerRadius =
        16.0 * Provider.of<MenuController>(context, listen: true).percentOpen;

    return Transform(
      transform: Matrix4.translationValues(slideAmount, 0.0, 0.0)
        ..scale(contentScale, contentScale),
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0.0, 5.0),
              blurRadius: 15.0,
              spreadRadius: 10.0,
            ),
          ],
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius), child: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          child: Scaffold(
            body: widget.menuScreen,
          ),
        ),
        createContentDisplay()
      ],
    );
  }
}

class ZoomScaffoldMenuController extends StatefulWidget {
  const ZoomScaffoldMenuController({required this.builder});

  final ZoomScaffoldBuilder builder;

  @override
  ZoomScaffoldMenuControllerState createState() {
    return ZoomScaffoldMenuControllerState();
  }
}

class ZoomScaffoldMenuControllerState
    extends State<ZoomScaffoldMenuController> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(
        context, Provider.of<MenuController>(context, listen: true));
  }
}

typedef ZoomScaffoldBuilder = Widget Function(
    BuildContext context, MenuController menuController);

class Layout {
  Layout({required this.contentBuilder});

  final WidgetBuilder contentBuilder;
}
