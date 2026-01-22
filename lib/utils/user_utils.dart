import 'package:mobileapp2/models/user_login.dart';
import 'package:flutter/material.dart';

/// Utility class untuk memudahkan akses data user
/// Gunakan class ini untuk menghindari repetisi kode saat mengakses user data
class UserUtils {
  /// Get current user data secara lengkap
  /// Returns UserLogin object atau null jika tidak ada user
  static Future<UserLogin?> getCurrentUser() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    
    if (user.status == true && user.name != null) {
      return user;
    }
    return null;
  }

  /// Check apakah user sudah login
  /// Returns true jika user sudah login dan memiliki token
  static Future<bool> isUserLoggedIn() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return user.status == true && user.token != null;
  }

  /// Check apakah user adalah admin
  /// Returns true jika role adalah 'admin'
  static Future<bool> isUserAdmin() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return user.role?.toLowerCase() == 'admin';
  }

  /// Check apakah user adalah regular user
  /// Returns true jika role adalah 'user'
  static Future<bool> isRegularUser() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return user.role?.toLowerCase() == 'user';
  }

  /// Get user name
  /// Returns nama lengkap user atau null
  static Future<String?> getUserName() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return user.name;
  }

  /// Get user role
  /// Returns role user (admin/user) atau null
  static Future<String?> getUserRole() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return user.role;
  }

  /// Get user email
  /// Returns email user atau null
  static Future<String?> getUserEmail() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return user.email;
  }

  /// Get user ID
  /// Returns ID user atau null
  static Future<int?> getUserId() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return user.id;
  }

  /// Get user token untuk API request
  /// Returns token atau null
  static Future<String?> getUserToken() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    return user.token;
  }

  /// Logout user dengan menghapus semua data
  static Future<void> logoutUser() async {
    UserLogin userLogin = UserLogin();
    await userLogin.clearUserLogin();
  }

  /// Get display name untuk greeting
  /// Contoh output: "Halo, John Doe!"
  static Future<String> getGreetingMessage() async {
    final name = await getUserName();
    return 'Halo, ${name ?? 'User'}!';
  }

  /// Get role display text
  /// Menerjemahkan role ke bahasa yang lebih mudah dibaca
  static String getRoleDisplayText(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'user':
        return 'Pengguna Biasa';
      default:
        return 'Unknown Role';
    }
  }

  /// Get role badge color
  /// Mengembalikan color untuk role badge
  static Color getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Color(0xFFFF6B6B); // Red
      case 'user':
        return Color(0xFF51CF66); // Green
      default:
        return Color(0xFF868E96); // Gray
    }
  }
}
