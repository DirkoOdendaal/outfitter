import 'package:flutter/material.dart';

class CustomShapeBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    path.lineTo(0, rect.height);
    path.lineTo(0, rect.height);
    path.quadraticBezierTo(
        rect.width / 2, rect.height + 10, rect.width, rect.height);
    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }
}
