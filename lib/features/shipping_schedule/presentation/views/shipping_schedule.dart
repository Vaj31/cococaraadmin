import 'package:ccpladmin/services/shipping_schedule_service.dart';

import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:ccpladmin/features/shipping_schedule/presentation/views/create_shipping_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ShippingSchedule extends StatefulWidget {
  const ShippingSchedule({super.key});

  @override
  State<ShippingSchedule> createState() => _ShippingScheduleState();
}

class _ShippingScheduleState extends State<ShippingSchedule> with UIMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _data = [];

  final ShippingScheduleService _shippingScheduleService = ShippingScheduleService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatQty(dynamic qty) {
    if (qty == null) return '-';
    double? parsed = double.tryParse(qty.toString());
    if (parsed != null) {
      return parsed.toInt().toString();
    }
    return qty.toString();
  }

  Future<void> _loadData() async {
    try {
      final List<dynamic> rawData = await _shippingScheduleService.getAll();
        
        // Group the flat DB data by shippingid
        Map<String, Map<String, dynamic>> groupedMap = {};

        for (var item in rawData) {
          String shippingId = item['shippingid'] ?? 'Unknown';
          
          if (!groupedMap.containsKey(shippingId)) {
            groupedMap[shippingId] = {
              'shippingId': shippingId,
              'color': item['color'],
              'orders': <Map<String, dynamic>>[],
            };
          }

          groupedMap[shippingId]!['orders'].add({
            'orderId': item['orderid'],
            'itemCode': item['itemcode'],
            'pol': item['pol'] ?? '-',
            'pod': item['pod'] ?? '-',
            'deliveryDate': item['deliveryLT'] ?? item['deliveryl/t'] ?? '-',
            'productionStatus': item['productionStatus'] ?? item['productionstatus'] ?? '-',
            'qty': _formatQty(item['qty']),
          });
        }

        setState(() {
          _data = groupedMap.values.toList();
          _isLoading = false;
        });
    } catch (e) {
      setState(() {
        _errorMessage = "Error connecting to server: $e";
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Layout(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Layout(
        child: Center(child: MyText.bodyMedium(_errorMessage!, color: contentTheme.danger)),
      );
    }

    List<Map<String, dynamic>> filteredList = _data;
    if (_searchText.isNotEmpty) {
      filteredList = _data.where((group) {
        String search = _searchText.toLowerCase();
        bool match(String? value) =>
            value != null && value.toLowerCase().contains(search);

        if (match(group['shippingId']?.toString())) return true;
        
        List<dynamic> orders = group['orders'] ?? [];
        for (var order in orders) {
          if (match(order['orderId']?.toString()) ||
              match(order['itemCode']?.toString()) ||
              match(order['pol']?.toString()) ||
              match(order['pod']?.toString()) ||
              match(order['deliveryDate']?.toString()) ||
              match(order['productionStatus']?.toString()) ||
              match(order['qty']?.toString())) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    int totalItems = filteredList.length;
    int totalPages = (totalItems / _itemsPerPage).ceil();
    if (totalPages == 0) {
      totalPages = 1;
    }
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    
    if (endIndex > totalItems) {
      endIndex = totalItems;
    }
    
    if (startIndex >= totalItems && totalItems > 0) {
      startIndex = 0;
      endIndex = _itemsPerPage < totalItems ? _itemsPerPage : totalItems;
      _currentPage = 1;
    }

    List<Map<String, dynamic>> currentData = [];
    if (totalItems > 0) {
      currentData = filteredList.sublist(startIndex, endIndex);
    }

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
                  "Shipping Schedule",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Shipping Schedule', active: true),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText.titleMedium("Shipping Schedule", fontWeight: 600),
                        Row(
                          children: [
                            MyButton.rounded(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CreateShippingScheduleScreen()),
                                );
                                _loadData();
                              },
                              elevation: 0,
                              padding: MySpacing.xy(20, 16),
                              backgroundColor: contentTheme.primary,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.plus,
                                    color: contentTheme.onPrimary,
                                    size: 18,
                                  ),
                                  MySpacing.width(8),
                                  MyText.labelLarge(
                                    "New Shipping Schedule",
                                    color: contentTheme.onPrimary,
                                    fontWeight: 600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    MySpacing.height(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 280,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchText = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search all data...",
                              hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: contentTheme.onBackground.withValues(alpha: 150 / 255)),
                              prefixIcon: Icon(LucideIcons.search,
                                  size: 18,
                                  color: contentTheme.onBackground.withValues(alpha: 150 / 255)),
                              filled: true,
                              fillColor: contentTheme.background.withValues(alpha: 50 / 255),
                              contentPadding: MySpacing.xy(12, 8),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: contentTheme.primary.withValues(alpha: 100 / 255)),
                              ),
                            ),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    MySpacing.height(20),
                    if (currentData.isEmpty)
                      Padding(
                        padding: MySpacing.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(LucideIcons.search_x,
                                  size: 40,
                                  color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
                              MySpacing.height(10),
                              MyText.bodyMedium("No records found for '$_searchText'",
                                  color: contentTheme.onBackground.withValues(alpha: 150 / 255)),
                            ],
                          ),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.black.withValues(alpha: 0.3),
                                width: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Table(
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  width: 0.8),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(1.5),
                              1: FlexColumnWidth(1.5),
                              2: FlexColumnWidth(1.5),
                              3: FlexColumnWidth(1),
                              4: FlexColumnWidth(1),
                              5: FlexColumnWidth(1),
                              6: FlexColumnWidth(1.2),
                              7: FlexColumnWidth(1),
                            },
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                    color: contentTheme.primary.withValues(alpha: 40 / 255),
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          width: 0.8),
                                    )),
                                children: [
                                  _buildHeaderCell("Shipping ID"),
                                  _buildHeaderCell("Order ID"),
                                  _buildHeaderCell("Item Code"),
                                  _buildHeaderCell("POL"),
                                  _buildHeaderCell("POD"),
                                  _buildHeaderCell("Delivery Date"),
                                  _buildHeaderCell("Prod Status"),
                                  _buildHeaderCell("Ordered Qty", hasRightBorder: false),
                                ],
                              ),
                              ..._buildTableRows(currentData),
                            ],
                          ),
                        ),
                      ),
                    MySpacing.height(20),
                    _buildPaginationControls(totalPages, totalItems, startIndex + 1, endIndex),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }



  List<TableRow> _buildTableRows(List<Map<String, dynamic>> currentData) {
    List<TableRow> rows = [];
    for (int groupIndex = 0; groupIndex < currentData.length; groupIndex++) {
      var group = currentData[groupIndex];
      String shippingId = group['shippingId'].toString();

      Color? highlightColor;
      String? colorStr = group['color']?.toString();
      if (colorStr != null && colorStr.isNotEmpty && colorStr != 'null') {
        try {
          highlightColor = Color(int.parse(colorStr, radix: 16));
        } catch (e) {}
      }

      List<dynamic> orders = group['orders'] ?? [];

      for (int i = 0; i < orders.length; i++) {
        var order = orders[i];
        rows.add(
          TableRow(
            decoration: BoxDecoration(
              color: highlightColor ??
                  (groupIndex % 2 == 0
                      ? Colors.transparent
                      : contentTheme.background.withValues(alpha: 10 / 255)),
            ),
            children: [
              _buildCell(shippingId),
              _buildCell(order['orderId']?.toString()),
              _buildCell(order['itemCode']?.toString()),
              _buildCell(order['pol']?.toString()),
              _buildCell(order['pod']?.toString()),
              _buildCell(order['deliveryDate']?.toString()),
              _buildCell(order['productionStatus']?.toString()),
              _buildCell(order['qty']?.toString(), hasRightBorder: false),
            ],
          ),
        );
      }
    }
    return rows;
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Widget _buildPaginationControls(int totalPages, int totalItems, int start, int end) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText.bodyMedium(
          "Showing $start to $end of $totalItems Records",
          fontWeight: 600,
          color: contentTheme.onBackground.withValues(alpha: 150 / 255),
        ),
        Row(
          children: [
            MyText.bodyMedium(
              "Page $_currentPage of $totalPages",
              color: contentTheme.onBackground.withValues(alpha: 150 / 255),
              fontWeight: 600,
            ),
            MySpacing.width(16),
            InkWell(
              onTap: _currentPage > 1 ? () => _onPageChanged(_currentPage - 1) : null,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: MySpacing.all(8),
                decoration: BoxDecoration(
                    color: _currentPage > 1 ? contentTheme.primary.withValues(alpha: 20 / 255) : contentTheme.onBackground.withValues(alpha: 10 / 255),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _currentPage > 1 ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 20 / 255))),
                child: Icon(
                  LucideIcons.chevron_left,
                  size: 16,
                  color: _currentPage > 1 ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                ),
              ),
            ),
            MySpacing.width(8),
            InkWell(
              onTap: _currentPage < totalPages ? () => _onPageChanged(_currentPage + 1) : null,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: MySpacing.all(8),
                decoration: BoxDecoration(
                    color: _currentPage < totalPages ? contentTheme.primary.withValues(alpha: 20 / 255) : contentTheme.onBackground.withValues(alpha: 10 / 255),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _currentPage < totalPages ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 20 / 255))),
                child: Icon(
                  LucideIcons.chevron_right,
                  size: 16,
                  color: _currentPage < totalPages ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String title, {bool hasRightBorder = true}) {
    return Container(
      padding: MySpacing.xy(12, 12),
      decoration: BoxDecoration(
        border: hasRightBorder
            ? Border(
                right: BorderSide(
                    color: Colors.black.withValues(alpha: 0.3),
                    width: 0.8),
              )
            : null,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: MyText.labelLarge(
          title,
          fontWeight: 700,
          color: contentTheme.primary,
          fontSize: 14,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildCell(String? value, {bool hasRightBorder = true}) {
    return Container(
      padding: MySpacing.xy(12, 12),
      decoration: BoxDecoration(
        border: hasRightBorder
            ? Border(
                right: BorderSide(
                    color: Colors.black.withValues(alpha: 0.3),
                    width: 0.8),
              )
            : null,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: MyText.bodyMedium(
          value ?? "",
          maxLines: 1,
        ),
      ),
    );
  }
}
