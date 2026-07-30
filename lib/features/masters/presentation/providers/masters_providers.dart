import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ccpladmin/services/customer_service.dart';
import 'package:ccpladmin/services/supplier_service.dart';
import 'package:ccpladmin/services/create_pallet_service.dart';

// --- CUSTOMERS ---
class CustomerListNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  CustomerListNotifier() : super(const AsyncLoading()) {
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    state = const AsyncLoading();
    try {
      final data = await CustomerService.getCustomers();
      state = AsyncData(data.map((e) => e as Map<String, dynamic>).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> deleteCustomer(int id) async {
    try {
      await CustomerService.deleteCustomer(id);
      await fetchCustomers();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final customerListProvider = StateNotifierProvider<CustomerListNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return CustomerListNotifier();
});

// --- SUPPLIERS ---
class SupplierListNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final SupplierService _service = SupplierService();
  SupplierListNotifier() : super(const AsyncLoading()) {
    fetchSuppliers();
  }

  Future<void> fetchSuppliers() async {
    state = const AsyncLoading();
    try {
      final List<dynamic> data = await _service.getSuppliers();
      final mapped = data.map((item) {
        dynamic rawMachines = item['machines'] ?? item['machinecodes'] ?? item['machineCodes'];
        List<String> parsedMachines = [];
        if (rawMachines is List) {
          parsedMachines = rawMachines.map((e) => e.toString()).toList();
        } else if (rawMachines is String && rawMachines.isNotEmpty) {
          parsedMachines = rawMachines.split(',').map((e) => e.trim()).toList();
        }
        parsedMachines = parsedMachines.where((e) => e.isNotEmpty).toSet().toList();

        String getVal(List<String> keys) {
          for (var key in keys) {
            if (item.containsKey(key) && item[key] != null) {
              return item[key].toString();
            }
          }
          return '';
        }

        String officeAddress1 = getVal(['officeaddressline1', 'officeAddressLine1']);
        String officeAddress2 = getVal(['officeaddressline2', 'officeAddressLine2']);
        String officeCity = getVal(['officecity', 'officeCity']);
        String officeState = getVal(['officestate', 'officeState']);
        String officePincode = getVal(['officepincode', 'officePincode']);
        
        String factoryAddress1 = getVal(['factoryaddressline1', 'factoryAddressLine1']);
        String factoryAddress2 = getVal(['factoryaddressline2', 'factoryAddressLine2']);
        String factoryCity = getVal(['factorycity', 'factoryCity']);
        String factoryState = getVal(['factorystate', 'factoryState']);
        String factoryPincode = getVal(['factorypincode', 'factoryPincode']);

        return {
          'supplierId': getVal(['supplierid', 'supplierId']),
          'supplierName': getVal(['suppliername', 'supplierName']),
          'shortName': getVal(['shortname', 'shortName']),
          'contactPerson': getVal(['contactperson', 'contactPerson']),
          'phone': getVal(['phone', 'Phone']),
          'email': getVal(['email', 'Email']),
          'officeAddressLine1': officeAddress1,
          'officeAddressLine2': officeAddress2,
          'officeCity': officeCity,
          'officeState': officeState,
          'officePincode': officePincode,
          'factoryAddressLine1': factoryAddress1,
          'factoryAddressLine2': factoryAddress2,
          'factoryCity': factoryCity,
          'factoryState': factoryState,
          'factoryPincode': factoryPincode,
          'machineCodesList': parsedMachines,
          'machineCodes': parsedMachines.join(', '),
          'officeAddress': getVal(['officeAddress', 'office_address']).isNotEmpty 
              ? getVal(['officeAddress', 'office_address']) 
              : [officeAddress1, officeAddress2, officeCity, officeState, officePincode].where((s) => s.isNotEmpty).join(', '),
          'factoryAddress': getVal(['factoryAddress', 'factory_address']).isNotEmpty 
              ? getVal(['factoryAddress', 'factory_address']) 
              : [factoryAddress1, factoryAddress2, factoryCity, factoryState, factoryPincode].where((s) => s.isNotEmpty).join(', '),
        };
      }).toList();
      state = AsyncData(mapped);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> deleteSupplier(String id) async {
    try {
      final response = await _service.deleteSupplier(id);
      if (response.statusCode == 200) {
        await fetchSuppliers();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

final supplierListProvider = StateNotifierProvider<SupplierListNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return SupplierListNotifier();
});

// --- PALLETS ---
class PalletListNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  PalletListNotifier() : super(const AsyncLoading()) {
    fetchPallets();
  }

  Future<void> fetchPallets() async {
    state = const AsyncLoading();
    try {
      final data = await CreatePalletService.getAll();
      Map<String, Map<String, dynamic>> groupedData = {};
      int unassignedCounter = 0;

      for (var shipment in data) {
        String shippingId = shipment['shippingId']?.toString() ?? '';
        if (shipment['items'] != null) {
          for (var item in shipment['items']) {
            String cococaraId = item['cococaraPalletId']?.toString() ?? '';
            if (cococaraId == 'null') cococaraId = '';
            String tempId = item['tempPalletId']?.toString() ?? '';
            if (tempId == 'null') tempId = '';

            String keyId = tempId.isNotEmpty ? tempId : cococaraId;
            String key = keyId.isNotEmpty ? '${shippingId}_$keyId' : '${shippingId}_unassigned_${unassignedCounter++}';

            if (!groupedData.containsKey(key)) {
              groupedData[key] = {
                'shippingId': shippingId,
                'supplier': item['supplier']?.toString() ?? '',
                'tempPalletId': tempId,
                'cococaraPalletId': cococaraId,
                'palletHeight': item['palletHeight']?.toString() ?? item['palletheight']?.toString() ?? '',
                'netWeight': item['netWeight']?.toString() ?? item['netweight']?.toString() ?? '',
                'grossWeight': item['grossWeight']?.toString() ?? item['grossweight']?.toString() ?? '',
                'totalPackage': '0',
                'layerDetails': <Map<String, String>>[],
              };
            }

            if (item['layers'] != null) {
              String currentOrderId = item['orderId']?.toString() ?? item['orderid']?.toString() ?? '';
              String currentItemCode = item['itemCode']?.toString() ?? item['itemcode']?.toString() ?? '';

              List<String> orderIds = currentOrderId.isNotEmpty ? currentOrderId.split('~') : [];
              List<String> itemCodes = currentItemCode.isNotEmpty ? currentItemCode.split('~') : [];

              int index = 0;
              for (var layer in item['layers']) {
                String layerOrderId = index < orderIds.length 
                    ? orderIds[index] 
                    : (orderIds.isNotEmpty ? orderIds.first : '');
                String layerItemCode = index < itemCodes.length 
                    ? itemCodes[index] 
                    : (itemCodes.isNotEmpty ? itemCodes.first : '');

                String finalOrderId = layerOrderId.isNotEmpty ? layerOrderId : (layer['orderId']?.toString() ?? layer['orderid']?.toString() ?? '');
                String finalItemCode = layerItemCode.isNotEmpty ? layerItemCode : (layer['itemCode']?.toString() ?? layer['itemcode']?.toString() ?? '');

                (groupedData[key]!['layerDetails'] as List<Map<String, String>>).add({
                  'layerNumber': layer['layerNumber']?.toString() ?? '',
                  'orderId': finalOrderId.trim(),
                  'itemCode': finalItemCode.trim(),
                  'packageType': layer['packageType']?.toString() ?? layer['packagetype']?.toString() ?? '',
                  'countOfPackage': layer['countOfPackage']?.toString() ?? layer['countofpackage']?.toString() ?? '',
                });
                
                index++;
              }
            }
          }
        }
      }

      groupedData.forEach((key, palletData) {
        int total = 0;
        if (palletData['layerDetails'] != null) {
          for (var layer in (palletData['layerDetails'] as List<Map<String, String>>)) {
            total += int.tryParse(layer['countOfPackage'] ?? '0') ?? 0;
          }
        }
        palletData['totalPackage'] = total.toString();
      });

      var finalData = groupedData.values.toList();
      for (var pallet in finalData) {
        (pallet['layerDetails'] as List<Map<String, String>>).sort((a, b) {
          int layerA = int.tryParse(a['layerNumber'] ?? '0') ?? 0;
          int layerB = int.tryParse(b['layerNumber'] ?? '0') ?? 0;
          return layerA.compareTo(layerB);
        });
      }
      state = AsyncData(finalData);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final palletListProvider = StateNotifierProvider<PalletListNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return PalletListNotifier();
});
