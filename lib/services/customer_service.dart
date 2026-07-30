import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ccpladmin/helpers/api_url.dart';

class CustomerService {
  static String get baseUrl => '${ApiUrl.baseUrl}/customers';

  static Future<List<dynamic>> getCustomers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load customers');
    }
  }

  static Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create customer');
    }
  }

  static Future<Map<String, dynamic>> updateCustomer(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update customer');
    }
  }

  static Future<bool> deleteCustomer(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete customer');
    }
  }
}
