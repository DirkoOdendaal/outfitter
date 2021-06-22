import 'package:flutter/foundation.dart';
import 'package:outfitter/models/user_model.dart';

class OutfitterModel extends ChangeNotifier {
  User? _user;

  User? get getUser => _user;

  void setUserInitial(User user) {
    _user = user;
  }

  void setUser(User user) {
    _user = user;
    // This line tells [Model] that it should rebuild the widgets that
    // depend on it.
    notifyListeners();
  }

  void signOut() {
    _user = null;
    print('model is reset');
    notifyListeners();
  }
}
