import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:http/http.dart' as http;

class SupplierService {
  final String baseUrl = "${ApiUrl.baseUrl}/suppliers";

  Future<List<dynamic>> getSuppliers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getProductionReport(Map<String, String> queryParams) async {
    try {
      final uri = Uri.parse("${ApiUrl.baseUrl}/production-report").replace(queryParameters: queryParams);
      debugPrint("Fetching Production Report: $uri");
      final response = await http.get(uri);
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Server Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error in getProductionReport: $e");
      rethrow;
    }
  }

  Future<http.Response> addSupplier(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(data),
    );
  }

  Future<http.Response> updateSupplier(String id, Map<String, dynamic> data) async {
    return await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(data),
    );
  }

  Future<http.Response> deleteSupplier(String id) async {
    return await http.delete(Uri.parse('$baseUrl/$id'));
  }

  Future<List<dynamic>> getAssignedSuppliers(String orderId, String itemCode) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/assigned?orderId=$orderId&itemCode=$itemCode'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching assigned suppliers: $e");
      return [];
    }
  }

  Future<http.Response> saveAssignedSuppliers(Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse('$baseUrl/assign'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(data),
    );
  }

  Future<List<dynamic>> getProductionByOrderAndItem(String orderId, String itemCode) async {
    try {
      final response = await http.get(Uri.parse('${ApiUrl.baseUrl}/supplier-production/by-order?orderId=$orderId&itemCode=$itemCode'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching daily production: $e");
      return [];
    }
  }

  Future<String> getNextPoNo(String supplierId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/next-po-no?supplierId=${Uri.encodeComponent(supplierId)}'));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['nextPoNo']?.toString() ?? '';
      }
      return '';
    } catch (e) {
      debugPrint("Error fetching next supplier PO number: $e");
      return '';
    }
  }
}