import 'dart:convert';
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:http/http.dart' as http;

class PoMasterService {
  final String _apiUrl = "${ApiUrl.baseUrl}/pomaster";

  Future<Map<String, dynamic>> getPoMasterData() async {
    final response = await http.get(Uri.parse(_apiUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load PO Master data: ${response.statusCode}');
    }
  }

  Future<void> addMasterData(String table, String column, String value) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'table': table,
        'column': column,
        'value': value,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add master data');
    }
  }
}