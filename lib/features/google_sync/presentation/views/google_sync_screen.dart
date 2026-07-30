import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/services/shipping_schedule_service.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class GoogleSyncScreen extends StatefulWidget {
  const GoogleSyncScreen({super.key});

  @override
  State<GoogleSyncScreen> createState() => _GoogleSyncScreenState();
}

class _GoogleSyncScreenState extends State<GoogleSyncScreen> with SingleTickerProviderStateMixin, UIMixin {
  bool _isChecking = false;
  bool _isApplying = false;
  bool _isInitialSyncing = false;
  bool _hasData = false;
  bool _isLoadingDataStatus = true;

  late TabController _tabController;

  List<dynamic> _poDiffs = [];
  List<dynamic> _shippingDiffs = [];
  
  Set<String> _selectedPoIds = {};
  Set<String> _selectedShippingIds = {};

  final ShippingScheduleService shippingScheduleService = ShippingScheduleService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _checkDataStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkDataStatus() async {
    setState(() {
      _isLoadingDataStatus = true;
    });
    try {
      final data = await shippingScheduleService.getAll();
      if (mounted) {
        setState(() {
          _hasData = data.isNotEmpty;
          _isLoadingDataStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDataStatus = false;
        });
      }
    }
  }

  Future<void> _checkDiffs() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final diffs = await shippingScheduleService.getGoogleSyncDiffs();
      if (mounted) {
        setState(() {
          _poDiffs = _filterDecimalChanges(diffs['poDiffs'] ?? []);
          _shippingDiffs = _filterDecimalChanges(diffs['shippingDiffs'] ?? []);
          
          // By default, select all detected changes so they're checked off
          _selectedPoIds = _poDiffs.map((e) => e['id'].toString()).toSet();
          _selectedShippingIds = _shippingDiffs.map((e) => e['id'].toString()).toSet();
        });

        if (_poDiffs.isEmpty && _shippingDiffs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: MyText.bodyMedium("Everything is up to date!", color: contentTheme.onPrimary), backgroundColor: contentTheme.success),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Utils.showErrorToast("Error fetching diffs: $e", context: context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  List<dynamic> _filterDecimalChanges(List<dynamic> diffs) {
    return diffs.where((diff) {
      if (diff['isNew'] == true) return true;
      
      Map<String, dynamic> oldData = diff['oldData'] ?? {};
      Map<String, dynamic> newData = diff['newData'] ?? {};
      
      bool hasRealChanges = false;
      newData.forEach((key, value) {
        String oldStr = oldData[key]?.toString() ?? '';
        String newStr = value?.toString() ?? '';
        
        if (oldStr != newStr) {
          double? oldNum = double.tryParse(oldStr);
          double? newNum = double.tryParse(newStr);
          if (!(oldNum != null && newNum != null && oldNum == newNum)) {
            hasRealChanges = true;
          }
        }
      });
      
      return hasRealChanges;
    }).toList();
  }

  Future<void> _applySync() async {
    setState(() {
      _isApplying = true;
    });

    try {
      final selectedPOs = _poDiffs.where((e) => _selectedPoIds.contains(e['id'].toString())).map((e) => e['newData']).toList();
      final selectedShippings = _shippingDiffs.where((e) => _selectedShippingIds.contains(e['id'].toString())).map((e) => e['newData']).toList();

      await shippingScheduleService.applyGoogleSync({
        'selectedPOs': selectedPOs,
        'selectedShippings': selectedShippings,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: MyText.bodyMedium("Sync applied successfully!", color: contentTheme.onPrimary), backgroundColor: contentTheme.success),
        );
        setState(() {
          _poDiffs.clear();
          _shippingDiffs.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        Utils.showErrorToast("Apply Sync Error: $e", context: context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  Future<void> _initialSync() async {
    setState(() {
      _isInitialSyncing = true;
    });

    try {
      await shippingScheduleService.syncWithGoogle();

      if (mounted) {
        setState(() {
          _hasData = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: MyText.bodyMedium("Initial Sync completed successfully!", color: contentTheme.onPrimary), backgroundColor: contentTheme.success),
        );
      }
    } catch (e) {
      if (mounted) {
        Utils.showErrorToast("Initial Sync Error: $e", context: context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialSyncing = false;
        });
      }
    }
  }

  Widget _buildCustomCheckbox(bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          color: value ? contentTheme.primary : Colors.transparent,
          border: Border.all(
            color: value ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: value ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary) : null,
      ),
    );
  }

  Widget _buildDiffSection(String title, List<dynamic> diffs, Set<String> selectedIds, {bool isPo = false}) {
    if (diffs.isEmpty) {
      return Padding(
        padding: MySpacing.y(24),
        child: Center(
          child: MyText.bodyMedium("No changes found in $title.",
              color: contentTheme.onBackground.withValues(alpha: 150 / 255)),
        ),
      );
    }

    bool isAllSelected = diffs.isNotEmpty && selectedIds.containsAll(diffs.map((e) => e['id'].toString()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildCustomCheckbox(
              isAllSelected,
              (bool? val) {
                setState(() {
                  if (val == true) {
                    selectedIds.addAll(diffs.map((e) => e['id'].toString()));
                  } else {
                    selectedIds.removeAll(diffs.map((e) => e['id'].toString()));
                  }
                });
              },
            ),
            MySpacing.width(8),
            MyText.bodyMedium("Select All", fontWeight: 600),
          ],
        ),
        MySpacing.height(16),
        ...diffs.map((diff) => _buildRecordCard(diff, selectedIds, isPo: isPo)),
      ],
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> diff, Set<String> selectedIds, {bool isPo = false}) {
    bool isNew = diff['isNew'] == true;
    String id = diff['id'].toString();
    Map<String, dynamic> oldData = diff['oldData'] ?? {};
    Map<String, dynamic> newData = diff['newData'] ?? {};

    String displayTitle = "ID: $id";
    if (isPo) {
      displayTitle = "Order ID: ${newData['orderid'] ?? id}";
    } else {
      String oId = newData['orderid']?.toString() ?? '-';
      String iCode = newData['itemcode']?.toString() ?? '-';
      String sId = newData['shippingid']?.toString() ?? '-';
      displayTitle = "Order ID: $oId | Item: $iCode | Shipping: $sId";
    }

    Map<String, String> poColumnMap = {
      "revision": "Revision",
      "updateddate": "Updated",
      "status": "Status",
      "orderdate": "Order",
      "sales": "Sales",
      "orderid": "Order ID",
      "deliveryl/t": "Delivery L/T",
      "planting": "Planting",
      "product": "Product",
      "ec": "EC",
      "material": "Material",
      "l": "L",
      "d": "D",
      "h": "H",
      "itemcode": "Item code",
      "qty": "QTY",
      "crop": "Crop",
      "planter": "Planter",
      "plantersize": "Planter size",
      "plantershape": "Planter shape",
      "space": "Space",
      "drain": "Drain",
      "drainsize": "Drain size",
      "drainposition": "Drain position",
      "lifespan": "Lifespan",
      "diagram": "Diagram",
      "patncode": "PATN code",
      "newpatn": "New PATN",
      "sample": "Sample",
      "memo(in)": "Memo（IN）",
      "memo(jp)": "Memo（JP）",
      "lastmodifieddate": "Last Modified Date",
      "lastmodifiedby": "Last Modified By"
    };

    List<String> columns = [];
    if (isPo) {
      for (String key in poColumnMap.keys) {
        String? actualKey = newData.keys.cast<String?>().firstWhere((k) => k?.toLowerCase() == key, orElse: () => null);
        if (actualKey != null) {
          columns.add(actualKey);
        }
      }
    } else {
      columns = newData.keys.cast<String>().where((k) => k.toLowerCase() != 'color').toList();
    }

    return MyCard(
      margin: MySpacing.bottom(16),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: MySpacing.xy(16, 12),
            decoration: BoxDecoration(
              color: contentTheme.primary.withValues(alpha: 20 / 255),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                _buildCustomCheckbox(
                  selectedIds.contains(id),
                  (bool? val) {
                    setState(() {
                      if (val == true) {
                        selectedIds.add(id);
                      } else {
                        selectedIds.remove(id);
                      }
                    });
                  },
                ),
                MySpacing.width(8),
                Expanded(
                  child: MyText.titleMedium(displayTitle, fontWeight: 600),
                ),
                Container(
                  padding: MySpacing.xy(8, 4),
                  decoration: BoxDecoration(
                    color: isNew ? contentTheme.success.withValues(alpha: 20 / 255) : contentTheme.primary.withValues(alpha: 20 / 255),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: MyText.bodySmall(isNew ? "New Record" : "Modified Record", color: isNew ? contentTheme.success : contentTheme.primary, fontWeight: 600),
                ),
              ],
            ),
          ),
          _HorizontalScrollableTable(
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                horizontalInside: BorderSide(
                    color: contentTheme.onBackground.withValues(alpha: 20 / 255),
                    width: 0.5),
                verticalInside: BorderSide(
                    color: contentTheme.onBackground.withValues(alpha: 20 / 255),
                    width: 0.5),
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: contentTheme.background),
                  children: [
                    Padding(
                      padding: MySpacing.xy(12, 12),
                      child: MyText.labelLarge("Version", fontWeight: 600, color: contentTheme.onBackground),
                    ),
                    ...columns.map((col) {
                      String header = col;
                      if (isPo) {
                        header = poColumnMap[col.toLowerCase()] ?? col;
                      }
                      return Padding(
                        padding: MySpacing.xy(12, 12),
                        child: MyText.labelLarge(header, fontWeight: 600, color: contentTheme.onBackground),
                      );
                    }),
                  ],
                ),
                if (!isNew)
                  TableRow(
                    decoration: BoxDecoration(color: contentTheme.danger.withValues(alpha: 10 / 255)),
                    children: [
                      Padding(
                        padding: MySpacing.xy(12, 12),
                        child: MyText.bodyMedium("Old Record", fontWeight: 600, color: contentTheme.danger),
                      ),
                      ...columns.map((col) {
                        String oldStr = oldData[col]?.toString() ?? '';
                        String newStr = newData[col]?.toString() ?? '';
                        
                        bool isChanged = oldStr != newStr;
                        if (isChanged) {
                          double? oldNum = double.tryParse(oldStr);
                          double? newNum = double.tryParse(newStr);
                          if (oldNum != null && newNum != null && oldNum == newNum) {
                            isChanged = false;
                          }
                        }

                        return TableCell(
                          verticalAlignment: TableCellVerticalAlignment.fill,
                          child: Container(
                            color: isChanged ? contentTheme.danger.withValues(alpha: 30 / 255) : Colors.transparent,
                            padding: MySpacing.xy(12, 12),
                            alignment: Alignment.centerLeft,
                            child: MyText.bodyMedium(
                              oldStr.isEmpty ? "-" : oldStr,
                              fontWeight: isChanged ? 700 : 500,
                              color: isChanged ? contentTheme.danger : contentTheme.onBackground,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                TableRow(
                  decoration: BoxDecoration(color: contentTheme.success.withValues(alpha: 10 / 255)),
                  children: [
                    Padding(
                      padding: MySpacing.xy(12, 12),
                      child: MyText.bodyMedium("New Record", fontWeight: 600, color: contentTheme.success),
                    ),
                    ...columns.map((col) {
                      String oldStr = oldData[col]?.toString() ?? '';
                      String newStr = newData[col]?.toString() ?? '';
                      
                      bool isChanged = oldStr != newStr;
                      if (isChanged) {
                        double? oldNum = double.tryParse(oldStr);
                        double? newNum = double.tryParse(newStr);
                        if (oldNum != null && newNum != null && oldNum == newNum) {
                          isChanged = false;
                        }
                      }

                      return TableCell(
                        verticalAlignment: TableCellVerticalAlignment.fill,
                        child: Container(
                          color: isChanged && !isNew ? contentTheme.success.withValues(alpha: 30 / 255) : Colors.transparent,
                          padding: MySpacing.xy(12, 12),
                          alignment: Alignment.centerLeft,
                          child: MyText.bodyMedium(
                            newStr.isEmpty ? "-" : newStr,
                            fontWeight: isChanged && !isNew ? 700 : 500,
                            color: isChanged && !isNew ? contentTheme.success : contentTheme.onBackground,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasDiffs = _poDiffs.isNotEmpty || _shippingDiffs.isNotEmpty;

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
                  "Google Sync",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Google Sync', active: true),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.titleMedium("Sync Data with Google", fontWeight: 600),
                  MySpacing.height(16),
                  MyText.bodyMedium("Click 'Check for Updates' to preview differences before importing, or 'Initial Sync' if this is the first time syncing."),
                  MySpacing.height(24),
                  if (_isLoadingDataStatus)
                    SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: contentTheme.primary, strokeWidth: 2))
                  else
                    Row(
                      children: [
                        if (_hasData)
                          MyButton.rounded(
                            onPressed: (_isChecking || _isApplying || _isInitialSyncing) ? null : _checkDiffs,
                            elevation: 0,
                            padding: MySpacing.xy(20, 16),
                            backgroundColor: contentTheme.primary,
                            child: _isChecking 
                              ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: contentTheme.onPrimary, strokeWidth: 2))
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.search, size: 18, color: contentTheme.onPrimary),
                                    MySpacing.width(8),
                                    MyText.labelLarge("Check for Updates", color: contentTheme.onPrimary, fontWeight: 600),
                                  ],
                                ),
                          ),
                        if (!_hasData)
                          MyButton.rounded(
                            onPressed: (_isChecking || _isApplying || _isInitialSyncing) ? null : _initialSync,
                            elevation: 0,
                            padding: MySpacing.xy(20, 16),
                            backgroundColor: contentTheme.secondary,
                            child: _isInitialSyncing 
                              ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: contentTheme.onSecondary, strokeWidth: 2))
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.download, size: 18, color: contentTheme.onSecondary),
                                    MySpacing.width(8),
                                    MyText.labelLarge("Initial Sync", color: contentTheme.onSecondary, fontWeight: 600),
                                  ],
                                ),
                          ),
                        if (hasDiffs) ...[
                          MySpacing.width(16),
                          MyButton.rounded(
                            onPressed: (_isChecking || _isApplying || _isInitialSyncing) ? null : _applySync,
                            elevation: 0,
                            padding: MySpacing.xy(20, 16),
                            backgroundColor: contentTheme.success,
                            child: _isApplying 
                              ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: contentTheme.onPrimary, strokeWidth: 2))
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.save, size: 18, color: contentTheme.onPrimary),
                                    MySpacing.width(8),
                                    MyText.labelLarge("Apply Selected Changes", color: contentTheme.onPrimary, fontWeight: 600),
                                  ],
                                ),
                          ),
                        ]
                      ],
                    ),
                  
                  if (hasDiffs) ...[
                    MySpacing.height(32),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: contentTheme.primary,
                      labelColor: contentTheme.primary,
                      unselectedLabelColor: contentTheme.onBackground.withValues(alpha: 150 / 255),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      tabs: [
                        Tab(text: "Purchase Orders (${_poDiffs.length})"),
                        Tab(text: "Shipping Schedules (${_shippingDiffs.length})"),
                      ],
                    ),
                    MySpacing.height(24),
                    if (_tabController.index == 0)
                      _buildDiffSection("Purchase Orders", _poDiffs, _selectedPoIds, isPo: true)
                    else
                      _buildDiffSection("Shipping Schedules", _shippingDiffs, _selectedShippingIds, isPo: false),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalScrollableTable extends StatefulWidget {
  final Widget child;

  const _HorizontalScrollableTable({required this.child});

  @override
  State<_HorizontalScrollableTable> createState() => _HorizontalScrollableTableState();
}

class _HorizontalScrollableTableState extends State<_HorizontalScrollableTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: MySpacing.bottom(16),
          child: widget.child,
        ),
      ),
    );
  }
}