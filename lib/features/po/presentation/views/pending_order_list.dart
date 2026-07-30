import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:ccpladmin/features/po/presentation/providers/po_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class PendingOrderList extends ConsumerStatefulWidget {
  const PendingOrderList({super.key});

  @override
  ConsumerState<PendingOrderList> createState() => _PendingOrderListState();
}

class _PendingOrderListState extends ConsumerState<PendingOrderList> with UIMixin {
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingState = ref.watch(pendingOrdersProvider);

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
                  "Pending Order List",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Pending Order List', active: true),
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
              child: pendingState.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator())),
                error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(24.0), child: MyText.bodyMedium("Error: $error", color: contentTheme.danger))),
                data: (data) {
                  int totalItems = data.length;
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
                  List<Map<String, String>> currentData = data.sublist(startIndex, endIndex);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                                  DataColumn(label: MyText.labelLarge("Shipment ID", fontWeight: 600)),
                                  DataColumn(label: MyText.labelLarge("Supplier", fontWeight: 600)),
                                  DataColumn(label: MyText.labelLarge("Order ID", fontWeight: 600)),
                                  DataColumn(label: MyText.labelLarge("Item Code", fontWeight: 600)),
                                  DataColumn(label: MyText.labelLarge("Ordered QTY", fontWeight: 600)),
                                  DataColumn(label: MyText.labelLarge("Assigned QTY", fontWeight: 600)),
                                  DataColumn(label: MyText.labelLarge("Completed QTY", fontWeight: 600)),
                                  DataColumn(label: MyText.labelLarge("Pending QTY", fontWeight: 600)),
                                ],
                                rows: currentData.map((row) {
                                  return DataRow(cells: [
                                    DataCell(MyText.bodyMedium(row['shipId']!)),
                                    DataCell(MyText.bodyMedium(row['supplier']!)),
                                    DataCell(MyText.bodyMedium(row['orderId']!)),
                                    DataCell(MyText.bodyMedium(row['itemCode']!)),
                                    DataCell(MyText.bodyMedium(row['orderQty']!)),
                                    DataCell(MyText.bodyMedium(row['assignedQty']!)),
                                    DataCell(MyText.bodyMedium(row['compQty']!)),
                                    DataCell(MyText.bodyMedium(row['pendQty']!)),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }),
                      MySpacing.height(20),
                      _buildPaginationControls(totalPages, totalItems, startIndex + 1, endIndex),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
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
}
