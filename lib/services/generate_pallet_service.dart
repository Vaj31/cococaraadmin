import 'dart:convert';
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:http/http.dart' as http;

class GeneratePalletService {
  static String baseUrl = '${ApiUrl.baseUrl}/generate-pallet';

  static Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        return jsonData.map((item) {
          return {
            'shippingId': item['shippingid']?.toString() ?? '',
            'pod': item['pod']?.toString() ?? '',
            // The backend now returns a comma-separated string of supplier pallet IDs
            'supplierPalletId': item['supplier_pallets']?.toString() ?? '',
            // This will now be populated with a comma-separated string of generated IDs
            'ccplPalletId': item['ccplPalletId']?.toString() ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load pallet data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  
  static Future<void> generateCcplPalletId(String shippingId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'shippingId': shippingId}),
      );

      if (response.statusCode != 200) {
        try {
          final error = json.decode(response.body);
          throw Exception('Failed to generate CCPL Pallet ID: ${error['message']}');
        } catch (_) {
          throw Exception('Failed to generate CCPL Pallet ID');
        }
      }
    } catch (e) {
      throw Exception('Error generating ID: $e');
    }
  }
}
