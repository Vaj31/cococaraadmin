import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:ccpladmin/helpers/widgets/my_text_style.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/model/polist_model.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/services/supplier_service.dart';
import 'package:ccpladmin/features/po/presentation/views/po_checklist_screen.dart';
import 'package:ccpladmin/services/product_master_service.dart';
import 'package:ccpladmin/services/purchase_order_service.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';

class AssignSuppliersScreen extends StatefulWidget {
  final PolistModel data;

  const AssignSuppliersScreen({super.key, required this.data});

  @override
  AssignSuppliersScreenState createState() => AssignSuppliersScreenState();
}

class AssignSuppliersScreenState extends State<AssignSuppliersScreen> with UIMixin {
  
  List<dynamic> _suppliers = [];
  List<Map<String, dynamic>> _assignedSuppliers = [];
  final List<Map<String, dynamic>> _assignedCcSuppliers = [];

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
    _fetchAssignedSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final supplierService = SupplierService();
      final data = await supplierService.getSuppliers();
      setState(() {
        _suppliers = data;
      });
    } catch (e) {
      debugPrint('Error loading suppliers: $e');
    }
  }

  Future<void> _fetchAssignedSuppliers() async {
    try {
      final supplierService = SupplierService();
      final data = await supplierService.getAssignedSuppliers(widget.data.orderId, widget.data.itemCode);
      if (mounted) {
        setState(() {
          _assignedSuppliers = List<Map<String, dynamic>>.from(data.map((e) => {
            'poNo': e['poNo']?.toString() ?? '',
            'supplierId': e['supplierId']?.toString() ?? '',
            'machine': e['machine']?.toString() ?? '',
            'qty': e['qty']?.toString() ?? '',
          }));
        });
      }
    } catch (e) {
      debugPrint('Error loading assigned suppliers: $e');
    }
  }

  Future<void> saveAssignedSuppliers() async {
    try {
      // Fetch the current purchase order to get the shipping ID
      final poService = PurchaseOrderService();
      final poData = await poService.getPurchaseOrder(widget.data.orderId);
      final orderData = poData is List ? (poData.isNotEmpty ? poData.first : null) : poData;

      String shippingId = 'not assigned';
      if (orderData != null && orderData['shippingId'] != null && orderData['shippingId'].toString().trim().isNotEmpty) {
        shippingId = orderData['shippingId'].toString().trim();
      }

      final service = SupplierService();
      final payload = {
        'orderId': widget.data.orderId,
        'itemCode': widget.data.itemCode,
        'shippingId': shippingId,
        'suppliers': _assignedSuppliers,
        'ccSuppliers': _assignedCcSuppliers,
      };
      final response = await service.saveAssignedSuppliers(payload);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save assigned suppliers');
      }
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildDialogTextField(String label, String hint, TextEditingController controller, {bool isNumber = false, bool readOnly = false, bool isSmall = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(label, fontWeight: 600),
        MySpacing.height(isSmall ? 4 : 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: isNumber ? TextInputType.number : null,
          validator: readOnly ? null : validator ?? (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label is required";
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
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
            fillColor: readOnly ? contentTheme.onBackground.withValues(alpha: 10 / 255) : contentTheme.background,
            isDense: true,
            contentPadding: isSmall ? MySpacing.xy(8, 8) : MySpacing.xy(12, 12),
          ),
          style: isSmall ? MyTextStyle.bodySmall(fontWeight: 600) : null,
        ),
        MySpacing.height(16),
      ],
    );
  }

  Widget _buildDialogDropdownField(
    String label,
    String hint,
    String? value,
    List<dynamic> options,
    ValueChanged<String?> onChanged,
    {Key? key, String displayMember = 'label', String valueMember = 'value'}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EditableDropdown(
          key: key,
          label: label,
          hint: hint,
          value: value,
          options: options,
          onChanged: onChanged,
          displayMember: displayMember,
          valueMember: valueMember,
        ),
        MySpacing.height(16),
      ],
    );
  }

  Future<void> _checkAndProceed(VoidCallback action) async {
    // 1. Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final poService = PurchaseOrderService();
      final poData = await poService.getPurchaseOrder(widget.data.orderId);
      final orderData = poData is List ? poData.first : poData;

      final productMasterService = ProductMasterService();
      final configs = await productMasterService.getAllPalletConfig();
      final itemConfigs = configs.where((c) => c['itemcode'] == widget.data.itemCode).toList();

      if (mounted) {
        Navigator.pop(context); // Dismiss loading indicator
      }

      if (orderData == null) {
        Utils.showErrorToast(
          "Failed to fetch order details",
          context: context,
        );
        return;
      }

      // Check completeness
      String excess = orderData['excess']?.toString() ?? '';
      bool hasCoverCutting = widget.data.coverCutting.toString().toLowerCase() == 'yes';
      String ccExcess = orderData['ccExcess']?.toString() ?? orderData['ccexcess']?.toString() ?? '';
      
      String prodStart = orderData['prodStart']?.toString() ?? orderData['productionstart']?.toString() ?? '';
      String prodEnd = orderData['prodEnd']?.toString() ?? orderData['productionend']?.toString() ?? '';
      String prodLT = orderData['prodLT']?.toString() ?? orderData['productionlt']?.toString() ?? '';

      bool isComplete = excess.trim().isNotEmpty &&
          (!hasCoverCutting || ccExcess.trim().isNotEmpty) &&
          prodStart.trim().isNotEmpty &&
          prodEnd.trim().isNotEmpty &&
          prodLT.trim().isNotEmpty &&
          itemConfigs.isNotEmpty;

      if (isComplete) {
        action();
      } else {
        // Show complete checklist popup
        if (mounted) {
          _showCompleteChecklistDialog(orderData, itemConfigs.isNotEmpty, action);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading indicator if error
      }
      Utils.showErrorToast(
        "Error checking PO checklist: $e",
        context: context,
      );
    }
  }

  void _showCompleteChecklistDialog(
      Map<String, dynamic> orderData, bool hasPalletConfig, VoidCallback onComplete) {
    // We instantiate controllers
    String val(String key) => orderData[key]?.toString() ?? '';

    final TextEditingController excessController = TextEditingController(text: val('excess'));
    final TextEditingController ccExcessController = TextEditingController(text: val('ccExcess').isNotEmpty ? val('ccExcess') : val('ccexcess'));
    final TextEditingController prodStartController = TextEditingController(text: val('prodStart').isNotEmpty ? val('prodStart') : val('productionstart'));
    final TextEditingController prodEndController = TextEditingController(text: val('prodEnd').isNotEmpty ? val('prodEnd') : val('productionend'));
    final TextEditingController prodLTController = TextEditingController(text: val('prodLT').isNotEmpty ? val('prodLT') : val('productionlt'));
    final TextEditingController daysController = TextEditingController(text: val('days'));

    bool hasExistingExcess = val('excess').isNotEmpty;
    bool hasExistingCcExcess = (val('ccExcess').isNotEmpty || val('ccexcess').isNotEmpty);

    final checklistKey = GlobalKey<PoChecklistScreenState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium("Complete PO Checklist", fontWeight: 600),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: PoChecklistScreen(
                key: checklistKey,
                data: widget.data,
                excessController: excessController,
                ccExcessController: ccExcessController,
                prodStartController: prodStartController,
                prodEndController: prodEndController,
                prodLTController: prodLTController,
                daysController: daysController,
                hasExistingExcess: hasExistingExcess,
                hasExistingCcExcess: hasExistingCcExcess,
              ),
            ),
          ),
          actions: [
            MyButton.text(
              onPressed: () => Navigator.pop(context),
              padding: MySpacing.xy(20, 16),
              child: MyText.bodyMedium("Cancel"),
            ),
            MyButton.rounded(
              onPressed: () async {
                // Validate fields:
                if (excessController.text.trim().isEmpty) {
                  Utils.showWarningToast(
                    "Excess is required",
                    context: context,
                  );
                  return;
                }
                
                bool hasCoverCutting = widget.data.coverCutting.toString().toLowerCase() == 'yes';
                if (hasCoverCutting && ccExcessController.text.trim().isEmpty) {
                  Utils.showWarningToast(
                    "Cover Cutting Excess is required",
                    context: context,
                  );
                  return;
                }

                if (prodStartController.text.trim().isEmpty ||
                    prodEndController.text.trim().isEmpty ||
                    prodLTController.text.trim().isEmpty) {
                  Utils.showWarningToast(
                    "Production details (Start, End, L/T) are required",
                    context: context,
                  );
                  return;
                }

                final state = checklistKey.currentState;
                if (state != null) {
                  if (!state.hasExistingData && (state.packageType1 == null || state.packageType1!.isEmpty)) {
                    Utils.showWarningToast(
                      "Pallet Configuration Package Type is required",
                      context: context,
                    );
                    return;
                  }
                }

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  // Save Pallet Config
                  if (state != null) {
                    await state.savePalletConfig();
                  }

                  // Save Purchase Order (Excess, CC Excess, Production Info)
                  final service = PurchaseOrderService();
                  await service.updatePurchaseOrder(
                    widget.data.orderId,
                    {
                      'excess': excessController.text,
                      'ccexcess': ccExcessController.text,
                      'productionstart': prodStartController.text,
                      'productionend': prodEndController.text,
                      'productionlt': prodLTController.text,
                      'days': daysController.text,
                      'updatedby': 'Admin',
                      'createdby': 'Admin',
                    },
                  );

                  // Dismiss loading indicator
                  Navigator.pop(context);
                  // Update widget.data locally so AssignSuppliersScreen knows the new values
                  widget.data.excess = excessController.text;
                  widget.data.ccExcess = ccExcessController.text;
                  setState(() {});

                  // Dismiss checklist dialog
                  Navigator.pop(context);

                  Utils.showSuccessToast(
                    "Checklist completed successfully!",
                    context: context,
                  );

                  // Proceed to original action (assign supplier or assign cc supplier)
                  Future.microtask(() {
                    if (mounted) onComplete();
                  });
                } catch (e) {
                  // Dismiss loading indicator
                  Navigator.pop(context);
                  Utils.showErrorToast(
                    "Error saving checklist: $e",
                    context: context,
                  );
                }
              },
              elevation: 0,
              padding: MySpacing.xy(24, 16),
              backgroundColor: contentTheme.primary,
              child: MyText.bodyMedium("Save & Proceed", color: contentTheme.onPrimary, fontWeight: 600),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAssignSupplierDialog() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController poNoController = TextEditingController();
    final TextEditingController qtyController = TextEditingController();

    String? selectedSupplierId;
    String? selectedMachine;

    final supplierService = SupplierService();

    List<Map<String, String>> supplierOptions = _suppliers.map((s) {
      return {
        'id': (s['supplierid'] ?? s['supplierId'])?.toString() ?? '',
        'name': (s['suppliername'] ?? s['supplierName'] ?? s['supplierid'] ?? s['supplierId'])?.toString() ?? '',
      };
    }).where((s) => s['id']!.isNotEmpty).toList();
        
    List<String> getMachineOptions(String? suppId) {
      if (suppId == null) return [];
      var supplier = _suppliers.firstWhere((s) => (s['supplierid']?.toString() ?? s['supplierId']?.toString()) == suppId, orElse: () => {});
      if (supplier.isEmpty) return ['N/A'];
      dynamic rawMachines = supplier['machines'] ?? supplier['machinecodes'] ?? supplier['machineCodes'] ?? supplier['machineCodesList'];
      List<String> parsedMachines = [];
      if (rawMachines is List) {
        parsedMachines = rawMachines.map((e) => e.toString()).toList();
      } else if (rawMachines is String && rawMachines.isNotEmpty) {
        parsedMachines = rawMachines.split(',').map((e) => e.trim()).toList();
      }
      List<String> list = parsedMachines.where((e) => e.isNotEmpty).toSet().toList();
      if (list.isEmpty) {
        return ['N/A'];
      }
      if (!list.contains('N/A')) {
        list.add('N/A');
      }
      return list;
    }

    List<String> machineOptions = getMachineOptions(selectedSupplierId);
    selectedMachine = (machineOptions.length == 1 && machineOptions.first == 'N/A') ? 'N/A' : null;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            double remainingQty = _poTotalQty - _totalAssignedQty;
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.titleMedium("Assign Supplier", fontWeight: 600),
                  MyText.titleMedium("Remaining QTY: ${remainingQty % 1 == 0 ? remainingQty.toInt() : remainingQty}", fontWeight: 600),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogDropdownField(
                        "Supplier Name",
                        "Select Supplier",
                        selectedSupplierId,
                        supplierOptions,
                        (val) async {
                          setStateDialog(() {
                            selectedSupplierId = val;
                            machineOptions = getMachineOptions(selectedSupplierId);
                            if (machineOptions.length == 1 && machineOptions.first == 'N/A') {
                              selectedMachine = 'N/A';
                            } else {
                              selectedMachine = null;
                            }
                          });
                          if (val != null) {
                            final nextPo = await supplierService.getNextPoNo(val);
                            if (nextPo.isNotEmpty) {
                              final lastHyphenIndex = nextPo.lastIndexOf('-');
                              if (lastHyphenIndex != -1) {
                                final prefix = nextPo.substring(0, lastHyphenIndex + 1);
                                final seqStr = nextPo.substring(lastHyphenIndex + 1);
                                int currentSeq = int.tryParse(seqStr) ?? 1;

                                int countInSession = _assignedSuppliers.where((s) => 
                                  s['supplierId'] == val && 
                                  s['poNo'].toString().startsWith(prefix)
                                ).length;

                                if (countInSession > 0) {
                                  int nextSeqNum = currentSeq + countInSession;
                                  String nextSeqStr = nextSeqNum.toString().padLeft(3, '0');
                                  poNoController.text = "$prefix$nextSeqStr";
                                } else {
                                  poNoController.text = nextPo;
                                }
                              } else {
                                poNoController.text = nextPo;
                              }
                            }
                          } else {
                            poNoController.clear();
                          }
                        },
                        displayMember: 'name',
                        valueMember: 'id',
                      ),
                      _buildDialogTextField("Supplier PO No", "Enter Supplier PO No", poNoController),
                      _buildDialogDropdownField(
                        "Supplier Machine",
                        "Select Supplier Machine",
                        selectedMachine,
                        machineOptions,
                        (val) {
                          setStateDialog(() {
                            selectedMachine = val;
                          });
                        },
                        key: ValueKey(selectedSupplierId ?? 'machine_empty'),
                      ),
                      _buildDialogTextField("Assigned QTY", "Enter Assigned QTY", qtyController, isNumber: true, validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Assigned QTY is required";
                        }
                        double enteredQty = double.tryParse(val) ?? 0;
                        double remainingQty = _poTotalQty - _totalAssignedQty;
                        if (enteredQty > remainingQty) {
                          return "Cannot exceed remaining QTY ($remainingQty)";
                        }
                        if (enteredQty <= 0) {
                          return "Must be greater than 0";
                        }
                        return null;
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                MyButton.text(
                  onPressed: () => Navigator.pop(context),
                  padding: MySpacing.xy(20, 16),
                  child: MyText.bodyMedium("Cancel"),
                ),
                MyButton.rounded(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (selectedSupplierId == null || selectedSupplierId!.isEmpty) {
                        Utils.showWarningToast(
                          "Please select a Supplier",
                          context: context,
                        );
                        return;
                      }
                      if (selectedMachine == null || selectedMachine!.trim().isEmpty) {
                        Utils.showWarningToast(
                          "Please select a Supplier Machine",
                          context: context,
                        );
                        return;
                      }
                      String machineToSave = selectedMachine!;
                      setState(() {
                        _assignedSuppliers.add({
                          'poNo': poNoController.text,
                          'supplierId': selectedSupplierId,
                          'machine': machineToSave,
                          'qty': qtyController.text,
                        });
                      });
                      Navigator.pop(context);
                      try {
                        await saveAssignedSuppliers();
                        Utils.showSuccessToast(
                          "Assigned Supplier saved successfully!",
                          context: context,
                        );
                      } catch (e) {
                        Utils.showErrorToast(
                          "Failed to save assignment: $e",
                          context: context,
                        );
                      }
                    }
                  },
                  elevation: 0,
                  padding: MySpacing.xy(20, 16),
                  backgroundColor: contentTheme.primary,
                  child: MyText.bodyMedium("Save", color: contentTheme.onPrimary),
                ),
              ],
            );
          }
        );
      },
    );
  }

  String _getSupplierName(String supplierId) {
    if (supplierId.isEmpty) return '';
    var supplier = _suppliers.firstWhere((s) => (s['supplierid']?.toString() ?? s['supplierId']?.toString()) == supplierId, orElse: () => {});
    if (supplier.isEmpty) return supplierId;
    return (supplier['suppliername'] ?? supplier['supplierName'] ?? supplierId).toString();
  }

  Widget _buildAssignedSuppliersTable() {
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
                _buildTableCell(MyText.labelMedium('Action', fontWeight: 600)),
              ],
            ),
            ..._assignedSuppliers.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> supplier = entry.value;
              return TableRow(
                children: [
                  _buildTableCell(MyText.bodyMedium(supplier['poNo']?.toString() ?? '')),
                  _buildTableCell(MyText.bodyMedium(_getSupplierName(supplier['supplierId']?.toString() ?? ''))),
                  _buildTableCell(MyText.bodyMedium(supplier['machine']?.toString() ?? '')),
                  _buildTableCell(MyText.bodyMedium(supplier['qty']?.toString() ?? '')),
                  _buildTableCell(
                    InkWell(
                      onTap: () async {
                        setState(() {
                          _assignedSuppliers.removeAt(index);
                        });
                        try {
                          await saveAssignedSuppliers();
                          Utils.showSuccessToast(
                            "Assignment removed successfully!",
                            context: context,
                          );
                        } catch (e) {
                          Utils.showErrorToast(
                            "Failed to update assignments: $e",
                            context: context,
                          );
                        }
                      },
                      child: Icon(LucideIcons.trash_2, size: 18, color: contentTheme.danger),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
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

  String _getPlanterCode() {
    List<String> parts = [widget.data.planter, widget.data.planterShape, widget.data.planterSize, widget.data.space]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.isNotEmpty ? "P${parts.join('').toUpperCase()}" : "--";
  }

  String _getDrainCode() {
    List<String> parts = [widget.data.drain, widget.data.drainShape, widget.data.drainSize, widget.data.drainPosition]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.isNotEmpty ? "D${parts.join('').toUpperCase()}" : "--";
  }

  Future<void> _showAssignCcSupplierDialog() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController planterCodeController = TextEditingController(text: _getPlanterCode());
    final TextEditingController drainCodeController = TextEditingController(text: _getDrainCode());
    final TextEditingController qtyController = TextEditingController();

    String? selectedSupplierId;

    List<Map<String, String>> supplierOptions = _suppliers.map((s) {
      return {
        'id': (s['supplierid'] ?? s['supplierId'])?.toString() ?? '',
        'name': (s['suppliername'] ?? s['supplierName'] ?? s['supplierid'] ?? s['supplierId'])?.toString() ?? '',
      };
    }).where((s) => s['id']!.isNotEmpty).toList();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            double remainingCcQty = _poCcTotalQty - _totalAssignedCcQty;
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText.titleMedium("Assign CC Supplier", fontWeight: 600),
                  MyText.titleMedium("Remaining CC QTY: ${remainingCcQty % 1 == 0 ? remainingCcQty.toInt() : remainingCcQty}", fontWeight: 600),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDialogDropdownField(
                        "Supplier Name",
                        "Select Supplier",
                        selectedSupplierId,
                        supplierOptions,
                        (val) {
                          setStateDialog(() {
                            selectedSupplierId = val;
                          });
                        },
                        displayMember: 'name',
                        valueMember: 'id',
                      ),
                      _buildDialogTextField("Planter Code", "", planterCodeController, readOnly: true),
                      _buildDialogTextField("Drain Code", "", drainCodeController, readOnly: true),
                      _buildDialogTextField("CC Assigned QTY", "Enter CC Assigned QTY", qtyController, isNumber: true, validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "CC Assigned QTY is required";
                        }
                        double enteredQty = double.tryParse(val) ?? 0;
                        double remainingCcQty = _poCcTotalQty - _totalAssignedCcQty;
                        if (enteredQty > remainingCcQty) {
                          return "Cannot exceed remaining CC QTY (${remainingCcQty % 1 == 0 ? remainingCcQty.toInt() : remainingCcQty})";
                        }
                        if (enteredQty <= 0) {
                          return "Must be greater than 0";
                        }
                        return null;
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                MyButton.text(
                  onPressed: () => Navigator.pop(context),
                  padding: MySpacing.xy(20, 16),
                  child: MyText.bodyMedium("Cancel"),
                ),
                MyButton.rounded(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (selectedSupplierId != null) {
                        setState(() {
                          _assignedCcSuppliers.add({
                            'supplierId': selectedSupplierId,
                            'planterCode': planterCodeController.text,
                            'drainCode': drainCodeController.text,
                            'qty': qtyController.text,
                          });
                        });
                        Navigator.pop(context);
                        try {
                          await saveAssignedSuppliers();
                          Utils.showSuccessToast(
                            "Assigned CC Supplier saved successfully!",
                            context: context,
                          );
                        } catch (e) {
                          Utils.showErrorToast(
                            "Failed to save CC assignment: $e",
                            context: context,
                          );
                        }
                      }
                    }
                  },
                  elevation: 0,
                  padding: MySpacing.xy(20, 16),
                  backgroundColor: contentTheme.primary,
                  child: MyText.bodyMedium("Save", color: contentTheme.onPrimary),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildAssignedCcSuppliersTable() {
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
                _buildTableCell(MyText.labelMedium('Supplier Name', fontWeight: 600)),
                _buildTableCell(MyText.labelMedium('Planter Code', fontWeight: 600)),
                _buildTableCell(MyText.labelMedium('Drain Code', fontWeight: 600)),
                _buildTableCell(MyText.labelMedium('Assigned CC QTY', fontWeight: 600)),
                _buildTableCell(MyText.labelMedium('Action', fontWeight: 600)),
              ],
            ),
            ..._assignedCcSuppliers.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> supplier = entry.value;
              return TableRow(
                children: [
                  _buildTableCell(MyText.bodyMedium(_getSupplierName(supplier['supplierId']?.toString() ?? ''))),
                  _buildTableCell(MyText.bodyMedium(supplier['planterCode']?.toString() ?? '')),
                  _buildTableCell(MyText.bodyMedium(supplier['drainCode']?.toString() ?? '')),
                  _buildTableCell(MyText.bodyMedium(supplier['qty']?.toString() ?? '')),
                  _buildTableCell(
                    InkWell(
                      onTap: () async {
                        setState(() {
                          _assignedCcSuppliers.removeAt(index);
                        });
                        try {
                          await saveAssignedSuppliers();
                          Utils.showSuccessToast(
                            "CC Assignment removed successfully!",
                            context: context,
                          );
                        } catch (e) {
                          Utils.showErrorToast(
                            "Failed to update CC assignments: $e",
                            context: context,
                          );
                        }
                      },
                      child: Icon(LucideIcons.trash_2, size: 18, color: contentTheme.danger),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  double get _totalAssignedQty {
    double total = 0;
    for (var supplier in _assignedSuppliers) {
      total += double.tryParse(supplier['qty']?.toString() ?? '0') ?? 0;
    }
    return total;
  }

  double get _poTotalQty {
    double qty = double.tryParse(widget.data.qty.toString().replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    double excess = double.tryParse(widget.data.excess.toString().replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    return qty + excess;
  }

  double get _totalAssignedCcQty {
    double total = 0;
    for (var supplier in _assignedCcSuppliers) {
      total += double.tryParse(supplier['qty']?.toString() ?? '0') ?? 0;
    }
    return total;
  }

  double get _poCcTotalQty {
    double qty = double.tryParse(widget.data.qty.toString().replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    double ccExcess = double.tryParse(widget.data.ccExcess.toString().replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    return qty + ccExcess;
  }

  @override
  Widget build(BuildContext context) {
    bool canAssignMore = _totalAssignedQty < _poTotalQty;
    bool canAssignMoreCc = _totalAssignedCcQty < _poCcTotalQty;
    bool hasCoverCutting = widget.data.coverCutting.toString().toLowerCase() == 'yes';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            if (canAssignMore)
              MyButton.rounded(
                onPressed: () => _checkAndProceed(_showAssignSupplierDialog),
                elevation: 0,
                padding: MySpacing.xy(20, 16),
                backgroundColor: contentTheme.primary,
                child: MyText.bodyMedium("Assign Supplier", color: contentTheme.onPrimary, fontWeight: 600),
              ),
            if (hasCoverCutting && canAssignMoreCc)
              MyButton.rounded(
                onPressed: () => _checkAndProceed(_showAssignCcSupplierDialog),
                elevation: 0,
                padding: MySpacing.xy(20, 16),
                backgroundColor: contentTheme.primary,
                child: MyText.bodyMedium("Assign CC Supplier", color: contentTheme.onPrimary, fontWeight: 600),
              ),
          ],
        ),
        MySpacing.height(16),
        if (_assignedSuppliers.isNotEmpty) ...[
          MyText.titleMedium("Assigned Suppliers", fontWeight: 600),
          MySpacing.height(8),
          _buildAssignedSuppliersTable(),
          MySpacing.height(16),
        ],
        if (_assignedCcSuppliers.isNotEmpty) ...[
          MyText.titleMedium("Assigned CC Suppliers", fontWeight: 600),
          MySpacing.height(8),
          _buildAssignedCcSuppliersTable(),
        ],
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
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    this.onChanged,
    this.displayMember = 'label',
    this.valueMember = 'value',
    this.isRequired = false,
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
      if (option is String) return option;
      return option[widget.displayMember]?.toString() ?? '';
    }).toList();
  }

  String _getDisplayValue(String? val) {
    if (val == null) {
      return '';
    }
    for (var opt in widget.options) {
      if (opt is String) {
        if (opt == val) return opt;
      } else if (opt[widget.valueMember]?.toString() == val) {
        return opt[widget.displayMember]?.toString() ?? val;
      }
    }
    return val;
  }

  String _getValueFromDisplay(String display) {
    for (var opt in widget.options) {
      if (opt is String) {
        if (opt == display) return opt;
      } else if (opt[widget.displayMember]?.toString() == display) {
        return opt[widget.valueMember]?.toString() ?? display;
      }
    }
    return display;
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