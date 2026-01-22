import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  bool? status = false;
  String? token;
  String? message;
  int? id;
  String? name;
  String? email;
  String? role;
  UserLogin({
    this.status,
    this.token,
    this.message,
    this.id,
    this.name,
    this.email,
    this.role,
  });

  Future prefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (status != null) prefs.setBool("status", status!);
    if (token != null) prefs.setString("token", token!);
    if (message != null) prefs.setString("message", message!);
    if (id != null) prefs.setInt("id", id!);
    if (name != null) prefs.setString("name", name!);
    if (email != null) prefs.setString("email", email!);
    if (role != null) prefs.setString("role", role!);
  }

  Future getUserLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserLogin userLogin = UserLogin(
      status: prefs.getBool("status"),
      token: prefs.getString("token"),
      message: prefs.getString("message"),
      id: prefs.getInt("id"),
      name: prefs.getString("name"),
      email: prefs.getString("email"),
      role: prefs.getString("role"),
    );
    return userLogin;
  }

  // Method untuk clear semua data user saat logout
  Future clearUserLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("status");
    await prefs.remove("token");
    await prefs.remove("message");
    await prefs.remove("id");
    await prefs.remove("name");
    await prefs.remove("email");
    await prefs.remove("role");
  }

  UserLogin.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    token = json['token'];
    message = json['message'];
    id = json['data']?['id'];
    name = json['data']?['name'];
    email = json['data']?['email'];
    role = json['data']?['role'];
  }
}