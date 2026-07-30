import 'dart:convert';
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:http/http.dart' as http;

class PurchaseOrderService {
  final String baseUrl = '${ApiUrl.baseUrl}/purchaseorders';

  Future<List<dynamic>> getPurchaseOrders() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load purchase orders: ${response.statusCode}');
    }
  } 

  Future<dynamic> getPurchaseOrder(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/${Uri.encodeComponent(id)}'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      String errorMessage = 'Failed to load purchase order: ${response.statusCode}';
      try {
        // Try to parse a message from the error response body
        final errorBody = json.decode(response.body);
        errorMessage += ' - ${errorBody['message'] ?? response.body}';
      } catch (_) {
        // Ignore if the body isn't valid JSON or has no message.
      }
      throw Exception(errorMessage);
    }
  }

  Future<http.Response> createPurchaseOrder(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
  }

  Future<http.Response> updatePurchaseOrder(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${Uri.encodeComponent(id)}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      String errorMessage =
          'Failed to update purchase order: ${response.statusCode}';
      try {
        final errorBody = json.decode(response.body);
        errorMessage += ' - ${errorBody['message'] ?? response.body}';
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<http.Response> deletePurchaseOrder(String id) async {
    return await http.delete(
      Uri.parse('$baseUrl/${Uri.encodeComponent(id)}'),
    );
  }

  Future<http.Response> syncWithGoogle() async {
    return await http.post(
      Uri.parse('${ApiUrl.baseUrl}/googlesync/purchase-orders'),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
