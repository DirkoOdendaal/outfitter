import 'package:flutter/material.dart';
import 'package:outfitter/services/parse_service.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';

/// Used to create user-dependant objects that need to be accessible by all widgets.
/// This widget should live above the [MaterialApp].
/// See [RootPage], a descendant widget that consumes the snapshot generated by this builder.
class AuthWidgetBuilder extends StatelessWidget {
  const AuthWidgetBuilder({required Key key, required this.widgetBuilder})
      : super(key: key);
  final Widget Function(BuildContext, AsyncSnapshot<ParseUser?>) widgetBuilder;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<ParseService>(context, listen: true);
    return StreamBuilder<ParseUser?>(
      stream: authService.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<ParseUser?> snapshot) {
        return widgetBuilder(context, snapshot);
      },
    );
  }
}
