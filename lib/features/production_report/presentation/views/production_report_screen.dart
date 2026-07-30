import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:ccpladmin/services/supplier_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ProductionReportScreen extends StatefulWidget {
  const ProductionReportScreen({super.key});

  @override
  State<ProductionReportScreen> createState() => _ProductionReportScreenState();
}

class _ProductionReportScreenState extends State<ProductionReportScreen>
    with UIMixin {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  bool _useSpecificDate = false;
  bool _useDateRange = false;
  bool _useCurrentDate = false;
  bool _useCurrentMonth = false;
  bool _allSuppliers = false;

  DateTime? _selectedDate;
  DateTime? _fromDate;
  DateTime? _toDate;

  List<Map<String, dynamic>> _suppliers = [];
  String? _selectedSupplierId;
  bool _isLoadingSuppliers = true;
  final SupplierService _supplierService = SupplierService();
  List<dynamic> _reportData = [];
  bool _isGeneratingReport = false;
  bool _hasSearched = false;

  Future<void> _selectSpecificDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _toDate ?? DateTime(2101),
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final suppliersData = await _supplierService.getSuppliers();
      if (mounted) {
        setState(() {
          _suppliers = List<Map<String, dynamic>>.from(suppliersData);
          _isLoadingSuppliers = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSuppliers = false;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGeneratingReport = true;
      _reportData = [];
      _hasSearched = false;
    });

    final Map<String, String> queryParams = {};
    if (_useCurrentDate) {
      queryParams['specificDate'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
    } else if (_useCurrentMonth) {
      DateTime now = DateTime.now();
      DateTime firstDay = DateTime(now.year, now.month, 1);
      DateTime lastDay = DateTime(now.year, now.month + 1, 0);
      queryParams['fromDate'] = DateFormat('yyyy-MM-dd').format(firstDay);
      queryParams['toDate'] = DateFormat('yyyy-MM-dd').format(lastDay);
    } else if (_useSpecificDate && _selectedDate != null) {
      queryParams['specificDate'] = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    } else if (_useDateRange && _fromDate != null && _toDate != null) {
      queryParams['fromDate'] = DateFormat('yyyy-MM-dd').format(_fromDate!);
      queryParams['toDate'] = DateFormat('yyyy-MM-dd').format(_toDate!);
    }

    if (!_allSuppliers && _selectedSupplierId != null) {
      queryParams['supplierId'] = _selectedSupplierId!;
    }

    try {
      final List<dynamic> reportData = await _supplierService.getProductionReport(queryParams);
      if (mounted) {
        setState(() {
          _reportData = reportData;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        Utils.showErrorToast("Failed to fetch report: $e", context: context);
        setState(() { _hasSearched = true; });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReport = false;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _useSpecificDate = false;
      _useDateRange = false;
      _useCurrentDate = false;
      _useCurrentMonth = false;
      _allSuppliers = false;
      _selectedDate = null;
      _fromDate = null;
      _toDate = null;
      _selectedSupplierId = null;
      _reportData = [];
      _hasSearched = false;
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
                  "Production Report",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Production Report', active: true),
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                MyText.titleMedium("Report Filters", fontWeight: 600),
                MySpacing.height(24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _useCurrentDate,
                              fillColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return contentTheme.primary;
                                }
                                return Colors.white;
                              }),
                              checkColor: contentTheme.onPrimary,
                              onChanged: (bool? value) {
                                setState(() {
                                  _useCurrentDate = value ?? false;
                                  if (_useCurrentDate) {
                                    _useCurrentMonth = false;
                                    _useSpecificDate = false;
                                    _useDateRange = false;
                                    _selectedDate = null;
                                    _fromDate = null;
                                    _toDate = null;
                                  }
                                });
                              },
                            ),
                            MyText.bodyMedium("Current Date"),
                          ],
                        ),
                        MySpacing.height(8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _useCurrentMonth,
                              fillColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return contentTheme.primary;
                                }
                                return Colors.white;
                              }),
                              checkColor: contentTheme.onPrimary,
                              onChanged: (bool? value) {
                                setState(() {
                                  _useCurrentMonth = value ?? false;
                                  if (_useCurrentMonth) {
                                    _useCurrentDate = false;
                                    _useSpecificDate = false;
                                    _useDateRange = false;
                                    _selectedDate = null;
                                    _fromDate = null;
                                    _toDate = null;
                                  }
                                });
                              },
                            ),
                            MyText.bodyMedium("Current Month"),
                          ],
                        ),
                      ],
                    ),
                    MySpacing.width(48),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _useSpecificDate,
                              fillColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return contentTheme.primary;
                                }
                                return Colors.white;
                              }),
                              checkColor: contentTheme.onPrimary,
                              onChanged: (bool? value) {
                                setState(() {
                                  _useSpecificDate = value ?? false;
                                  if (_useSpecificDate) {
                                    _useCurrentDate = false;
                                    _useCurrentMonth = false;
                                    _useDateRange = false;
                                    _fromDate = null;
                                    _toDate = null;
                                  }
                                });
                              },
                            ),
                            MyText.bodyMedium("Specific Date"),
                          ],
                        ),
                        if (_useSpecificDate)
                          Padding(
                            padding: MySpacing.top(16),
                            child: MyButton.outlined(
                              onPressed: () => _selectSpecificDate(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.calendar, size: 16, color: contentTheme.primary),
                                  MySpacing.width(8),
                                  MyText.bodyMedium(
                                    _selectedDate == null
                                        ? 'Select Date'
                                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                                    color: contentTheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    MySpacing.width(48),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _useDateRange,
                              fillColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return contentTheme.primary;
                                }
                                return Colors.white;
                              }),
                              checkColor: contentTheme.onPrimary,
                              onChanged: (bool? value) {
                                setState(() {
                                  _useDateRange = value ?? false;
                                  if (_useDateRange) {
                                    _useCurrentDate = false;
                                    _useCurrentMonth = false;
                                    _useSpecificDate = false;
                                    _selectedDate = null;
                                  }
                                });
                              },
                            ),
                            MyText.bodyMedium("Between Date"),
                          ],
                        ),
                        if (_useDateRange)
                          Padding(
                            padding: MySpacing.top(16),
                            child: Row(
                              children: [
                                MyButton.outlined(
                                  onPressed: () => _selectFromDate(context),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.calendar, size: 16, color: contentTheme.primary),
                                      MySpacing.width(8),
                                      MyText.bodyMedium(
                                        _fromDate == null
                                            ? 'From Date'
                                            : DateFormat('yyyy-MM-dd').format(_fromDate!),
                                        color: contentTheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                                MySpacing.width(16),
                                MyButton.outlined(
                                  onPressed: () => _selectToDate(context),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.calendar, size: 16, color: contentTheme.primary),
                                      MySpacing.width(8),
                                      MyText.bodyMedium(
                                        _toDate == null
                                            ? 'To Date'
                                            : DateFormat('yyyy-MM-dd').format(_toDate!),
                                        color: contentTheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    MySpacing.width(48),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     Checkbox(
                        //       value: _allSuppliers,
                        //       fillColor: WidgetStateProperty.resolveWith((states) {
                        //         if (states.contains(WidgetState.selected)) {
                        //           return contentTheme.primary;
                        //         }
                        //         return Colors.white;
                        //       }),
                        //       checkColor: contentTheme.onPrimary,
                        //       onChanged: (bool? value) {
                        //         setState(() {
                        //           _allSuppliers = value ?? false;
                        //           if (_allSuppliers) {
                        //             _selectedSupplierId = null;
                        //           }
                        //         });
                        //       },
                        //     ),
                        //     MyText.bodyMedium("All Supplier"),
                        //   ],
                        // ),
                        if (!_allSuppliers)
                          Padding(
                            padding: MySpacing.top(1),
                            child: _isLoadingSuppliers
                                ? Center(child: CircularProgressIndicator())
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // MyText.labelMedium("Supplier", fontWeight: 600),
                                      // MySpacing.height(8),
                                      Container(
                                        width: 300,
                                        padding: MySpacing.xy(16, 4),
                                        decoration: BoxDecoration(
                                          color: contentTheme.background,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedSupplierId,
                                            isExpanded: true,
                                            hint: MyText.bodyMedium("Select Supplier"),
                                            items: _suppliers.map((Map<String, dynamic> supplier) {
                                              String supId = supplier['supplierId']?.toString() ?? supplier['supplier_id']?.toString() ?? supplier['id']?.toString() ?? '';
                                              String supName = supplier['supplierName']?.toString() ?? supplier['supplier_name']?.toString() ?? supplier['name']?.toString() ?? 'Unnamed Supplier';
                                              return DropdownMenuItem<String>(
                                                value: supId.isNotEmpty ? supId : null,
                                                child: MyText.bodyMedium(supId.isNotEmpty ? '$supId - $supName'.toUpperCase() : supName.toUpperCase()),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                _selectedSupplierId = newValue;
                                              });
                                            },
                                            dropdownColor: contentTheme.background,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                      ],
                    ),
                  ],
                ),
                MySpacing.height(24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_hasSearched)
                      MyButton.outlined(
                        onPressed: _clearFilters,
                        elevation: 0,
                        padding: MySpacing.xy(20, 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.x, color: contentTheme.danger, size: 18),
                            MySpacing.width(8),
                            MyText.labelLarge("Clear", color: contentTheme.danger, fontWeight: 600),
                          ],
                        ),
                      ),
                    if (_hasSearched) MySpacing.width(16),
                    MyButton.rounded(
                      onPressed: _isGeneratingReport ? null : _generateReport,
                      elevation: 0,
                      padding: MySpacing.xy(20, 16),
                      backgroundColor: contentTheme.primary,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.file_text, color: contentTheme.onPrimary, size: 18),
                          MySpacing.width(8),
                          MyText.labelLarge("Generate Report", color: contentTheme.onPrimary, fontWeight: 600),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isGeneratingReport) ...[
                  MySpacing.height(32),
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                ] else if (_reportData.isNotEmpty) ...[
                  MySpacing.height(32),
                  MyText.titleMedium("Report Results", fontWeight: 600),
                  MySpacing.height(16),
                  LayoutBuilder(builder: (context, constraints) {
                    double minWidth = constraints.maxWidth > 2200 ? constraints.maxWidth : 2200;
                    return Theme(
                      data: theme.copyWith(
                        scrollbarTheme: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(contentTheme.primary),
                          trackColor: WidgetStateProperty.all(contentTheme.primary.withValues(alpha: 40 / 255)),
                          trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                          thickness: WidgetStateProperty.all(8),
                          radius: const Radius.circular(4),
                        ),
                      ),
                      child: Scrollbar(
                        controller: _horizontalController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: minWidth,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: MySpacing.xy(16, 12),
                                    color: contentTheme.primary.withValues(alpha: 40 / 255),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 3, child: MyText.labelLarge("Date", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("Supplier", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("Shipment ID", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("Order ID", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("Item Code", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 2, child: MyText.labelLarge("Assigned", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 2, child: MyText.labelLarge("Completed", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 2, child: MyText.labelLarge("Overall", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 2, child: MyText.labelLarge("Pending", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("Package Type", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 2, child: MyText.labelLarge("Qty / Pkg", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("Total Package", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("Production L/T", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("ETA", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("ETD", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 2, child: MyText.labelLarge("Delivery L/T", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("POL", fontWeight: 600, color: contentTheme.primary)),
                                        Expanded(flex: 3, child: MyText.labelLarge("POD", fontWeight: 600, color: contentTheme.primary)),
                                      ],
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 500),
                                    child: Scrollbar(
                                      controller: _verticalController,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      child: SingleChildScrollView(
                                        controller: _verticalController,
                                        scrollDirection: Axis.vertical,
                                        child: Column(
                                          children: [
                                            ..._reportData.asMap().entries.map((entry) {
                                              return _ProductionRow(
                                                data: entry.value,
                                                isEven: entry.key % 2 == 0,
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ] else if (_hasSearched) ...[
                  MySpacing.height(32),
                  Center(
                    child: MyText.bodyLarge(
                      "No records found for the selected filters.",
                      color: contentTheme.onBackground.withValues(alpha: 150 / 255),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductionRow extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isEven;

  const _ProductionRow({required this.data, required this.isEven});

  @override
  State<_ProductionRow> createState() => _ProductionRowState();
}

class _ProductionRowState extends State<_ProductionRow> with UIMixin {
  @override
  Widget build(BuildContext context) {
    String formatDate(String? val) {
      if (val == null || val.isEmpty || val == '-') {
        return '-';
      }
      try {
        return DateFormat('dd/MM/yyyy').format(DateTime.parse(val));
      } catch (e) {
        return val.split('T')[0];
      }
    }

    // Extract & calculate fields based on reference logic
    final dateStr = formatDate(widget.data['productiondate']?.toString());
    final shipmentId = widget.data['shipmentId'] ?? widget.data['shipmentid'] ?? widget.data['shippingid'] ?? widget.data['shippingId'] ?? '-';
    
    double assigned = double.tryParse(widget.data['assignedqty']?.toString() ?? '0') ?? 0;
    double pending = double.tryParse(widget.data['pendingqty']?.toString() ?? '0') ?? 0;
    double overall = assigned - pending;
    if (overall < 0) {
      overall = 0;
    }
    String overallStr = overall % 1 == 0 ? overall.toInt().toString() : overall.toString();

    return Container(
      padding: MySpacing.xy(16, 12),
      decoration: BoxDecoration(
        color: widget.isEven
            ? Colors.transparent
            : contentTheme.background.withValues(alpha: 10 / 255),
        border: Border(
            bottom: BorderSide(
                color: contentTheme.onBackground.withValues(alpha: 20 / 255),
                width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: MyText.bodyMedium(dateStr, fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(widget.data['supplierid']?.toString().toUpperCase() ?? '-', fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(shipmentId.toString(), fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(widget.data['orderid']?.toString() ?? '-', fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(widget.data['itemcode']?.toString() ?? '-', fontWeight: 600, color: contentTheme.primary)),
          Expanded(flex: 2, child: MyText.bodyMedium(widget.data['assignedqty']?.toString() ?? '0', fontWeight: 600)),
          Expanded(flex: 2, child: MyText.bodyMedium(widget.data['completedqty']?.toString() ?? '0', fontWeight: 600, color: contentTheme.primary)),
          Expanded(flex: 2, child: MyText.bodyMedium(overallStr, fontWeight: 600)),
          Expanded(flex: 2, child: MyText.bodyMedium(widget.data['pendingqty']?.toString() ?? '0', fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(widget.data['packagetype']?.toString() ?? '-', fontWeight: 600)),
          Expanded(flex: 2, child: MyText.bodyMedium(widget.data['qty/package']?.toString() ?? '0', fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(widget.data['totalpackage']?.toString() ?? '0', fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(formatDate(widget.data['productionlt']?.toString() ?? widget.data['production_lt']?.toString() ?? widget.data['productionLt']?.toString()), fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(formatDate(widget.data['eta']?.toString()), fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(formatDate(widget.data['etd']?.toString()), fontWeight: 600)),
          Expanded(flex: 2, child: MyText.bodyMedium(formatDate(widget.data['deliverylt']?.toString() ?? widget.data['delivery_lt']?.toString() ?? widget.data['deliveryLt']?.toString()), fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(widget.data['pol']?.toString() ?? '-', fontWeight: 600)),
          Expanded(flex: 3, child: MyText.bodyMedium(widget.data['pod']?.toString() ?? '-', fontWeight: 600)),
        ],
      ),
    );
  }
}