import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccpladmin/services/product_master_service.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_flex.dart';
import 'package:ccpladmin/helpers/widgets/my_flex_item.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_text_style.dart';
import 'package:ccpladmin/model/polist_model.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ccpladmin/services/purchase_order_service.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';

class PoChecklistScreen extends StatefulWidget {
  final PolistModel data;
  final VoidCallback? onDataFetched;
  final TextEditingController excessController;
  final TextEditingController ccExcessController;
  final TextEditingController prodStartController;
  final TextEditingController prodEndController;
  final TextEditingController prodLTController;
  final TextEditingController daysController;
  final bool hasExistingExcess;
  final bool hasExistingCcExcess;

  const PoChecklistScreen({
    super.key,
    required this.data,
    this.onDataFetched,
    required this.excessController,
    required this.ccExcessController,
    required this.prodStartController,
    required this.prodEndController,
    required this.prodLTController,
    required this.daysController,
    this.hasExistingExcess = false,
    this.hasExistingCcExcess = false,
  });

  @override
  PoChecklistScreenState createState() => PoChecklistScreenState();
}

class PoChecklistScreenState extends State<PoChecklistScreen> with UIMixin {
  final ProductMasterService _productMasterService = ProductMasterService();
  bool _isLoading = true;
  bool hasExistingData = false;
  bool _savedExcess = false;
  bool _savedCcExcess = false;
  bool _savedProductionInfo = false;
  bool _savedPalletConfig = false;

  bool get isExcessReadOnly => widget.hasExistingExcess || _savedExcess;
  bool get isCcExcessReadOnly => widget.hasExistingCcExcess || _savedCcExcess;
  bool get isProductionInfoReadOnly => _savedProductionInfo;
  bool get isPalletConfigReadOnly => hasExistingData || _savedPalletConfig;

  late TextEditingController _totalController;
  late TextEditingController _ccTotalController;

  String? _packageType1;
  late TextEditingController _palletHeightController1;
  late TextEditingController _piecesPerPackageController1;
  late TextEditingController _packagesInALayerController1;
  late TextEditingController _noOfLayersController1;
  late TextEditingController _packagesPerPalletController1;

  String? _packageType2;
  late TextEditingController _palletHeightController2;
  late TextEditingController _piecesPerPackageController2;
  late TextEditingController _packagesInALayerController2;
  late TextEditingController _noOfLayersController2;
  late TextEditingController _packagesPerPalletController2;

  String? get packageType1 => _packageType1;
  String? get packageType2 => _packageType2;

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController();
    _ccTotalController = TextEditingController();

    _palletHeightController1 = TextEditingController(text: "210");
    _piecesPerPackageController1 = TextEditingController();
    _packagesInALayerController1 = TextEditingController();
    _noOfLayersController1 = TextEditingController();
    _packagesPerPalletController1 = TextEditingController();

    _palletHeightController2 = TextEditingController(text: "240");
    _piecesPerPackageController2 = TextEditingController();
    _packagesInALayerController2 = TextEditingController();
    _noOfLayersController2 = TextEditingController();
    _packagesPerPalletController2 = TextEditingController();
    
    widget.excessController.addListener(_calculateTotal);
    widget.ccExcessController.addListener(_calculateCcTotal);
    _calculateTotal();
    _calculateCcTotal();

    _savedProductionInfo = widget.prodStartController.text.isNotEmpty && widget.prodEndController.text.isNotEmpty && widget.prodLTController.text.isNotEmpty;

