import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/widgets/my_flex.dart';
import 'package:ccpladmin/helpers/widgets/my_flex_item.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_text_style.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ccpladmin/services/shipping_schedule_service.dart';
import 'package:ccpladmin/services/purchase_order_service.dart';
import 'package:ccpladmin/services/port_master_service.dart';
import 'package:ccpladmin/services/po_master_service.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CreateShippingScheduleScreen extends StatefulWidget {
  const CreateShippingScheduleScreen({super.key});

  @override
  State<CreateShippingScheduleScreen> createState() =>
      _CreateShippingScheduleScreenState();
}

class _CreateShippingScheduleScreenState
    extends State<CreateShippingScheduleScreen> with UIMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _shippingIdController = TextEditingController();
  String? _selectedPol;
  List<String> _polOptions = [];
  final PortMasterService _portMasterService = PortMasterService();
  Color _selectedHighlightColor = Colors.yellow.withOpacity(0.3);

  bool _sortByPod = false;
  bool _sortByDeliveryDate = false;
  bool _sortByProductGroup = false;
  String? _selectedProductGroup;
  List<dynamic> _productGroupOptions = [];
  final PoMasterService _poMasterService = PoMasterService();

  final PurchaseOrderService _purchaseOrderService = PurchaseOrderService();
  List<dynamic> _poList = [];
  final Set<String> _selectedPoIds = {};
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _fetchPurchaseOrders();
    _fetchPorts();
    _fetchProductGroups();
  }

  String _formatQty(dynamic qty) {
    if (qty == null) return '-';
    double? parsed = double.tryParse(qty.toString());
    if (parsed != null) {
      return parsed.toInt().toString();
    }
    return qty.toString();
  }

  @override
  void dispose() {
    _shippingIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  "New Shipping Schedule",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Shipping Schedule'),
                    MyBreadcrumbItem(name: 'New', active: true),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing),
          Padding(
            padding: MySpacing.x(flexSpacing / 2),
            child: MyCard(
              paddingAll: 16,
              borderRadiusAll: 8,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium("Shipping Schedule Details",
                        fontWeight: 600),
                    MySpacing.height(24),
                    MyFlex(
                      children: [
                        MyFlexItem(
                          sizes: 'lg-3 md-6 sm-12',
                          child: _buildTextField(
                            "Shipping ID",
                            "Enter Shipping ID",
                            _shippingIdController,
                            isSmall: true,
                          ),
                        ),
                        MyFlexItem(
                          sizes: 'lg-3 md-6 sm-12',
                          child: _buildDropdownField(
                            "POL",
                            "Select POL",
                            value: _selectedPol,
                            options: _polOptions,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedPol = newValue;
                              });
                            },
                            isSmall: true,
                          ),
                        ),
                        MyFlexItem(
                          sizes: 'lg-3 md-6 sm-12',
                          child: _buildColorPicker(),
                        ),
                        MyFlexItem(
                          sizes: 'lg-12',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MySpacing.height(8),
                              MyText.labelMedium("Sort By", fontWeight: 600),
                              MySpacing.height(16),
                              Wrap(
                                spacing: 24,
                                runSpacing: 16,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _buildCheckbox("POD", _sortByPod, (val) { 
                                    setState(() => _sortByPod = val ?? false);
                                    _sortPoList();
                                  }),
                                  _buildCheckbox("Delivery Date", _sortByDeliveryDate, (val) { 
                                    setState(() => _sortByDeliveryDate = val ?? false);
                                    _sortPoList();
                                  }),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      _buildCheckbox("Product Group", _sortByProductGroup, (val) { 
                                        setState(() {
                                          _sortByProductGroup = val ?? false;
                                          if (!_sortByProductGroup) {
                                            _selectedProductGroup = null;
                                          }
                                        });
                                        _sortPoList();
                                      }),
                                      if (_sortByProductGroup) ...[
                                        MySpacing.width(12),
                                        SizedBox(
                                          width: 220,
                                          child: _buildDropdownField(
                                            "",
                                            "Select Product Group",
                                            value: _selectedProductGroup,
                                            options: _productGroupOptions,
                                            displayMember: 'Product',
                                            valueMember: 'Product',
                                            onChanged: (val) {
                                              setState(() => _selectedProductGroup = val);
                                              _sortPoList();
                                            },
                                            isSmall: true,
                                            isRequired: false,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    MySpacing.height(24),
                    MyText.titleMedium("Select Purchase Orders", fontWeight: 600),
                    MySpacing.height(16),
                    _isLoadingData
                        ? const Center(child: CircularProgressIndicator())
                        : _buildPoListTable(),
                    MySpacing.height(24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyButton.text(
                          onPressed: () => Navigator.pop(context),
                          child: MyText.labelMedium("Cancel"),
                        ),
                        MySpacing.width(16),
                        MyButton.rounded(
                          onPressed: _isLoading ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              if (_selectedPoIds.isEmpty) {
                                Utils.showErrorToast("Please select at least one Purchase Order", context: context);
                                return;
                              }

                              setState(() => _isLoading = true);

                              try {
                                List<Map<String, dynamic>> selectedPoDetails = _poList
                                    .where((po) {
                                      String id = po['_id']?.toString() ?? po['orderId']?.toString() ?? '';
                                      return _selectedPoIds.contains(id);
                                    })
                                    .map((po) => <String, dynamic>{
                                          'orderId': po['orderId'],
                                          'itemCode': po['itemCode'],
                                          'pod': po['pod'],
                                          'qty': po['qty'],
                                          'deliveryLT': po['deliveryLT'] ?? po['deliveryl/t'],
                                        })
                                    .toList();

                                final shippingService = ShippingScheduleService();
                                await shippingService.assignShippingToPOs(
                                  _shippingIdController.text,
                                  _selectedPol,
                                  _selectedHighlightColor.value.toRadixString(16).padLeft(8, '0'),
                                  selectedPoDetails,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: MyText.labelMedium("Schedule saved successfully", color: contentTheme.onPrimary),
                                      backgroundColor: contentTheme.primary,
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Utils.showErrorToast("Error creating schedule: $e", context: context);
                                }
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                          elevation: 0,
                          padding: MySpacing.xy(20, 16),
                          backgroundColor: contentTheme.primary,
                          child: _isLoading 
                            ? SizedBox(
                                height: 16, 
                                width: 16, 
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, 
                                  color: contentTheme.onPrimary
                                )
                              )
                            : MyText.labelMedium(
                                "Save Schedule",
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
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String hint,
      {required String? value,
      required List<dynamic> options,
      ValueChanged<String?>? onChanged,
      String displayMember = 'name',
      String valueMember = 'name',
      bool isRequired = true,
      bool isSmall = false}) {
    return _EditableDropdown(
      label: label,
      hint: hint,
      value: value,
      options: options,
      onChanged: onChanged,
      displayMember: displayMember,
      valueMember: valueMember,
      isRequired: isRequired,
      isSmall: isSmall,
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium("Highlight Color", fontWeight: 600),
        MySpacing.height(4),
        InkWell(
          onTap: _showColorPickerDialog,
          child: InputDecorator(
            decoration: InputDecoration(
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
                borderSide: BorderSide(color: contentTheme.primary),
              ),
              filled: true,
              fillColor: contentTheme.background,
              isDense: true,
              contentPadding: MySpacing.xy(12, 12),
            ),
            child: Row(
              children: [
                Container(
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                    color: _selectedHighlightColor,
                    borderRadius: BorderRadius.circular(4),
                    border: _selectedHighlightColor == Colors.transparent
                        ? Border.all(color: contentTheme.onBackground.withValues(alpha: 80 / 255))
                        : null,
                  ),
                  child: _selectedHighlightColor == Colors.transparent
                      ? Icon(LucideIcons.ban, size: 14, color: contentTheme.onBackground.withValues(alpha: 120 / 255))
                      : null,
                ),
                MySpacing.width(12),
                Expanded(child: MyText.bodyMedium("Select Color", fontWeight: 600, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showColorPickerDialog() async {
    Color pickerColor = _selectedHighlightColor;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: MyText.titleMedium("Select Highlight Color", fontWeight: 600),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true,
              displayThumbColor: true,
              portraitOnly: true,
            ),
          ),
          actions: [
            MyButton.text(
              onPressed: () {
                setState(() => _selectedHighlightColor = Colors.transparent);
                Navigator.of(context).pop();
              },
              child: MyText.bodyMedium("Clear"),
            ),
            MyButton.text(
              onPressed: () => Navigator.of(context).pop(),
              child: MyText.bodyMedium("Cancel"),
            ),
            MyButton.rounded(
              onPressed: () {
                setState(() => _selectedHighlightColor = pickerColor);
                Navigator.of(context).pop();
              },
              elevation: 0,
              backgroundColor: contentTheme.primary,
              child: MyText.bodyMedium("Select", color: contentTheme.onPrimary),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
            child: value
                ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary)
                : null,
          ),
          MySpacing.width(8),
          MyText.bodyMedium(label, fontWeight: 600),
        ],
      ),
    );
  }

  Future<void> _fetchPurchaseOrders() async {
    setState(() => _isLoadingData = true);
    try {
      final data = await _purchaseOrderService.getPurchaseOrders();
      final filteredList = data.where((po) {
        final shippingId = po['shippingId'] ?? po['shippingid'];
        return shippingId == null || 
               shippingId.toString().trim().isEmpty || 
               shippingId.toString().trim().toLowerCase() == 'null';
      }).toList();
      setState(() {
        _poList = filteredList;
      });
      _sortPoList();
    } catch (e) {
      debugPrint("Error fetching POs: $e");
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _fetchPorts() async {
    try {
      final data = await _portMasterService.getPortMasterData();
      setState(() {
        _polOptions = data
            .map((port) => port['portshortname']?.toString() ?? '')
            .where((name) => name.toUpperCase() == 'TUT' || name.toUpperCase() == 'MAA')
            .toList();
      });
    } catch (e) {
      debugPrint("Error fetching ports: $e");
    }
  }

  Future<void> _fetchProductGroups() async {
    try {
      final data = await _poMasterService.getPoMasterData();
      setState(() {
        _productGroupOptions = data['products'] ?? [];
      });
    } catch (e) {
      debugPrint("Error fetching product groups: $e");
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      return null;
    }
    try {
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }
    } catch (_) {}
    return null;
  }

  void _sortPoList() {
    setState(() {
      _poList.sort((a, b) {
        int cmp = 0;
        if (_sortByPod) {
          cmp = (a['pod']?.toString() ?? '').compareTo(b['pod']?.toString() ?? '');
          if (cmp != 0) {
            return cmp;
          }
        }
        if (_sortByDeliveryDate) {
          DateTime? d1 = _parseDate(a['deliveryLT']?.toString());
          DateTime? d2 = _parseDate(b['deliveryLT']?.toString());
          if (d1 != null && d2 != null) {
            cmp = d1.compareTo(d2);
          } else if (d1 != null) {
            cmp = -1;
          } else if (d2 != null) {
            cmp = 1;
          }
          if (cmp != 0) {
            return cmp;
          }
        }
        if (_sortByProductGroup) {
          String prodA = a['product']?.toString() ?? '';
          String prodB = b['product']?.toString() ?? '';
          if (_selectedProductGroup != null && _selectedProductGroup!.isNotEmpty) {
            bool aMatches = prodA.toLowerCase() == _selectedProductGroup!.toLowerCase();
            bool bMatches = prodB.toLowerCase() == _selectedProductGroup!.toLowerCase();
            if (aMatches && !bMatches) return -1;
            if (!aMatches && bMatches) return 1;
          }
          cmp = prodA.compareTo(prodB);
          if (cmp != 0) {
            return cmp;
          }
        }
        return (a['orderId']?.toString() ?? '').compareTo(b['orderId']?.toString() ?? '');
      });
    });
  }

  Widget _buildPoListTable() {
    if (_poList.isEmpty) {
      return Container(
        padding: MySpacing.all(16),
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
        ),
        child: Center(child: MyText.bodyMedium("No Purchase Orders available")),
      );
    }

    bool isAllSelected = _poList.isNotEmpty && _selectedPoIds.length == _poList.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: contentTheme.background,
          border: Border.all(color: Colors.black.withValues(alpha: 0.3), width: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(
                color: Colors.black.withValues(alpha: 0.3),
                width: 0.8),
          ),
          columnWidths: const {
            0: FixedColumnWidth(50),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1.5),
            6: FlexColumnWidth(1.5),
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
                Container(
                  padding: MySpacing.xy(12, 12),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.black.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Center(
                    child: _buildCustomTableCheckbox(
                      isAllSelected,
                      (val) {
                        setState(() {
                          if (val == true) {
                            _selectedPoIds.addAll(_poList.map((po) => po['_id']?.toString() ?? po['orderId']?.toString() ?? '').where((id) => id.isNotEmpty));
                          } else {
                            _selectedPoIds.clear();
                          }
                        });
                      },
                    ),
                  ),
                ),
                _buildHeaderCell("Order ID"),
                _buildHeaderCell("Item Code"),
                _buildHeaderCell("Crop"),
                _buildHeaderCell("POD"),
                _buildHeaderCell("Delivery Date"),
                _buildHeaderCell("Planting Date"),
                _buildHeaderCell("QTY", hasRightBorder: false),
              ],
            ),
            ..._poList.map((po) {
              String id = po['_id']?.toString() ?? po['orderId']?.toString() ?? '';
              bool isSelected = _selectedPoIds.contains(id);
              return TableRow(
                decoration: BoxDecoration(
                  color: isSelected ? _selectedHighlightColor : Colors.transparent,
                ),
                children: [
                  Container(
                    padding: MySpacing.xy(12, 12),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.black.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: Center(
                      child: _buildCustomTableCheckbox(isSelected, (val) {
                        if (id.isEmpty) return;
                        setState(() {
                          if (val == true) {
                            _selectedPoIds.add(id);
                          } else {
                            _selectedPoIds.remove(id);
                          }
                        });
                      }),
                    ),
                  ),
                  _buildCell(po['orderId']?.toString()),
                  _buildCell(po['itemCode']?.toString()),
                  _buildCell(po['crop']?.toString()),
                  _buildCell(po['pod']?.toString()),
                  _buildCell(po['deliveryLT']?.toString()),
                  _buildCell(po['planting']?.toString()),
                  _buildCell(_formatQty(po['qty']), hasRightBorder: false),
                ],
              );
            }),
          ],
        ),
      ),
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
          value ?? "-",
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildCustomTableCheckbox(bool value, ValueChanged<bool?> onChanged) {
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

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {bool readOnly = false,
      VoidCallback? onTap,
      Widget? suffixIcon,
      bool isRequired = true,
      int maxLines = 1,
      bool isNumber = false,
      int? maxLength,
      bool isSmall = false,
      bool isDate = false,
      String? Function(String?)? validator,
      FocusNode? focusNode,
      TextInputAction? textInputAction,
      ValueChanged<String>? onFieldSubmitted}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(label, fontWeight: 600),
        MySpacing.height(isSmall ? 4 : 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          keyboardType: isNumber || isDate ? TextInputType.number : null,
          focusNode: focusNode,
          textInputAction: textInputAction ?? (readOnly ? TextInputAction.none : TextInputAction.next),
          onFieldSubmitted: onFieldSubmitted,
          inputFormatters: [
            if (isNumber) FilteringTextInputFormatter.digitsOnly,
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ],
          validator: validator ?? (isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            suffixIconConstraints: suffixIcon != null
                ? const BoxConstraints(minWidth: 40, minHeight: 24)
                : null,
            hintStyle: MyTextStyle.bodySmall(
                color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
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
              borderSide: BorderSide(color: contentTheme.primary),
            ),
            filled: true,
            fillColor: readOnly ? contentTheme.onBackground.withValues(alpha: 10 / 255) : contentTheme.background,
            isDense: isSmall,
            contentPadding: isSmall ? MySpacing.xy(12, 12) : MySpacing.all(16),
          ),
          style: MyTextStyle.bodyMedium(fontWeight: 600),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _EditableDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final String? value;
  final List<dynamic> options;
  final ValueChanged<String?>? onChanged;
  final String displayMember;
  final String valueMember;
  final bool isRequired;
  final bool isSmall;

  const _EditableDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    this.onChanged,
    this.displayMember = 'name',
    this.valueMember = 'name',
    this.isRequired = true,
    this.isSmall = false,
  });

  @override
  __EditableDropdownState createState() => __EditableDropdownState();
}

class __EditableDropdownState extends State<_EditableDropdown> with UIMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _getDisplayValue(widget.value));
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _EditableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final newDisplay = _getDisplayValue(widget.value);
      if (_controller.text != newDisplay) {
        _controller.text = newDisplay;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<String> _getDisplayOptions() {
    return widget.options.map((option) {
      if (option is String) {
        return option;
      }
      return option[widget.displayMember]?.toString() ?? '';
    }).toList();
  }

  String _getDisplayValue(String? val) {
    if (val == null) {
      return '';
    }
    var option = widget.options.firstWhere((opt) {
      if (opt is String) {
        return opt == val;
      }
      return opt[widget.valueMember]?.toString() == val;
    }, orElse: () => val);

    if (option is String) {
      return option;
    }
    return option[widget.displayMember]?.toString() ?? val;
  }

  String _getValueFromDisplay(String display) {
    var option = widget.options.firstWhere((opt) {
      if (opt is String) {
        return opt == display;
      }
      return opt[widget.displayMember]?.toString() == display;
    }, orElse: () => display);

    if (option is String) {
      return option;
    }
    return option[widget.valueMember]?.toString() ?? display;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          MyText.labelMedium(widget.label, fontWeight: 600),
          MySpacing.height(widget.isSmall ? 4 : 8),
        ],
        LayoutBuilder(
          builder: (context, constraints) => RawAutocomplete<String>(
            focusNode: _focusNode,
            textEditingController: _controller,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (isDisabled) {
                return const Iterable<String>.empty();
              }
              final stringOptions = _getDisplayOptions();
              if (textEditingValue.text.isEmpty) {
                return stringOptions;
              }
              return stringOptions.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              if (widget.onChanged != null) {
                widget.onChanged!(_getValueFromDisplay(selection));
              }
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController fieldTextEditingController,
                FocusNode fieldFocusNode,
                VoidCallback onFieldSubmitted) {
              return TextFormField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                readOnly: isDisabled,
                enabled: !isDisabled,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                onChanged: (text) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(_getValueFromDisplay(text));
                  }
                },
                validator: widget.isRequired
                    ? (val) {
                        if (val == null || val.isEmpty) {
                          return '${widget.label} is required';
                        }
                        return null;
                      }
                    : null,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  suffixIcon: InkWell(
                    onTap: isDisabled
                        ? null
                        : () {
                            if (!fieldFocusNode.hasFocus) {
                              fieldFocusNode.requestFocus();
                            } else {
                              fieldFocusNode.unfocus();
                            }
                          },
                    child: Icon(
                      LucideIcons.chevron_down,
                      size: 20,
                      color: isDisabled
                          ? contentTheme.onBackground.withValues(alpha: 100 / 255)
                          : null,
                    ),
                  ),
                  suffixIconConstraints: widget.isSmall 
                      ? const BoxConstraints(minWidth: 40, minHeight: 24)
                      : null,
                  hintStyle: MyTextStyle.bodySmall(
                      color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
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
                    borderSide: BorderSide(color: contentTheme.primary),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
                  ),
                  filled: true,
                  fillColor: isDisabled
                      ? contentTheme.onBackground.withValues(alpha: 10 / 255)
                      : contentTheme.background,
                  isDense: widget.isSmall,
                  contentPadding: widget.isSmall ? MySpacing.xy(12, 12) : MySpacing.all(16),
                ),
                style: MyTextStyle.bodyMedium(fontWeight: 600),
              );
            },
            optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<String> onSelected,
                Iterable<String> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8),
                  color: contentTheme.background,
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: 200, maxWidth: constraints.maxWidth),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return InkWell(
                          onTap: () {
                            onSelected(option);
                          },
                          child: Padding(
                            padding: MySpacing.xy(16, 12),
                            child: MyText.bodyMedium(option, fontWeight: 600),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
