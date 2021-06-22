import 'dart:async';

import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:rxdart/rxdart.dart';

class ParseService {
  ParseService() {
    ParseUser.currentUser().then((dynamic value) {
      if (value != null) {
        final user = value as ParseUser;
        _userStream.add(user);
        _currentUser = user;
      } else {
        _userStream.add(value);
      }
    });
  }

  late ParseUser _currentUser;
  final StreamController<ParseUser?> _userStream = BehaviorSubject();

  // Auth and user section
  Stream<ParseUser?> get onAuthStateChanged {
    print('auth changed');
    return _userStream.stream;
  }

  Future<void> signOut() async {
    final response = await _currentUser.logout();
    if (response.success) {
      _userStream.add(_currentUser);
    } else {
      throw Exception(response.error);
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final user = ParseUser(email, password, email);
      final response = await user.login();
      if (response.success) {
        _currentUser = user;
        _userStream.add(user);
      } else {
        print(response.error);
        final theError = response.error;

        throw Exception(theError!.message);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final function = ParseCloudFunction('sendPasswordResetEmail');
    final params = <String, String>{'email': email};
    final result = await function.execute(parameters: params);

    if (result.success) {
      if (result.result['processed'] as bool) {
        return;
      } else {
        throw Exception(result.result['error'] as String);
      }
    } else {
      final theError = result.error;

      throw Exception(theError!.message);
    }
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password, String name, String surname) async {
    try {
      final user = ParseUser(email, password, email);
      user.set('name', name);
      user.set('surname', surname);

      final result = await user.create();
      if (result.success) {
        // Create installation record
        await ParseInstallation.currentInstallation()
            .then((ParseInstallation value) async {
          value.set('user_id', user.objectId);
          value.set('GCMSenderId', '882756483241');

          await value.create();
        });

        _currentUser = user;
        _userStream.add(user);
        return;
      } else {
        print(result.error);
        final theError = result.error;

        throw Exception(theError!.message);
      }
    } catch (e) {
      throw Exception(e as String);
    }
  }

  Future<ParseUser> currentUser() async {
    return _currentUser;
  }
}
