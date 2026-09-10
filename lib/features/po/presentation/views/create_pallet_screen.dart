import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_flex.dart';
import 'package:ccpladmin/helpers/widgets/my_flex_item.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:ccpladmin/helpers/widgets/app_dropdown.dart';
import 'package:ccpladmin/features/po/presentation/views/cococara_create_pallet_screen.dart';
import 'package:ccpladmin/services/create_pallet_service.dart';

class CreatePalletScreen extends StatefulWidget {
  const CreatePalletScreen({super.key});

  @override
  State<CreatePalletScreen> createState() => _CreatePalletScreenState();
}

class _CreatePalletScreenState extends State<CreatePalletScreen> with UIMixin {
  List<dynamic> _shippingData = [];
  String? _selectedShippingId;
  List<dynamic> _availableOrders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await CreatePalletService.getAll();
      if (mounted) {
        setState(() {
          _shippingData = [];
          for (var shipment in data) {
            String shippingId = shipment['shippingId']?.toString().trim() ?? '';
            if (shippingId.isEmpty || shippingId.toLowerCase() == 'null' || shippingId.toLowerCase() == 'not assigned') {
              continue;
            }

            if (shipment['items'] != null) {
              var pendingItems = (shipment['items'] as List).where((item) {
                String cococaraId = item['cococaraPalletId']?.toString() ?? '';
                return cococaraId.isEmpty || cococaraId == 'null';
              }).toList();
              if (pendingItems.isNotEmpty) {
                Map<String, dynamic> newShipment = Map<String, dynamic>.from(shipment as Map);
                newShipment['items'] = pendingItems;
                _shippingData.add(newShipment);
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Utils.showErrorToast("Error loading data: $e", context: context);
      }
    }
  }

  void _onShippingChanged(String? val) {
    setState(() {
      _selectedShippingId = val;
      var shipping = _shippingData.firstWhere(
          (element) => element['shippingId'] == val,
          orElse: () => null);
      _availableOrders = shipping != null ? shipping['items'] : [];
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
                  "Create Pallet",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Pallet Details', route: '/po/pallet_details'),
                    MyBreadcrumbItem(name: 'Create Pallet', active: true),
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
                  MyFlex(
                    contentPadding: false,
                    children: [
                      MyFlexItem(
                        sizes: 'lg-6 md-12',
                        child: _buildDropdown(
                          "Shipping ID",
                          _selectedShippingId,
                          _shippingData
                              .map((e) => e['shippingId'].toString())
                              .toList(),
                          _onShippingChanged,
                        ),
                      ),
                      if (_selectedShippingId != null)
                        MyFlexItem(
                          sizes: 'lg-12',
                          child: _buildOrderTable()),
                      MyFlexItem(
                        sizes: 'lg-12',
                        child: Padding(
                          padding: MySpacing.top(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              MyButton.text(
                                onPressed: () => Navigator.pop(context),
                                child: MyText.labelMedium("Back"),
                              ),
                              if (_selectedShippingId != null) ...[
                                MySpacing.width(16),
                                MyButton.rounded(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => CococaraCreatePalletScreen(shippingId: _selectedShippingId)),
                                    );
                                  },
                                  elevation: 0,
                                  padding: MySpacing.xy(20, 16),
                                  backgroundColor: contentTheme.primary,
                                  child: MyText.labelMedium("Next", color: contentTheme.onPrimary, fontWeight: 600),
                                ),
                              ],
                            ],
                          ),
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

  Widget _buildOrderTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium("Pallet Items", fontWeight: 600),
        MySpacing.height(8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: contentTheme.background,
              border: Border.all(color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(
                    color: contentTheme.onBackground.withValues(alpha: 20 / 255), width: 1),
                verticalInside: BorderSide(
                    color: contentTheme.onBackground.withValues(alpha: 20 / 255), width: 1),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1.5),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration:
                      BoxDecoration(color: contentTheme.primary.withValues(alpha: 20 / 255)),
                  children: [
                    _buildHeaderCell("Order ID"),
                    _buildHeaderCell("Item Code"),
                    _buildHeaderCell("Supplier"),
                    _buildHeaderCell("Pallet ID"),
                  ],
                ),
                ..._availableOrders.expand((order) {
                  String rootOrderId = order['orderId']?.toString() ?? order['orderid']?.toString() ?? order['order_id']?.toString() ?? '';
                  String rootItemCode = order['itemCode']?.toString() ?? order['itemcode']?.toString() ?? order['item_code']?.toString() ?? '';
                  String supplier = order['supplier']?.toString() ?? order['supplierName']?.toString() ?? order['supplier_name']?.toString() ?? '';
                  String tempPalletId = order['tempPalletId']?.toString() ?? order['temppalletid']?.toString() ?? order['temp_pallet_id']?.toString() ?? '';

                  List<Map<String, String>> rowDataList = [];

                  if (order['layers'] != null && order['layers'] is List && (order['layers'] as List).isNotEmpty) {
                    final layers = order['layers'] as List;
                    for (var l in layers) {
                      String lOrderId = l['orderId']?.toString() ?? l['orderid']?.toString() ?? l['order_id']?.toString() ?? '';
                      String lItemCode = l['itemCode']?.toString() ?? l['itemcode']?.toString() ?? l['item_code']?.toString() ?? '';
                      
                      if (lOrderId.isEmpty) lOrderId = rootOrderId;
                      if (lItemCode.isEmpty) lItemCode = rootItemCode;

                      rowDataList.add({
                        'orderId': lOrderId,
                        'itemCode': lItemCode,
                      });
                    }
                  } else {
                    rowDataList.add({
                      'orderId': rootOrderId,
                      'itemCode': rootItemCode,
                    });
                  }

                  List<Map<String, String>> uniqueRows = [];
                  for (var row in rowDataList) {
                    if (!uniqueRows.any((r) => r['orderId'] == row['orderId'] && r['itemCode'] == row['itemCode'])) {
                      uniqueRows.add(row);
                    }
                  }

                  return uniqueRows.map((row) => TableRow(
                    children: [
                      _buildCell(row['orderId']),
                      _buildCell(row['itemCode']),
                      _buildCell(supplier),
                      _buildCell(tempPalletId),
                    ],
                  ));
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String title) {
    return Padding(
      padding: MySpacing.xy(12, 12),
      child: MyText.bodySmall(title,
          fontWeight: 700, color: contentTheme.primary),
    );
  }

  Widget _buildCell(String? value) {
    return Padding(
      padding: MySpacing.xy(12, 12),
      child: MyText.bodySmall(value ?? "",
          fontWeight: 600, color: contentTheme.onBackground),
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