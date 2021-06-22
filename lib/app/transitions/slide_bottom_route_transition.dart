import 'package:flutter/material.dart';

class SlideBottomRoute extends PageRouteBuilder<dynamic> {
  SlideBottomRoute({required this.page})
      : super(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) =>
                page,
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              const begin = Offset(0.0, -1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              final tween = Tween<Offset>(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            });
  final Widget page;
}
