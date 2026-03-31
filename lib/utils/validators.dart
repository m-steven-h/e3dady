// lib/utils/validators.dart
class Validators {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال اسم المستخدم';
    }
    if (value.length < 3) {
      return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }
}

// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  
  User? get user => _user;
  
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
  
  void clearUser() {
    _user = null;
    notifyListeners();
  }
  
  bool get isLoggedIn => _user != null;
  bool get isFounder => _user?.role == 'founder';
  bool get isAmin => _user?.role == 'amin';
  bool get isServant => _user?.role == 'servant';
}