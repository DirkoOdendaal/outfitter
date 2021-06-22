import 'dart:async';

import 'package:flutter/material.dart';
import 'package:outfitter/app/home.dart';
import 'package:outfitter/app/login.dart';
import 'package:outfitter/models/outfitter_model.dart';
import 'package:outfitter/services/parse_service.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';

import 'package:outfitter/models/user_model.dart' as user_model;
import 'package:provider/single_child_widget.dart';
import 'package:wiredash/wiredash.dart';

class RootPage extends StatelessWidget {
  const RootPage({Key? key, required this.userSnapshot}) : super(key: key);
  final AsyncSnapshot<ParseUser?> userSnapshot;

  @override
  Widget build(BuildContext context) {
    final outfitterModel = Provider.of<OutfitterModel>(context, listen: false);
    print(userSnapshot.connectionState);
    if (userSnapshot.connectionState == ConnectionState.active) {
      if (userSnapshot.hasData) {
        Wiredash.of(context)!.setUserProperties(
          userEmail: userSnapshot.data?.emailAddress,
          userId: userSnapshot.data?.objectId,
        );

        outfitterModel.setUserInitial(user_model.User(
            userSnapshot.data!.objectId,
            userSnapshot.data!.get<String>('name'),
            userSnapshot.data!.get<String>('surname'),
            userSnapshot.data!.emailAddress,
            ''));
      }

if(userSnapshot.hasData)
 {
   print(userSnapshot.data!.emailAddress);
 }      

      return userSnapshot.hasData && userSnapshot.data!.emailAddress != null
          ? MultiProvider(providers: <SingleChildWidget>[
              Provider<ParseUser>.value(value: userSnapshot.data!)
            ], child: HomePage())
          : LoginPage();
    }
    return Scaffold(
      body: Container(
        color: const Color(0xFF201E1E),
        padding: const EdgeInsets.only(top: 20.0),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
