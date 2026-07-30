import 'dart:convert';
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:http/http.dart' as http;

class ShippingScheduleService {
  final String baseUrl = '${ApiUrl.baseUrl}/shippingschedules';

  Future<List<dynamic>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load shipping schedules: ${response.statusCode} ${response.body}');
    }
  }

  Future<dynamic> create(Map<String, dynamic> schedule) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(schedule),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create shipping schedule: ${response.statusCode} ${response.body}');
    }
  }

  Future<http.Response> delete(String id) async {
    return await http.delete(Uri.parse('$baseUrl/$id'));
  }

  Future<void> assignShippingToPOs(String shippingId, String? pol, String? color, List<Map<String, dynamic>> selectedPOs) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assign'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'shippingId': shippingId,
        'pol': pol,
        'color': color,
        'selectedPOs': selectedPOs,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to assign shipping ID');
    }
  }

  Future<void> syncWithGoogle() async {
    final response = await http.post(Uri.parse('${ApiUrl.baseUrl}/googlesync/purchase-orders'));
    if (response.statusCode != 200) {
      throw Exception('Failed to sync with Google: ${response.statusCode}');
    }
  }

  // --- NEW METHODS FOR THE DIFF VIEWER --- //

  Future<Map<String, dynamic>> getGoogleSyncDiffs() async {
    final response = await http.get(Uri.parse('${ApiUrl.baseUrl}/googlesync/diffs'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get diffs: ${response.statusCode}');
    }
  }

  Future<void> applyGoogleSync(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/googlesync/apply'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to apply sync: ${response.statusCode}');
    }
  }
}
