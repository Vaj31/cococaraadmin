import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static bool isLoggedIn = false;

  static Future<void> login() async {
    isLoggedIn = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  static Future<void> logout() async {
    isLoggedIn = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}