import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_flex.dart';
import 'package:ccpladmin/helpers/widgets/my_flex_item.dart';
import 'package:ccpladmin/view/layouts/layout.dart'; 
import 'package:ccpladmin/services/admin_pallet_service.dart';
import 'package:flutter/material.dart';
import 'package:ccpladmin/helpers/utils/pallet_pdf_helper.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:ccpladmin/helpers/widgets/app_dropdown.dart';

class PalletStickeringScreen extends StatefulWidget {
  const PalletStickeringScreen({super.key});

  @override
  State<PalletStickeringScreen> createState() => _PalletStickeringScreenState();
}

class _PalletStickeringScreenState extends State<PalletStickeringScreen> with UIMixin {
  List<String> shippingIds = [];
  String? selectedShippingId;
  List<Map<String, dynamic>> _allPalletData = [];
  List<Map<String, dynamic>> _selectedPallets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShippingIds();
  }

  Future<void> _fetchShippingIds() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await AdminPalletService.getAll();
      
      Map<String, Map<String, dynamic>> groupedPallets = {};
      int unassignedCounter = 0;
        
    
      for (var item in data) {
        Map<String, dynamic> newItem = Map<String, dynamic>.from(item);
        
        
        newItem['shippingId'] = newItem['shipmentId'];
        
        String ccplId = newItem['ccplPalletId']?.toString() ?? '';
        if (ccplId == 'null') ccplId = '';
        String tempId = newItem['tempPalletId']?.toString() ?? newItem['id']?.toString() ?? newItem['palletId']?.toString() ?? '';
        if (tempId == 'null') tempId = '';
        
        String keyId = ccplId.isNotEmpty ? ccplId : tempId;
        String shippingId = newItem['shippingId']?.toString() ?? '';
        String key = keyId.isNotEmpty ? '${shippingId}_$keyId' : '${shippingId}_unassigned_${unassignedCounter++}';
        
        if (!groupedPallets.containsKey(key)) {
          groupedPallets[key] = newItem;
          groupedPallets[key]!['layers'] = newItem['layers'] != null ? List<dynamic>.from(newItem['layers']) : [];
        } else {
          
          List<String> existingOrders = (groupedPallets[key]!['orderId']?.toString() ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          String newOrderId = newItem['orderId']?.toString().trim() ?? '';
          if (newOrderId.isNotEmpty && !existingOrders.contains(newOrderId)) {
            existingOrders.add(newOrderId);
            groupedPallets[key]!['orderId'] = existingOrders.join(', ');
          }
          
        
          List<String> existingItems = (groupedPallets[key]!['itemCode']?.toString() ?? '').split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          String newItemCode = newItem['itemCode']?.toString().trim() ?? '';
          if (newItemCode.isNotEmpty && !existingItems.contains(newItemCode)) {
            existingItems.add(newItemCode);
            groupedPallets[key]!['itemCode'] = existingItems.join(', ');
          }
          
          
          if (newItem['layers'] != null) {
            (groupedPallets[key]!['layers'] as List).addAll(newItem['layers']);
          }
        }
      }

      List<Map<String, dynamic>> mappedData = groupedPallets.values.toList();

      for (var pallet in mappedData) {
        if (pallet['layers'] != null && (pallet['layers'] as List).isNotEmpty) {
          double total = 0;
          for (var layer in pallet['layers']) {
            String countStr = layer['count']?.toString() ?? layer['countofpackage']?.toString() ?? '0';
            total += double.tryParse(countStr) ?? 0;
          }
          pallet['totalPackage'] = total % 1 == 0 ? total.toInt().toString() : total.toString();
        } else {
          pallet['totalPackage'] = '0';
        }
      }

      if (mounted) {
        setState(() {
          _allPalletData = mappedData;
          shippingIds = mappedData
              .where((item) =>
                  item['ccplPalletId'] != null &&
                  item['ccplPalletId'].toString().isNotEmpty &&
                  item['ccplPalletId'].toString() != 'null')
              .map((item) => item['shippingId'].toString())
              .toSet()
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _onShippingIdChanged(String? newValue) {
    setState(() {
      selectedShippingId = newValue;
      if (newValue != null) {
        _selectedPallets = _allPalletData.where((item) =>
                item['shippingId'].toString() == newValue &&
                item['ccplPalletId'] != null &&
                item['ccplPalletId'].toString().isNotEmpty &&
                item['ccplPalletId'].toString() != 'null').toList();
      } else {
        _selectedPallets = [];
      }
    });
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
                  "Pallet Stickering",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Pallet Stickering', active: true),
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
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    MyFlex(
                      contentPadding: false,
                      children: [
                        MyFlexItem(
                          sizes: 'lg-6 md-12',
                          child: _buildDropdown(
                            "Shipping ID",
                            selectedShippingId,
                            shippingIds,
                            _onShippingIdChanged,
                          ),
                        ),
                      ],
                    ),
                  if (selectedShippingId != null) ...[
                    MySpacing.height(24),
                    MyText.titleMedium("Pallets", fontWeight: 600),
                    MySpacing.height(16),
                    if (_selectedPallets.isEmpty)
                      Center(
                        child: Padding(
                          padding: MySpacing.y(20),
                          child: MyText.bodyMedium("No pallets found for this shipping ID.", color: contentTheme.onBackground.withAlpha(150)),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: contentTheme.onBackground.withAlpha(20)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _selectedPallets.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final Map<String, dynamic> pallet = entry.value;
                            final bool isLast = index == _selectedPallets.length - 1;

                            return Container(
                              decoration: BoxDecoration(
                                border: isLast ? null : Border(bottom: BorderSide(color: contentTheme.onBackground.withAlpha(20))),
                              ),
                              child: ExpansionTile(
                                tilePadding: MySpacing.x(16),
                                title: MyText.bodyMedium(
                                  "Pallet ID: ${pallet['ccplPalletId'] ?? 'N/A'}",
                                  fontWeight: 600,
                                ),
                                subtitle: MyText.bodySmall("Item Code: ${pallet['itemCode'] ?? '-'}"),
                                children: [
                                  Padding(
                                    padding: MySpacing.fromLTRB(16, 0, 16, 16),
                                    child: Column(
                                      children: [
                                        _buildPalletDetails(pallet),
                                        _buildLayerDetails(pallet),
                                        MySpacing.height(16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () => PalletPdfHelper.generatePalletLabel(pallet),
                                              icon: Icon(LucideIcons.printer, size: 16, color: contentTheme.primary),
                                              label: MyText.bodySmall("Print", color: contentTheme.primary),
                                              style: OutlinedButton.styleFrom(
                                                padding: MySpacing.xy(12, 8),
                                                side: BorderSide(color: contentTheme.primary.withAlpha(100)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalletDetails(Map<String, dynamic> pallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MySpacing.height(8),
        _buildDetailItem("CCPL Pallet ID", pallet['ccplPalletId']?.toString()),
        _buildDetailItem("Temp Pallet ID", pallet['tempPalletId']?.toString() ?? pallet['id']?.toString() ?? pallet['palletId']?.toString()),
        _buildDetailItem("Order ID", pallet['orderId']?.toString()),
        _buildDetailItem("Pallet Height", pallet['palletHeight']?.toString()),
        _buildDetailItem("Net Weight", pallet['netWeight']?.toString()),
        _buildDetailItem("Gross Weight", pallet['grossWeight']?.toString()),
      ],
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: MySpacing.bottom(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: MyText.bodySmall("$label:", color: contentTheme.onBackground.withAlpha(150)),
          ),
          Expanded(
            child: MyText.bodySmall(
              (value == null || value.isEmpty || value == 'null') ? '-' : value,
              fontWeight: 600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerDetails(Map<String, dynamic> pallet) {
    final layersRaw = pallet['layers'];
    if (layersRaw == null) return const SizedBox.shrink();
    List<dynamic> layers = layersRaw as List<dynamic>;
    if (layers.isEmpty) return const SizedBox.shrink();

    List<String> orderIds = (pallet['orderId']?.toString() ?? '').split(RegExp(r'[,~]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    List<String> itemCodes = (pallet['itemCode']?.toString() ?? '').split(RegExp(r'[,~]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MySpacing.height(16),
        MyText.bodyMedium("Layer Configuration", fontWeight: 600),
        MySpacing.height(8),
        Container(
          decoration: BoxDecoration(
            color: contentTheme.background.withAlpha(50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: MySpacing.xy(12, 8),
                  color: contentTheme.primary.withAlpha(20),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: MyText.bodySmall("Layer No", fontWeight: 600)),
                      Expanded(flex: 3, child: MyText.bodySmall("Order ID", fontWeight: 600)),
                      Expanded(flex: 3, child: MyText.bodySmall("Item Code", fontWeight: 600)),
                      Expanded(flex: 3, child: MyText.bodySmall("Total Package", fontWeight: 600)),
                    ],
                  ),
                ),
                ...layers.asMap().entries.map((entry) {
                  int index = entry.key;
                  var layer = entry.value;

                  String fallbackOrderId = index < orderIds.length ? orderIds[index] : (orderIds.isNotEmpty ? orderIds.first : '-');
                  String fallbackItemCode = index < itemCodes.length ? itemCodes[index] : (itemCodes.isNotEmpty ? itemCodes.first : '-');

                  String layerOrderId = layer['orderId']?.toString() ?? layer['orderid']?.toString() ?? '';
                  String layerItemCode = layer['itemCode']?.toString() ?? layer['itemcode']?.toString() ?? '';

                  String layerNo = layer['layerNumber']?.toString() ?? layer['layernumber']?.toString() ?? '-';
                  String orderId = layerOrderId.isNotEmpty ? layerOrderId : fallbackOrderId;
                  String itemCode = layerItemCode.isNotEmpty ? layerItemCode : fallbackItemCode;
                  String totalPackage = layer['countOfPackage']?.toString() ?? layer['countofpackage']?.toString() ?? layer['count']?.toString() ?? '0';
                  String packageType = (layer['packageType']?.toString() ?? layer['packagetype']?.toString() ?? '').toLowerCase();

                  String displayPackage = totalPackage;
                  if (packageType.isNotEmpty) {
                    String pluralPackageType = packageType.endsWith('s') ? packageType : '${packageType}s';
                    if (packageType == 'box') pluralPackageType = 'boxes';
                    displayPackage = '$totalPackage $pluralPackageType';
                  }
                  
                  return Container(
                    padding: MySpacing.xy(12, 6),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: contentTheme.onBackground.withAlpha(20))),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: MyText.bodySmall(layerNo)),
                        Expanded(flex: 3, child: MyText.bodySmall(orderId)),
                        Expanded(flex: 3, child: MyText.bodySmall(itemCode)),
                        Expanded(flex: 3, child: MyText.bodySmall(displayPackage)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(label, fontWeight: 600),
        MySpacing.height(8),
        AppDropdown<String>(
          value: value,
          items: items,
          hint: "Select $label",
          height: 42,
          isExpanded: true,
          onChanged: (val) => onChanged(val),
        ),
      ],
    );
  }
}