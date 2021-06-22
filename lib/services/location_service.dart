import 'dart:async';

import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

class LocationService {
  LocationService() {
    initialize();
  }

  void requestPermission() {
    <handler.Permission>[
      handler.Permission.locationWhenInUse,
      handler.Permission.notification,
    ]
        .request()
        .then((Map<handler.Permission, handler.PermissionStatus> status) {
      initialize();
    });
  }

  Location location = Location();

  Future<void> initialize() async {
    if (await handler.Permission.location.isGranted) {
      // If granted listen to the onLocationChanged stream and emit over our controller
      location.onLocationChanged.listen((LocationData locationData) {
        print('Current location: ');
      });
    }
  }
}
