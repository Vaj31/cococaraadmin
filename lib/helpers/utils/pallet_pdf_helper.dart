import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ccpladmin/helpers/api_url.dart';

class PalletPdfHelper {
  static Future<void> generatePalletLabel(Map<String, dynamic> pallet) async {
  
    final logoData = await rootBundle.load('assets/images/logo/logo-sm.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    String? getValue(List<String> keys) {
      for (var key in keys) {
        final lowerKey = key.toLowerCase();
        for (var k in pallet.keys) {
          if (k.toLowerCase() == lowerKey) {
            if (pallet[k] != null && pallet[k].toString().trim().isNotEmpty) {
              return pallet[k].toString().trim();
            }
          }
        }
      }
      return null;
    }

    List<String> splitData(String data) {
      if (data.isEmpty) {
        return [];
      }
      return data.split(RegExp(r'[,|\n\r~]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    final orderIdStr = getValue(['orderId', 'orderNo']) ?? '';
    final itemCodeStr = getValue(['itemCode', 'productCode']) ?? '';
    final shipmentIdStr = getValue(['shipmentId']) ?? 'N/A';

    // Fetch dynamic destination
    String destinationStr = "";
    try {
      final orderIds = splitData(orderIdStr);
      final itemCodes = splitData(itemCodeStr);
      final firstOrderId = orderIds.isNotEmpty ? orderIds.first : '';
      final firstItemCode = itemCodes.isNotEmpty ? itemCodes.first : '';

      if (shipmentIdStr != 'N/A' && firstOrderId.isNotEmpty && firstItemCode.isNotEmpty) {
        final url = Uri.parse('${ApiUrl.baseUrl}/portmaster/destination?shippingId=$shipmentIdStr&orderId=$firstOrderId&itemCode=$firstItemCode');
        final response = await http.get(url);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['portfullname'] != null && data['country'] != null) {
            destinationStr = "${data['portfullname'].toString().toUpperCase()} / ${data['country'].toString().toUpperCase()}";
          }
        }
      }
    } catch (e) {
    }

    final pdf = pw.Document();

  
    final border = pw.Border.all(width: 4, color: PdfColors.black);
    final labelStyle = const pw.TextStyle(fontSize: 14, color: PdfColors.grey700);
    final valueStyle = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          Map<String, double> packageCounts = {};
          double calculatedTotalPackages = 0;
          bool hasLayers = false;
          
          if (pallet['layers'] != null && pallet['layers'] is List) {
            for (var layer in pallet['layers']) {
              final countStr = layer['count']?.toString() ?? layer['countofpackage']?.toString() ?? layer['countOfPackage']?.toString() ?? '0';
              final count = double.tryParse(countStr) ?? 0;
              
              if (count > 0) {
                String pType = (layer['packagetype']?.toString() ?? layer['packageType']?.toString() ?? '').trim();
                if (pType.isEmpty) {
                  pType = getValue(['packageType'])?.split(',').first.trim() ?? 'Package';
                }
                
                final lowerPType = pType.toLowerCase();
                if (lowerPType == 'box') {
                  pType = 'Box';
                } else if (lowerPType == 'bundle') {
                  pType = 'Bundle';
                } else if (lowerPType == 'item') {
                  pType = 'Item';
                } else if (pType.isEmpty) {
                  pType = 'Package';
                }
                
                packageCounts[pType] = (packageCounts[pType] ?? 0) + count;
                calculatedTotalPackages += count;
                hasLayers = true;
              }
            }
          }

          final totalPkgStr = hasLayers && calculatedTotalPackages > 0 
              ? (calculatedTotalPackages == calculatedTotalPackages.toInt() ? calculatedTotalPackages.toInt().toString() : calculatedTotalPackages.toString())
              : (getValue(['totalPackages', 'totalPackage', 'totalpackages', 'totalpackage', 'noofpackage', 'no of package']) ?? getValue(['palletQty', 'palletqty']) ?? '0');
          final sizeStr = getValue(['size', 'sizes']);
          
          String palletNoStr;
          final palletId = getValue(['id', 'palletId', 'palletid']);
          if (palletId != null && palletId.contains('-')) {
            final parts = palletId.split('-');
            final lastPart = parts.last;
            if (int.tryParse(lastPart) != null) {
              palletNoStr = lastPart;
            } else {
              palletNoStr = '01';
            }
          } else {
            palletNoStr = getValue(['palletNo']) ?? '01';
          }

          final ccplPalletIdRaw = getValue(['ccplPalletId', 'productionApproval']) ?? '-';
          
          List<String> ccplPalletIds = splitData(ccplPalletIdRaw);
          String ccplPalletIdStr = ccplPalletIdRaw; // Default to raw value
          if (ccplPalletIds.length > 1) {
            final palletNoInt = int.tryParse(palletNoStr) ?? 1;
            final index = palletNoInt - 1;
            if (index >= 0 && index < ccplPalletIds.length) {
              ccplPalletIdStr = ccplPalletIds[index];
            } else if (ccplPalletIds.isNotEmpty) {
              ccplPalletIdStr = ccplPalletIds.first; // Fallback
            }
          }

          final netWeightStr = getValue(['netWeight']) ?? '0.00';
          final grossWeightStr = getValue(['grossWeight']) ?? '0.00';
          
          String fallbackPkgType = getValue(['packageType'])?.split(',').first.trim() ?? '';
          String fallbackPkgLabel;
          if (fallbackPkgType.toLowerCase() == 'box') {
            fallbackPkgLabel = 'No of Boxes';
          } else if (fallbackPkgType.toLowerCase() == 'bundle') {
            fallbackPkgLabel = 'No of Bundles';
          } else if (fallbackPkgType.toLowerCase() == 'item') {
            fallbackPkgLabel = 'No of Items';
          } else {
            fallbackPkgLabel = 'No of Packages';
          }

          String sumData(String data) {
            if (data.isEmpty) {
              return '0';
            }
            final parts = splitData(data);
            if (parts.length <= 1) {
              return data;
            }
            double total = 0;
            for (var p in parts) {
              total += double.tryParse(p) ?? 0;
            }
            return total == total.toInt() ? total.toInt().toString() : total.toStringAsFixed(2);
          }

          List<String> orderIds = splitData(orderIdStr);
          bool isMultipleOrders = orderIds.length > 1;

          List<String> itemCodes = splitData(itemCodeStr);
          splitData(totalPkgStr);
          List<String> sizes = sizeStr != null ? splitData(sizeStr) : [];

          String getSafe(List<String> list, int index, [String fallback = 'N/A']) {
            if (index < list.length) {
              return list[index];
            }
            if (list.isNotEmpty) {
              return list.first;
            }
            return fallback;
          }

          String getCodeSize(String? code, int index) {
            if (index < sizes.length) {
              return sizes[index];
            }
            if (sizes.isNotEmpty) {
              return sizes.first;
            }
            
            if (code == null || code.isEmpty) {
              return "N/A";
            }
            final parts = code.split('-');
            if (parts.length > 3) {
              return '${parts[3]} cm';
            }
            return "N/A";
          }

          return pw.Center(
            child: pw.Container(
              width: 500,
              child: pw.Stack(
                children: [
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(10),
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                          border: pw.Border(bottom: pw.BorderSide(width: 4, color: PdfColors.black)),
                        ),
                        child: pw.Center(
                          child: pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Image(logoImage, height: 24),
                              pw.SizedBox(width: 10),
                              pw.Text("COCOCARA", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      pw.Row(
                        children: [
                          _buildCell("PALLET NO:", palletNoStr, flex: 1, borderRight: true),
                          _buildCell("DESTINATION:", destinationStr, flex: 1),
                        ],
                      ),
                      _divider(),
                      if (isMultipleOrders) ...[
                        _buildFullWidthCell("SHIPMENT ID: $shipmentIdStr"),
                        _divider(),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                decoration: const pw.BoxDecoration(
                                  border: pw.Border(right: pw.BorderSide(width: 4, color: PdfColors.black)),
                                ),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("ORDER NO: ${orderIds[0]}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                    pw.SizedBox(height: 4),
                                    pw.Text("PRODUCT CODE: ${getSafe(itemCodes, 0)}", style: const pw.TextStyle(fontSize: 12)),
                                    pw.SizedBox(height: 2),
                                    pw.Text("SIZE: ${getCodeSize(getSafe(itemCodes, 0, ''), 0)}", style: const pw.TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("ORDER NO: ${getSafe(orderIds, 1)}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                    pw.SizedBox(height: 4),
                                    pw.Text("PRODUCT CODE: ${getSafe(itemCodes, 1)}", style: const pw.TextStyle(fontSize: 12)),
                                    pw.SizedBox(height: 2),
                                    pw.Text("SIZE: ${getCodeSize(getSafe(itemCodes, 1, ''), 1)}", style: const pw.TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        _divider(),
                      ] else ...[
                        _buildFullWidthCell("ORDER NO: ${orderIds.isNotEmpty ? orderIds[0] : 'N/A'}"),
                        _divider(),
                        _buildFullWidthCell("SHIPMENT ID: $shipmentIdStr"),
                        _divider(),
                        pw.Row(
                          children: [
                            _buildCell("PRODUCT CODE:", getSafe(itemCodes, 0), flex: 1, borderRight: true, valueFontSize: 12),
                            _buildCell("Size:", getCodeSize(getSafe(itemCodes, 0, ''), 0), flex: 1),
                          ],
                        ),
                        _divider(),
                      ],
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Column(
                          children: [
                            pw.Text("PRODUCTION APPROVAL DETAILS", style: labelStyle),
                            pw.Text(ccplPalletIdStr, style: valueStyle),
                          ],
                        ),
                      ),
                      _divider(),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            flex: 1,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(right: pw.BorderSide(width: 4, color: PdfColors.black)),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text("QUANTITY DETAILS:", style: const pw.TextStyle(fontSize: 12)),
                                  pw.SizedBox(height: 10),
                                  if (packageCounts.isNotEmpty)
                                    ...packageCounts.entries.map((e) {
                                      String lbl;
                                      final keyLower = e.key.toLowerCase();
                                      if (keyLower == 'box') {
                                        lbl = 'No of Boxes';
                                      } else if (keyLower == 'bundle') {
                                        lbl = 'No of Bundles';
                                      } else if (keyLower == 'item') {
                                        lbl = 'No of Items';
                                      } else {
                                        lbl = 'No of Packages';
                                      }
                                      
                                      String val = e.value == e.value.toInt() ? e.value.toInt().toString() : e.value.toStringAsFixed(2);
                                      return pw.Padding(
                                        padding: const pw.EdgeInsets.only(bottom: 4),
                                        child: pw.Text("$lbl: $val", style: valueStyle),
                                      );
                                    })
                                  else
                                    pw.Text("$fallbackPkgLabel: ${sumData(totalPkgStr)}", style: valueStyle),
                                ],
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text("WEIGHT DETAILS:", style: const pw.TextStyle(fontSize: 12)),
                                  pw.SizedBox(height: 10),
                                  pw.Text("Net Weight: ${sumData(netWeightStr)}", style: valueStyle),
                                  pw.SizedBox(height: 2),
                                  pw.Text("Gross Weight: ${sumData(grossWeightStr)}", style: valueStyle),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Positioned.fill(
                    child: pw.Container(
                      decoration: pw.BoxDecoration(border: border),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _divider() => pw.Container(height: 4, color: PdfColors.black);

  static pw.Widget _buildCell(String label, String value, {int flex = 1, bool borderRight = false, double valueFontSize = 16}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: borderRight ? const pw.BoxDecoration(border: pw.Border(right: pw.BorderSide(width: 4, color: PdfColors.black))) : null,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Text(value, style: pw.TextStyle(fontSize: valueFontSize, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildFullWidthCell(String text) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
    );
  }
}
