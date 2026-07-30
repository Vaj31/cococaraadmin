import 'dart:convert';
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:http/http.dart' as http;

class ProductMasterService {
  final String _apiUrl = "${ApiUrl.baseUrl}/productmaster";

  Future<List<dynamic>> getAllPalletConfig() async {
    final response = await http.get(Uri.parse('$_apiUrl/palletconfig'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load pallet configs: ${response.statusCode}');
    }
  }

  Future<void> addPalletConfig(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/palletconfig'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add pallet config');
    }
  }
}