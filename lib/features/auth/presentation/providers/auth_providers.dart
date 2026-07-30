import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:ccpladmin/helpers/services/storage/local_storage.dart';
import 'package:ccpladmin/services/auth_service.dart';

// Login screen state providers
final loginObscureTextProvider = StateProvider.autoDispose<bool>((ref) => true);
final loginRememberMeProvider = StateProvider.autoDispose<bool>((ref) => false);
final loginLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

// SignUp screen state providers
final signUpObscureTextProvider = StateProvider.autoDispose<bool>((ref) => true);
final signUpLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

// Reset password screen state providers
final resetPasswordShowProvider = StateProvider.autoDispose<bool>((ref) => false);
final resetConfirmPasswordShowProvider = StateProvider.autoDispose<bool>((ref) => false);

// Logic / Action Notifiers
class LoginActionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<bool> login(String email, String password) async {
    try {
      final url = "${ApiUrl.baseUrl}/adminlogin/login";
      print("Sending login request to: $url");
      
      var response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": email, "password": password}));

      print("Login response status: ${response.statusCode}");
      print("Login response body: ${response.body}");

      if (response.statusCode == 200) {
        await LocalStorage.setLoggedInUser(true);
        AuthService.isLoggedIn = true;
        return true;
      }
      return false;
    } catch (e, stack) {
      print("Login exception occurred: $e");
      print(stack);
      return false;
    }
  }
}

final loginActionProvider = NotifierProvider<LoginActionNotifier, void>(() {
  return LoginActionNotifier();
});
