<<<<<<< Updated upstream
import 'package:flutter/material.dart';
import 'package:pawtnerup_admin/models/user_model.dart';


class AuthenticationProvider extends ChangeNotifier {
  late UserModel? _user;
  UserModel? get user => _user;

  // set user 
  set user(UserModel? user) {
=======
import 'package:flutter/material.dart';  
import 'package:pawtnerup_admin/models/shelter_model.dart';

class AuthenticationProvider extends ChangeNotifier {
  late ShelterModel? _user;

  ShelterModel? get user => _user;

  // set user 
  set user(ShelterModel? user) {
>>>>>>> Stashed changes
    _user = user;
    notifyListeners();
  }

  // remove user
  void removeUser() {
    _user = null;
    notifyListeners();
  }
}