import 'dart:convert';
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:http/http.dart' as http;

class PortMasterService {
  final String _apiUrl = "${ApiUrl.baseUrl}/portmaster";

  Future<List<dynamic>> getPortMasterData() async {
    final response = await http.get(Uri.parse(_apiUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Port Master data: ${response.statusCode}');
    }
  }

  Future<void> addPortMasterData(String portShortName) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/add'), // Adjust the URL base if needed
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'portshortname': portShortName,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add port master data');
    }
  }
}
