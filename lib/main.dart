import 'dart:async';

import 'package:flutter/material.dart';
import 'package:outfitter/app/email_address.dart';
import 'package:outfitter/app/forgotten_password.dart';
import 'package:outfitter/app/home.dart';
import 'package:outfitter/app/register.dart';
import 'package:outfitter/app/root_page.dart';
import 'package:outfitter/app/transitions/slide_bottom_route_transition.dart';
import 'package:outfitter/app/transitions/slide_left_route_transition.dart';
import 'package:outfitter/app/transitions/slide_right_route_transition.dart';
import 'package:outfitter/app/transitions/slide_top_route_transition.dart';
import 'package:outfitter/auth_widget_builder.dart';
import 'package:outfitter/models/outfitter_model.dart';
import 'package:outfitter/service_locator.dart';
import 'package:outfitter/services/location_service.dart';
import 'package:outfitter/services/navigation_service.dart';
import 'package:outfitter/services/parse_service.dart';
import 'package:outfitter/constants.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';

import 'package:provider/single_child_widget.dart';
import 'package:wiredash/wiredash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(
    parseApplicationId,
    parseAppUrl,
    masterKey: parseMasterKey,
    clientKey: parseClientKey,
    autoSendSessionId: true,
    // debug: true,
    // coreStore: await CoreStoreSembastImp.getInstance('/data'),
  );
  setupLocator();
  runApp(Outfitter());
}

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _blackPrimaryValue = 0xFF000000;

class Outfitter extends StatefulWidget {
  @override
  _OutfitterState createState() => _OutfitterState();
}

class _OutfitterState extends State<Outfitter> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<ParseService>(
          create: (_) => ParseService(),
        ),
        Provider<LocationService>(
          create: (_) => LocationService(),
        ),
        ChangeNotifierProvider<OutfitterModel>(
          create: (BuildContext context) => OutfitterModel(),
        ),
        Provider<NavigationService>(
          create: (_) => NavigationService(),
        ),
      ],
      child: Wiredash(
        projectId: 'outfitter-ievx0zd',
        secret: 'rhv5uh9r4jdxbalqgch5qi1rp0uu0du9pxx5vutfg591fodr',
        navigatorKey: NavigationService.navigatorKey,
        // options: WiredashOptionsData(
        //   showDebugFloatingEntryPoint: false,
        // ),
        theme: WiredashThemeData(
            backgroundColor: const Color(0xFF2D2D2D),
            primaryBackgroundColor: const Color(0xFF2D2D2D),
            secondaryBackgroundColor: const Color(0xFF201E1E),
            primaryColor: Colors.blueAccent.shade200,
            secondaryColor: Colors.blueAccent.shade200,
            primaryTextColor: Colors.white,
            secondaryTextColor: Colors.white,
            dividerColor: Colors.white),
        child: MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Game Surv',
          theme: ThemeData(
              primarySwatch: primaryBlack,
              fontFamily: 'Montserrat',
              brightness: Brightness.dark),
          onGenerateRoute: (RouteSettings routeSettings) {
            switch (routeSettings.name) {
              case '/login':
                return SlideBottomRoute(
                  page: AuthWidgetBuilder(
                    widgetBuilder: (BuildContext context,
                        AsyncSnapshot<ParseUser?> userSnapshotResult) {
                      return RootPage(userSnapshot: userSnapshotResult);
                    },
                    key: const Key('main_auth_key'),
                  ),
                );
              case '/register':
                return SlideTopRoute(page: RegisterPage());
              case '/reset-password':
                return SlideTopRoute(page: ForgottenPasswordPage());
              case '/home':
                return SlideRightRoute(page: HomePage());
              case '/email-address':
                return SlideLeftRoute(page: EmailAddressPage());
              default:
                return SlideBottomRoute(
                  page: AuthWidgetBuilder(
                    widgetBuilder: (BuildContext context,
                        AsyncSnapshot<ParseUser?> userSnapshotResult) {
                      return RootPage(userSnapshot: userSnapshotResult);
                    },
                    key: const Key('main_auth_default_key'),
                  ),
                );
            }
          },
          home: AuthWidgetBuilder(
            widgetBuilder: (BuildContext context,
                AsyncSnapshot<ParseUser?> userSnapshotResult) {
              return RootPage(userSnapshot: userSnapshotResult);
            },
            key: const Key('main_auth_key_default'),
          ),
        ),
      ),
    );
  }
}
