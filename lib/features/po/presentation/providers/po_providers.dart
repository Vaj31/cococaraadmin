import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:ccpladmin/model/polist_model.dart';
import 'package:ccpladmin/services/purchase_order_service.dart';

class PolistState {
  final List<PolistModel> po;
  final bool isLoading;

  PolistState({
    this.po = const [],
    this.isLoading = false,
  });

  PolistState copyWith({
    List<PolistModel>? po,
    bool? isLoading,
  }) {
    return PolistState(
      po: po ?? this.po,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PolistNotifier extends StateNotifier<PolistState> {
  final PurchaseOrderService _service = PurchaseOrderService();
  PolistNotifier() : super(PolistState()) {
    fetchPolist();
  }

  Future<void> fetchPolist() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _service.getPurchaseOrders();
      final mapped = response.map((e) => PolistModel.fromJson(e)).toList();
      state = state.copyWith(po: mapped, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> deletePolist(String orderId) async {
    try {
      await _service.deletePurchaseOrder(orderId);
      await fetchPolist();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePolist(String orderId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updatePurchaseOrder(orderId, data);
      await fetchPolist();
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> syncWithGoogle() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _service.syncWithGoogle();
      if (response.statusCode == 200) {
        await fetchPolist();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final polistProvider = StateNotifierProvider<PolistNotifier, PolistState>((ref) {
  return PolistNotifier();
});

// --- PENDING ORDERS FUTURE PROVIDER ---
final pendingOrdersProvider = FutureProvider.autoDispose<List<Map<String, String>>>((ref) async {
  final response = await http.get(Uri.parse('${ApiUrl.baseUrl}/shippingschedules'));

  if (response.statusCode == 200) {
    final List<dynamic> rawData = json.decode(response.body);
    List<Map<String, String>> parsedData = [];

    List<String> extractSuppliers(dynamic data, [List<String>? fallback]) {
      if (data == null) {
        return fallback ?? ['-'];
      }
      List<String> sups = [];
      if (data['supplier1'] != null && data['supplier1'].toString().trim().isNotEmpty) {
        sups.add(data['supplier1'].toString().trim());
      }
      if (data['supplier2'] != null && data['supplier2'].toString().trim().isNotEmpty) {
        sups.add(data['supplier2'].toString().trim());
      }
      if (data['supplier3'] != null && data['supplier3'].toString().trim().isNotEmpty) {
        sups.add(data['supplier3'].toString().trim());
      }
      if (sups.isNotEmpty) {
        return sups.toSet().toList();
      }
      
      String singleSup = data['supplier']?.toString() ?? data['supplierid']?.toString() ?? data['supplierId']?.toString() ?? data['supplier_id']?.toString() ?? '';
      if (singleSup.isNotEmpty) {
        return [singleSup];
      }
      return fallback ?? ['-'];
    }

    for (var item in rawData) {
      bool isFlat = item.containsKey('orderId') || item.containsKey('orderid') || item.containsKey('itemCode') || item.containsKey('itemcode');

      if (isFlat) {
        double qty = double.tryParse(item['qty']?.toString() ?? item['orderQty']?.toString() ?? '0') ?? 0;
        double compQty = double.tryParse(item['completed_qty']?.toString() ?? item['compQty']?.toString() ?? '0') ?? 0;
        double assignedQty = double.tryParse(item['assigned_qty']?.toString() ?? item['assignedQty']?.toString() ?? item['assignedqty']?.toString() ?? '0') ?? 0;
        double pendQty = assignedQty - compQty;
        if (pendQty < 0) {
          pendQty = 0;
        }

        List<String> suppliers = extractSuppliers(item);
        
        String rawShipId = item['shippingid']?.toString() ?? item['shippingId']?.toString() ?? item['shipId']?.toString() ?? '';
        String shipId = (rawShipId.isEmpty || rawShipId.toLowerCase() == 'null' || rawShipId == '-') ? 'Not Assigned' : rawShipId;
        
        for (String sup in suppliers) {
          parsedData.add({
            'supplier': sup,
            'shipId': shipId,
            'orderId': item['orderId']?.toString() ?? item['orderid']?.toString() ?? '-',
            'itemCode': item['itemcode']?.toString() ?? item['itemCode']?.toString() ?? '-',
            'orderQty': qty.toInt().toString(),
            'assignedQty': assignedQty.toInt().toString(),
            'compQty': compQty.toInt().toString(),
            'pendQty': pendQty.toInt().toString(),
          });
        }
      } else if (item.containsKey('items') && item['items'] is List) {
        String rawShipId = item['shippingId']?.toString() ?? item['shippingid']?.toString() ?? '';
        String shipId = (rawShipId.isEmpty || rawShipId.toLowerCase() == 'null' || rawShipId == '-') ? 'Not Assigned' : rawShipId;
        
        List<String> shipSuppliers = extractSuppliers(item);

        for (var subItem in item['items']) {
          if (subItem['layers'] != null && subItem['layers'] is List) {
            List<String> subItemSuppliers = extractSuppliers(subItem, shipSuppliers);
            for (var layer in subItem['layers']) {
              double qty = double.tryParse(layer['countOfPackage']?.toString() ?? layer['qty']?.toString() ?? '0') ?? 0;
              double compQty = double.tryParse(layer['completed_qty']?.toString() ?? layer['compQty']?.toString() ?? '0') ?? 0;
              double assignedQty = double.tryParse(layer['assigned_qty']?.toString() ?? layer['assignedQty']?.toString() ?? layer['assignedqty']?.toString() ?? '0') ?? 0;
              double pendQty = assignedQty - compQty;
              if (pendQty < 0) {
                pendQty = 0;
              }

              List<String> layerSuppliers = extractSuppliers(layer, subItemSuppliers);
              for (String sup in layerSuppliers) {
                parsedData.add({
                  'supplier': sup,
                  'shipId': shipId,
                  'orderId': layer['orderId']?.toString() ?? layer['orderid']?.toString() ?? '-',
                  'itemCode': layer['itemCode']?.toString() ?? layer['itemcode']?.toString() ?? '-',
                  'orderQty': qty.toInt().toString(),
                  'assignedQty': assignedQty.toInt().toString(),
                  'compQty': compQty.toInt().toString(),
                  'pendQty': pendQty.toInt().toString(),
                });
              }
            }
          }
        }
      }
    }

    List<Map<String, String>> uniqueData = [];
    Set<String> seen = {};
    for (var row in parsedData) {
      String key = "${row['shipId']}_${row['orderId']}_${row['itemCode']}_${row['supplier']}";
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueData.add(row);
      }
    }

    return uniqueData;
  } else {
    throw Exception("Failed to load data: ${response.statusCode}");
  }
});