    _fetchAndPopulateData();
  }
  
  String _formatQty(dynamic qty) {
    if (qty == null) return '';
    double? parsed = double.tryParse(qty.toString());
    if (parsed != null) {
      return parsed.toInt().toString();
    }
    return qty.toString();
  }

  @override
  void dispose() {
    widget.excessController.removeListener(_calculateTotal);
    widget.ccExcessController.removeListener(_calculateCcTotal);
    _totalController.dispose();
    _ccTotalController.dispose();

    _palletHeightController1.dispose();
    _piecesPerPackageController1.dispose();
    _packagesInALayerController1.dispose();
    _noOfLayersController1.dispose();
    _packagesPerPalletController1.dispose();

    _palletHeightController2.dispose();
    _piecesPerPackageController2.dispose();
    _packagesInALayerController2.dispose();
    _noOfLayersController2.dispose();
    _packagesPerPalletController2.dispose();
    super.dispose();
  }

  String _getPlanterCode(PolistModel data) {
    List<String> parts = [data.planter, data.planterShape,data.planterSize,  data.space]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.isNotEmpty ? "P${parts.join('').toUpperCase()}" : "--";
  }

    String _getDrainCode(PolistModel data) {
    List<String> parts = [data.drain, data.drainShape, data.drainSize, data.drainPosition]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.isNotEmpty ? "D${parts.join('').toUpperCase()}" : "--";
  }

  Future<void> _fetchAndPopulateData() async {
    try {
      final configs = await _productMasterService.getAllPalletConfig();
      final itemConfigs = configs.where((c) => c['itemcode'] == widget.data.itemCode).toList();

      if (mounted) {
        setState(() {
          if (itemConfigs.isNotEmpty) {
            hasExistingData = true;
            final config1 = itemConfigs[0];
            _packageType1 = config1['packagetype']?.toString();
            _palletHeightController1.text = config1['palletheight']?.toString() ?? '';
            _piecesPerPackageController1.text = config1['piecesperpackage']?.toString() ?? '';
            _packagesInALayerController1.text = config1['packagesinalayer']?.toString() ?? '';
            _noOfLayersController1.text = config1['nooflayers']?.toString() ?? '';
            _packagesPerPalletController1.text = config1['packagesperpallet']?.toString() ?? '';
          }

          if (itemConfigs.length > 1) {
            final config2 = itemConfigs[1];
            _packageType2 = config2['packagetype']?.toString();
            _palletHeightController2.text = config2['palletheight']?.toString() ?? '';
            _piecesPerPackageController2.text = config2['piecesperpackage']?.toString() ?? '';
            _packagesInALayerController2.text = config2['packagesinalayer']?.toString() ?? '';
            _noOfLayersController2.text = config2['nooflayers']?.toString() ?? '';
            _packagesPerPalletController2.text = config2['packagesperpallet']?.toString() ?? '';
          }
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch pallet config: $e");
      // Optionally show a toast or message
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (widget.onDataFetched != null) {
          widget.onDataFetched!();
        }
      }
    }
  }

  Future<void> savePalletConfig() async {
    if (_packageType1 != null && _packageType1!.isNotEmpty) {
      await _productMasterService.addPalletConfig({
        'itemcode': widget.data.itemCode,
        'packagetype': _packageType1 ?? '',
        'palletheight': _palletHeightController1.text,
        'piecesperpackage': _piecesPerPackageController1.text,
        'packagesinalayer': _packagesInALayerController1.text,
        'nooflayers': _noOfLayersController1.text,
        'packagesperpallet': _packagesPerPalletController1.text,
      });
    }

    if (_packageType2 != null && _packageType2!.isNotEmpty) {
      await _productMasterService.addPalletConfig({
        'itemcode': widget.data.itemCode,
        'packagetype': _packageType2,
        'palletheight': _palletHeightController2.text,
        'piecesperpackage': _piecesPerPackageController2.text,
        'packagesinalayer': _packagesInALayerController2.text,
        'nooflayers': _noOfLayersController2.text,
        'packagesperpallet': _packagesPerPalletController2.text,
      });
    }
  }

  void markExcessAsSaved() {
    if (mounted) {
      setState(() {
        if (widget.excessController.text.isNotEmpty) _savedExcess = true;
        if (widget.ccExcessController.text.isNotEmpty) _savedCcExcess = true;
      });
    }
  }

  void _calculateTotal() {
    String qtyStr = widget.data.qty.toString().replaceAll(RegExp(r'[^0-9\.]'), '');
    double poQty = double.tryParse(qtyStr) ?? 0;
    double excess = double.tryParse(widget.excessController.text.replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    
    double total = poQty + excess;
    String totalStr = total.toInt().toString();
    
    if (_totalController.text != totalStr) {
      _totalController.text = totalStr;
    }
  }

  void _calculateCcTotal() {
    String qtyStr = widget.data.qty.toString().replaceAll(RegExp(r'[^0-9\.]'), '');
    double poQty = double.tryParse(qtyStr) ?? 0;
    double excess = double.tryParse(widget.ccExcessController.text.replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    
    double total = poQty + excess;
    String totalStr = total.toInt().toString();
    
    if (_ccTotalController.text != totalStr) {
      _ccTotalController.text = totalStr;
    }
  }

  void _calculateDays() {
    if (widget.prodStartController.text.isNotEmpty && widget.prodEndController.text.isNotEmpty) {
      try {
        DateTime? start;
        DateTime? end;
        
        final startParts = widget.prodStartController.text.split('/');
        if(startParts.length == 3) {
          start = DateTime(int.parse(startParts[2]), int.parse(startParts[1]), int.parse(startParts[0]));
        }
        
        final endParts = widget.prodEndController.text.split('/');
        if(endParts.length == 3) {
          end = DateTime(int.parse(endParts[2]), int.parse(endParts[1]), int.parse(endParts[0]));
        }
        
        if (start != null && end != null) {
          int days = end.difference(start).inDays;
          if (days < 0) {
             widget.daysController.text = "0";
          } else {
             widget.daysController.text = days.toString();
          }
        }
      } catch (e) {
        // Ignore parse errors
      }
    } else {
      widget.daysController.text = "";
    }
  }

  Widget _buildDisplayField(
    String label,
    String value, {
    bool multiline = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(label, fontWeight: 600),
        MySpacing.height(8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          maxLines: multiline ? maxLines : 1,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.primary),
            ),
            filled: true,
            fillColor: contentTheme.background.withValues(alpha: 20 / 255),
            contentPadding: MySpacing.xy(16, 12),
            isDense: true,
          ),
          style: MyTextStyle.bodyMedium(fontWeight: 600),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isNumber = false, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(label, fontWeight: 600),
        MySpacing.height(8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: isNumber ? TextInputType.number : null,
          inputFormatters: [
            if (isNumber) FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: MyTextStyle.bodySmall(
                color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.primary),
            ),
            filled: true,
            fillColor: readOnly ? contentTheme.background.withValues(alpha: 20 / 255) : contentTheme.background,
            contentPadding: MySpacing.xy(16, 12),
            isDense: true,
          ),
          style: MyTextStyle.bodyMedium(fontWeight: 600),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, String? value, List<String> options, ValueChanged<String?>? onChanged) {
    return _EditableDropdown(
      label: label,
      hint: hint,
      value: value,
      options: options,
      onChanged: onChanged,
      isRequired: false,
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty && controller.text.length == 10) {
      try {
        final parts = controller.text.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          initialDate = DateTime(year, month, day);
        }
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
      if (controller == widget.prodStartController || controller == widget.prodEndController) {
        _calculateDays();
      }
    }
  }

  Widget _buildDatePickerField(String label, String hint, TextEditingController controller, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(label, fontWeight: 600),
        MySpacing.height(8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: TextInputType.number,
          inputFormatters: [
            _DateInputFormatter(),
          ],
          onChanged: (val) {
            if (controller == widget.prodStartController || controller == widget.prodEndController) {
              _calculateDays();
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: MyTextStyle.bodySmall(
                color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
            suffixIcon: InkWell(
              onTap: readOnly ? null : () => _selectDate(context, controller),
              child: Icon(
                LucideIcons.calendar,
                size: 20,
                color: contentTheme.onBackground.withValues(alpha: 100 / 255),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.primary),
            ),
            filled: true,
            fillColor: readOnly ? contentTheme.background.withValues(alpha: 20 / 255) : contentTheme.background,
            contentPadding: MySpacing.xy(16, 12),
            isDense: true,
          ),
          style: MyTextStyle.bodyMedium(fontWeight: 600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return MyFlex(
      contentPadding: false,
      children: [
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildDisplayField("Item Code", widget.data.itemCode),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildDisplayField("PO QTY", _formatQty(widget.data.qty)),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildInputField("Excess", "Enter Excess", widget.excessController, isNumber: true, readOnly: isExcessReadOnly),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildInputField("Total", "Enter Total", _totalController, isNumber: true, readOnly: true),
        ),
        if (!isExcessReadOnly)
          MyFlexItem(
            sizes: 'lg-4 md-8 sm-12',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.labelMedium("Action", fontWeight: 600, color: Colors.transparent),
                MySpacing.height(8),
                Row(
                  children: [
                    MyButton.outlined(
                      onPressed: () {
                        widget.excessController.clear();
                      },
                      borderColor: contentTheme.danger,
                      padding: MySpacing.xy(20, 16),
                      child: MyText.bodyMedium("Cancel", color: contentTheme.danger, fontWeight: 600),
                    ),
                    MySpacing.width(16),
                    MyButton.rounded(
                      onPressed: () async {
                        try {
                          final service = PurchaseOrderService();
                          await service.updatePurchaseOrder(
                            widget.data.orderId,
                            {'excess': widget.excessController.text},
                          );
                          if (mounted) {
                            setState(() {
                              _savedExcess = true;
                            });
                            Utils.showSuccessToast(
                              "Excess saved successfully!",
                              context: context,
                            );
                            if (widget.onDataFetched != null) {
                              widget.onDataFetched!();
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            Utils.showErrorToast(
                              "Error saving: $e",
                              context: context,
                            );
                          }
                        }
                      },
                      elevation: 0,
                      padding: MySpacing.xy(24, 16),
                      backgroundColor: contentTheme.primary,
                      child: MyText.bodyMedium("Save", color: contentTheme.onPrimary, fontWeight: 600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (widget.data.coverCutting.toString().toLowerCase() == 'yes') ...[
          MyFlexItem(
            sizes: 'lg-12',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MySpacing.height(16),
                MyText.titleMedium("Cover Cutting", fontWeight: 600),
                Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
              ],
            ),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildDisplayField("Cover Cutting Code", "Planter Details: ${_getPlanterCode(widget.data)}\nDrain Details: ${_getDrainCode(widget.data)}", multiline: true, maxLines: 2),
          ),
          MyFlexItem(
            sizes: 'lg-2 md-3 sm-6',
            child: _buildDisplayField("PO QTY", _formatQty(widget.data.qty)),
          ),
          MyFlexItem(
            sizes: 'lg-2 md-3 sm-6',
            child: _buildInputField("CC Excess", "Enter CC Excess", widget.ccExcessController, isNumber: true, readOnly: isCcExcessReadOnly),
          ),
          MyFlexItem(
            sizes: 'lg-2 md-3 sm-6',
            child: _buildInputField("CC Total", "Enter CC Total", _ccTotalController, isNumber: true, readOnly: true),
          ),
          if (!isCcExcessReadOnly)
            MyFlexItem(
              sizes: 'lg-3 md-9 sm-12',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.labelMedium("Action", fontWeight: 600, color: Colors.transparent),
                  MySpacing.height(8),
                  Row(
                    children: [
                      MyButton.outlined(
                        onPressed: () {
                          widget.ccExcessController.clear();
                        },
                        borderColor: contentTheme.danger,
                        padding: MySpacing.xy(20, 16),
                        child: MyText.bodyMedium("Cancel", color: contentTheme.danger, fontWeight: 600),
                      ),
                      MySpacing.width(16),
                      MyButton.rounded(
                        onPressed: () async {
                          try {
                            final service = PurchaseOrderService();
                            await service.updatePurchaseOrder(
                              widget.data.orderId,
                              {'ccexcess': widget.ccExcessController.text},
                            );
                            if (mounted) {
                              setState(() {
                                _savedCcExcess = true;
                              });
                              Utils.showSuccessToast(
                                "Cover Cutting Excess saved successfully!",
                                context: context,
                              );
                              if (widget.onDataFetched != null) {
                                widget.onDataFetched!();
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              Utils.showErrorToast(
                                "Error saving: $e",
                                context: context,
                              );
                            }
                          }
                        },
                        elevation: 0,
                        padding: MySpacing.xy(24, 16),
                        backgroundColor: contentTheme.primary,
                        child: MyText.bodyMedium("Save", color: contentTheme.onPrimary, fontWeight: 600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
        MyFlexItem(
          sizes: 'lg-12',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySpacing.height(16),
              MyText.titleMedium("Production Information", fontWeight: 600),
              Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
            ],
          ),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildDatePickerField("Production Start", "Select Date", widget.prodStartController, readOnly: isProductionInfoReadOnly),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildDatePickerField("Production End", "Select Date", widget.prodEndController, readOnly: isProductionInfoReadOnly),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildDatePickerField("Production L/T", "Select Date", widget.prodLTController, readOnly: isProductionInfoReadOnly),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildInputField("Days", "Calculated", widget.daysController, isNumber: true, readOnly: true),
        ),
        if (!isProductionInfoReadOnly)
        MyFlexItem(
          sizes: 'lg-4 md-8 sm-12',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.labelMedium("Action", fontWeight: 600, color: Colors.transparent),
              MySpacing.height(8),
              Row(
                children: [
                  MyButton.outlined(
                    onPressed: () {
                      widget.prodStartController.clear();
                      widget.prodEndController.clear();
                      widget.prodLTController.clear();
                      widget.daysController.clear();
                    },
                    borderColor: contentTheme.danger,
                    padding: MySpacing.xy(20, 16),
                    child: MyText.bodyMedium("Cancel", color: contentTheme.danger, fontWeight: 600),
                  ),
                  MySpacing.width(16),
                  MyButton.rounded(
                    onPressed: () async {
                      try {
                        final service = PurchaseOrderService();
                        await service.updatePurchaseOrder(
                          widget.data.orderId,
                          {
                            'productionstart': widget.prodStartController.text,
                            'productionend': widget.prodEndController.text,
                            'productionlt': widget.prodLTController.text,
                            'days': widget.daysController.text,
                            'updatedby': 'Admin',
                            'createdby': 'Admin',
                          },
                        );
                        if (mounted) {
                          setState(() {
                            _savedProductionInfo = true;
                          });
                          Utils.showSuccessToast(
                            "Production Information saved successfully!",
                            context: context,
                          );
                          if (widget.onDataFetched != null) {
                            widget.onDataFetched!();
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          Utils.showErrorToast(
                            "Error saving: $e",
                            context: context,
                          );
                        }
                      }
                    },
                    elevation: 0,
                    padding: MySpacing.xy(24, 16),
                    backgroundColor: contentTheme.primary,
                    child: MyText.bodyMedium("Save", color: contentTheme.onPrimary, fontWeight: 600),
                  ),
                ],
              ),
            ],
          ),
        ),
        MyFlexItem(
          sizes: 'lg-12',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySpacing.height(16),
              MyText.titleMedium("Pallet Configuration 1", fontWeight: 600),
              Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
            ],
          ),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildDropdownField("Package Type", "Select Type", _packageType1, ['Boxes', 'Bundles', 'Items'], isPalletConfigReadOnly ? null : (val) => setState(() => _packageType1 = val)),
        ),
        MyFlexItem(sizes: 'lg-2 md-4 sm-6', child: _buildInputField("Pallet Height", "Enter Height", _palletHeightController1, isNumber: true, readOnly: isPalletConfigReadOnly)),
        MyFlexItem(sizes: 'lg-2 md-4 sm-6', child: _buildInputField("Pieces/Package", "Enter Pieces", _piecesPerPackageController1, isNumber: true, readOnly: isPalletConfigReadOnly)),
        MyFlexItem(sizes: 'lg-2 md-4 sm-6', child: _buildInputField("Packages/Layer", "Enter Packages", _packagesInALayerController1, isNumber: true, readOnly: isPalletConfigReadOnly)),
        MyFlexItem(sizes: 'lg-2 md-4 sm-6', child: _buildInputField("No. of Layers", "Enter Layers", _noOfLayersController1, isNumber: true, readOnly: isPalletConfigReadOnly)),
        MyFlexItem(sizes: 'lg-2 md-4 sm-6', child: _buildInputField("Packages/Pallet", "Enter Total", _packagesPerPalletController1, isNumber: true, readOnly: isPalletConfigReadOnly)),
        
        MyFlexItem(
          sizes: 'lg-12',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MySpacing.height(16),
              MyText.titleMedium("Pallet Configuration 2", fontWeight: 600),
              Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
            ],
          ),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildDropdownField("Package Type", "Select Type", _packageType2, ['Boxes', 'Bundles', 'Items'], isPalletConfigReadOnly ? null : (val) => setState(() => _packageType2 = val)),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildInputField("Pallet Height", "Enter Height", _palletHeightController2, isNumber: true, readOnly: isPalletConfigReadOnly),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildInputField("Pieces/Package", "Enter Pieces", _piecesPerPackageController2, isNumber: true, readOnly: isPalletConfigReadOnly),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildInputField("Packages/Layer", "Enter Packages", _packagesInALayerController2, isNumber: true, readOnly: isPalletConfigReadOnly),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildInputField("No. of Layers", "Enter Layers", _noOfLayersController2, isNumber: true, readOnly: isPalletConfigReadOnly),
        ),
        MyFlexItem(
          sizes: 'lg-2 md-4 sm-6',
          child: _buildInputField("Packages/Pallet", "Enter Total", _packagesPerPalletController2, isNumber: true, readOnly: isPalletConfigReadOnly),
        ),
        if (!isPalletConfigReadOnly)
          MyFlexItem(
            sizes: 'lg-12',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyButton.outlined(
                      onPressed: () {
                        setState(() {
                          _packageType1 = null;
                          _palletHeightController1.text = "210";
                          _piecesPerPackageController1.clear();
                          _packagesInALayerController1.clear();
                          _noOfLayersController1.clear();
                          _packagesPerPalletController1.clear();

                          _packageType2 = null;
                          _palletHeightController2.text = "240";
                          _piecesPerPackageController2.clear();
                          _packagesInALayerController2.clear();
                          _noOfLayersController2.clear();
                          _packagesPerPalletController2.clear();
                        });
                      },
                      borderColor: contentTheme.danger,
                      padding: MySpacing.xy(20, 16),
                      child: MyText.bodyMedium("Cancel", color: contentTheme.danger, fontWeight: 600),
                    ),
                    MySpacing.width(16),
                    MyButton.rounded(
                      onPressed: () async {
                        try {
                          await savePalletConfig();
                          if (mounted) {
                            setState(() {
                              _savedPalletConfig = true;
                            });
                            Utils.showSuccessToast(
                              "Pallet Configuration saved successfully!",
                              context: context,
                            );
                            if (widget.onDataFetched != null) {
                              widget.onDataFetched!();
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            Utils.showErrorToast(
                              "Error saving: $e",
                              context: context,
                            );
                          }
                        }
                      },
                      elevation: 0,
                      padding: MySpacing.xy(24, 16),
                      backgroundColor: contentTheme.primary,
                      child: MyText.bodyMedium("Save", color: contentTheme.onPrimary, fontWeight: 600),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.length > newValue.text.length) {
      return newValue;
    }
    
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) {
      text = text.substring(0, 8);
    }

    StringBuffer newText = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) {
        newText.write('/');
      }
      newText.write(text[i]);
    }

    if (text.length == 2 || text.length == 4) {
      newText.write('/');
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
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
  final bool isRequired;

  const _EditableDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    this.onChanged,
    this.isRequired = true,
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
      if (option is String) return option;
      return option['name']?.toString() ?? '';
    }).toList();
  }

  String _getDisplayValue(String? val) {
    if (val == null) return '';
    var option = widget.options.firstWhere((opt) {
      if (opt is String) return opt == val;
      return opt['id']?.toString() == val;
    }, orElse: () => val);

    if (option is String) return option;
    return option['name']?.toString() ?? val;
  }

  String _getValueFromDisplay(String display) {
    var option = widget.options.firstWhere((opt) {
      if (opt is String) return opt == display;
      return opt['name']?.toString() == display;
    }, orElse: () => display);

    if (option is String) return option;
    return option['id']?.toString() ?? display;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(widget.label, fontWeight: 600),
        MySpacing.height(8),
        LayoutBuilder(
          builder: (context, constraints) => RawAutocomplete<String>(
            focusNode: _focusNode,
            textEditingController: _controller,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (isDisabled) return const Iterable<String>.empty();
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
                  _UpperCaseTextFormatter(),
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
                      LucideIcons.chevronDown,
                      size: 20,
                      color: isDisabled
                          ? contentTheme.onBackground.withValues(alpha: 100 / 255)
                          : null,
                    ),
                  ),
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
                  isDense: false,
                  contentPadding: MySpacing.all(16),
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
                  elevation: 6.0,
                  shadowColor: Colors.black.withAlpha(50),
                  color: contentTheme.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: contentTheme.onBackground.withAlpha(20),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: 220, maxWidth: constraints.maxWidth),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        final isSelected = option.toLowerCase() == _controller.text.trim().toLowerCase();
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? contentTheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected ? Colors.white : contentTheme.onBackground,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    LucideIcons.check,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ],
                            ),
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