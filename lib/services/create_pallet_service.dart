import 'dart:convert';
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:http/http.dart' as http;

class CreatePalletService {
  static final String _apiUrl = "${ApiUrl.baseUrl}/create-pallet";

  static Future<List<dynamic>> getAll() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load pallet creation data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}