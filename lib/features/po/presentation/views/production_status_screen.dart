import 'package:flutter/material.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/model/polist_model.dart';
import 'package:ccpladmin/services/supplier_service.dart';

class ProductionStatusScreen extends StatefulWidget {
  final PolistModel data;

  const ProductionStatusScreen({super.key, required this.data});

  @override
  ProductionStatusScreenState createState() => ProductionStatusScreenState();
}

class ProductionStatusScreenState extends State<ProductionStatusScreen> with UIMixin {
  List<Map<String, dynamic>> _productionData = [];
  List<dynamic> _suppliers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final supplierService = SupplierService();
      final suppliers = await supplierService.getSuppliers();
      final assignedSuppliers = await supplierService.getAssignedSuppliers(widget.data.orderId, widget.data.itemCode);
      final dailyProduction = await supplierService.getProductionByOrderAndItem(widget.data.orderId, widget.data.itemCode);

      if (mounted) {
        setState(() {
          _suppliers = suppliers;
          _productionData = List<Map<String, dynamic>>.from(assignedSuppliers.map((e) {
            String supplierId = e['supplierId']?.toString() ?? '';
            String poNo = e['poNo']?.toString() ?? '';
            
            var logsForPo = dailyProduction.where((d) => (d['supplierpono']?.toString() ?? '') == poNo).toList();
            List<Map<String, String>> logs = logsForPo.map((d) {
              String pDate = d['productiondate']?.toString() ?? '';
              if (pDate.contains('T')) {
                pDate = pDate.split('T')[0];
              } else if (pDate.contains(' ')) {
                pDate = pDate.split(' ')[0];
              }
              return {
                'date': pDate,
                'completedQty': d['completedqty']?.toString() ?? '0',
              };
            }).toList();

            return {
              'poNo': poNo,
              'supplierId': supplierId,
              'supplierName': _getSupplierName(supplierId),
              'machine': e['machine']?.toString() ?? '',
              'assignedQty': e['qty']?.toString() ?? '',
              'completedQty': (e['completedQty'] == null || e['completedQty'].toString().isEmpty) ? '0' : e['completedQty'].toString(),
              'productionLogs': logs,
            };
          }));
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching production data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getSupplierName(String supplierId) {
    if (supplierId.isEmpty) return '';
    var supplier = _suppliers.firstWhere(
      (s) => (s['supplierid']?.toString() ?? s['supplierId']?.toString()) == supplierId, 
      orElse: () => {}
    );
    if (supplier.isEmpty) return supplierId;
    return (supplier['suppliername'] ?? supplier['supplierName'] ?? supplierId).toString();
  }

  Widget _buildTableCell(Widget child) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: MySpacing.xy(24, 16),
        child: child,
      ),
    );
  }

  Widget _buildInnerLogsTable(List<Map<String, String>> logs) {
    if (logs.isEmpty) {
      return MyText.bodySmall("No logs", color: contentTheme.onBackground.withValues(alpha: 150 / 255));
    }
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder.all(color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
      children: [
        TableRow(
          decoration: BoxDecoration(color: contentTheme.primary.withValues(alpha: 10 / 255)),
          children: [
            Padding(padding: MySpacing.xy(8, 4), child: MyText.labelSmall('Date', fontWeight: 600)),
            Padding(padding: MySpacing.xy(8, 4), child: MyText.labelSmall('Completed QTY', fontWeight: 600)),
          ],
        ),
        ...logs.map((log) => TableRow(
          children: [
            Padding(padding: MySpacing.xy(8, 4), child: MyText.bodySmall(log['date'] ?? '')),
            Padding(padding: MySpacing.xy(8, 4), child: MyText.bodySmall(log['completedQty'] ?? '')),
          ],
        )),
      ],
    );
  }

  Widget _buildProductionTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder(
            horizontalInside: BorderSide(color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: contentTheme.primary.withValues(alpha: 10 / 255),
              ),
              children: [
                _buildTableCell(MyText.labelMedium('Supplier PO No', fontWeight: 600)),
                _buildTableCell(MyText.labelMedium('Supplier Name', fontWeight: 600)),
                _buildTableCell(MyText.labelMedium('Machine', fontWeight: 600)),
                _buildTableCell(MyText.labelMedium('Assigned QTY', fontWeight: 600)),
                _buildTableCell(MyText.labelMedium('Completed QTY', fontWeight: 600)),
                _buildTableCell(MyText.labelMedium('Production Logs', fontWeight: 600)),
              ],
            ),
            ..._productionData.map((data) {
              return TableRow(
                children: [
                  _buildTableCell(MyText.bodyMedium(data['poNo']?.toString() ?? '')),
                  _buildTableCell(MyText.bodyMedium(data['supplierName']?.toString() ?? '')),
                  _buildTableCell(MyText.bodyMedium(data['machine']?.toString() ?? '')),
                  _buildTableCell(MyText.bodyMedium(data['assignedQty']?.toString() ?? '')),
                  _buildTableCell(MyText.bodyMedium(data['completedQty']?.toString() ?? '')),
                  _buildTableCell(_buildInnerLogsTable(data['productionLogs'] as List<Map<String, String>>)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.titleMedium("Suppliers Production", fontWeight: 600),
        MySpacing.height(16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_productionData.isEmpty)
          MyText.bodyMedium("No suppliers assigned yet.")
        else
          _buildProductionTable(),
      ],
    );
  }
}