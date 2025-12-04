import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _email = '';
  String _verificationCode = '';
  String _password = '';
  String _uid = '';

  bool _isPasswordVisible = false;

  String get email => _email;
  String get verificationCode => _verificationCode;
  String get password => _password;
  String get uid => _uid;
  bool get isPasswordVisible => _isPasswordVisible;

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set verificationCode(String value) {
    _verificationCode = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  set uid(String value) {
    _uid = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }
}
