import 'package:flutter/material.dart';
import 'package:mobileapp2/models/user_login.dart';

class UserProvider extends ChangeNotifier {
  UserLogin? _currentUser;
  bool _isLoggedIn = false;

  // Getter
  UserLogin? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _currentUser?.name;
  String? get userRole => _currentUser?.role;
  String? get userEmail => _currentUser?.email;

  // Load user from SharedPreferences saat app dibuka
  Future<void> loadUserFromStorage() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    
    if (user.status == true && user.token != null) {
      _currentUser = user;
      _isLoggedIn = true;
    } else {
      _currentUser = null;
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  // Set user setelah login/register berhasil
  void setUser(UserLogin user) {
    _currentUser = user;
    _isLoggedIn = user.status == true;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
    
    // Clear SharedPreferences
    UserLogin userLogin = UserLogin();
    await userLogin.getUserLogin();
    // Anda bisa menambahkan clear di UserLogin model jika diperlukan
    
    notifyListeners();
  }

  // Update user data
  void updateUserData({String? nama, String? role, String? email}) {
    if (_currentUser != null) {
      _currentUser = UserLogin(
        status: _currentUser!.status,
        token: _currentUser!.token,
        message: _currentUser!.message,
        id: _currentUser!.id,
        name: nama ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        role: role ?? _currentUser!.role,
      );
      notifyListeners();
    }
  }
}
