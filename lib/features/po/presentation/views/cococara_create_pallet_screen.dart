import 'dart:convert';
import 'package:http/http.dart' as http; 
import 'package:ccpladmin/helpers/api_url.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';

import 'package:get/get.dart';
import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:ccpladmin/features/masters/presentation/views/pallet_list_screen.dart';
import 'package:flutter/material.dart';

class CococaraCreatePalletScreen extends StatefulWidget {
  final String? shippingId; 

  const CococaraCreatePalletScreen({super.key, this.shippingId});

  @override
  State<CococaraCreatePalletScreen> createState() => _CococaraCreatePalletScreenState();
}

class _CococaraCreatePalletScreenState extends State<CococaraCreatePalletScreen> with UIMixin {
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = false;
  final String _baseUrl = ApiUrl.baseUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      
      final response = await http.get(Uri.parse('$_baseUrl/create-pallet'));
      
      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);
        
        Map<String, Map<String, dynamic>> groupedData = {};
        int unassignedCounter = 0;

        for (var shipment in rawData) {
          if (widget.shippingId != null && shipment['shippingId'] != widget.shippingId) {
            continue;
          }
          
          String shippingId = shipment['shippingId']?.toString() ?? '';
          
          if (shipment['items'] != null) {
            for (var item in shipment['items']) {
              String cococaraId = item['cococaraPalletId']?.toString() ?? '';
              String tempId = item['tempPalletId']?.toString() ?? '';

              if (cococaraId.isEmpty || cococaraId == 'null') {
                String key = tempId.isNotEmpty ? '${shippingId}_$tempId' : '${shippingId}_unassigned_${unassignedCounter++}';

                if (groupedData.containsKey(key)) {
                  String currentSupplier = groupedData[key]!['supplier']?.toString() ?? '';
                  String newSupplier = item['supplier']?.toString() ?? '';
                  if (newSupplier.isNotEmpty && !currentSupplier.contains(newSupplier)) {
                    groupedData[key]!['supplier'] = currentSupplier.isEmpty ? newSupplier : '$currentSupplier, $newSupplier';
                  }
                } else {
                  groupedData[key] = {
                    'supplier': item['supplier'],
                    'tempPalletId': tempId,
                    'cococaraPalletId': item['cococaraPalletId'],
                    'itemCode': item['itemCode'],
                  };
                }
              }
            }
          }
        }

        setState(() {
          _data = groupedData.values.toList();
        });
      } else {
        debugPrint("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception loading data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAllPallets() async {
    if (widget.shippingId == null) {
      Utils.showErrorToast("No Shipping ID provided for generation.", context: context);
      return;
    }

    setState(() => _isLoading = true);
    int successCount = 0;
    int errorCount = 0;

    try {
      for (var data in _data) {
        String tempId = data['tempPalletId']?.toString() ?? '';
        String cococaraId = data['cococaraPalletId']?.toString() ?? '';

        if (tempId.isNotEmpty && (cococaraId.isEmpty || cococaraId == 'null')) {
          final response = await http.post(
            Uri.parse('$_baseUrl/generate-pallet/generate'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'shippingId': widget.shippingId,
              'tempPalletId': tempId,
            }),
          );

          if (response.statusCode == 200) {
            successCount++;
          } else {
            errorCount++;
            debugPrint("Failed to generate ID for $tempId: ${response.body}");
          }
        }
      }

      // Refresh data so generated items no longer appear
      await _loadData();

      if (mounted) {
        if (successCount > 0) {
          Utils.showSuccessToast("Pallet created successfully", context: context);
          Get.to(() => const PalletListScreen());
        } else if (errorCount > 0) {
          Utils.showErrorToast("Generated $successCount pallets, failed $errorCount.", context: context);
        } else {
          Utils.showInfoToast("No new pallets to generate.", context: context);
        }
      }
    } catch (e) {
      debugPrint("Error generating IDs: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  "Cococara Create Pallet",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Pallet Details', route: '/po/pallet_details'),
                    MyBreadcrumbItem(name: 'Create Pallet', route: '/po/create_pallet'),
                    MyBreadcrumbItem(name: 'Cococara Create', active: true),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing),
          Padding(
            padding: MySpacing.x(flexSpacing / 2),
            child: MyCard(
              paddingAll: 24,
              borderRadiusAll: 8,
              shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    Center(child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ))
                  else
                    LayoutBuilder(builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: DataTable(
                              headingRowColor: WidgetStatePropertyAll(contentTheme.primary.withValues(alpha: 40 / 255)),
                              dividerThickness: 0,
                              headingTextStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: contentTheme.onBackground,
                              ),
                              dataTextStyle: TextStyle( 
                                color: contentTheme.onBackground,
                                fontSize: 13,
                              ),
                              columns: [
                                DataColumn(label: MyText.labelLarge("Supplier", fontWeight: 600)),
                                DataColumn(label: MyText.labelLarge("Temp Pallet ID", fontWeight: 600)),
                                DataColumn(label: MyText.labelLarge("Cococara Pallet ID", fontWeight: 600)),
                              ],
                              rows: _data.map((data) {
                                String tempId = data['tempPalletId']?.toString() ?? '';
                                return DataRow(cells: [
                                  DataCell(MyText.bodyMedium(data['supplier'] ?? '')),
                                  DataCell(MyText.bodyMedium(tempId)),
                                  DataCell(MyText.bodyMedium(data['cococaraPalletId']?.toString() ?? '')),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    }),
                  MySpacing.height(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyButton.text(
                        onPressed: () => Navigator.pop(context),
                        child: MyText.labelMedium("Back"),
                      ),
                      MySpacing.width(16),
                      MyButton.rounded(
                        onPressed: _isLoading ? null : _generateAllPallets,
                        elevation: 0,
                        padding: MySpacing.xy(16, 12),
                        backgroundColor: contentTheme.primary,
                        child: MyText.labelMedium(
                          "Generate",
                          color: contentTheme.onPrimary,
                          fontWeight: 600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
