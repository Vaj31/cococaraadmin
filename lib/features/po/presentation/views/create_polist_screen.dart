import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:ccpladmin/services/po_master_service.dart';
import 'package:ccpladmin/services/port_master_service.dart';
import 'package:ccpladmin/services/purchase_order_service.dart';
import 'package:ccpladmin/services/customer_service.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CreatePolistScreen extends StatefulWidget {
  const CreatePolistScreen({super.key});

  @override
  _CreatePolistScreenState createState() => _CreatePolistScreenState();
}

class _CreatePolistScreenState extends State<CreatePolistScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final PoMasterService _poMasterService = PoMasterService();
  final PortMasterService _portMasterService = PortMasterService();
  final PurchaseOrderService _purchaseOrderService = PurchaseOrderService();
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  final TextEditingController _orderIdController = TextEditingController();
  String? _selectedSales;
  List<dynamic> _salesOptions = [];

  String? _selectedCustomer;
  List<dynamic> _customerOptions = [];

  String? _selectedProductGroup;
  List<dynamic> _productGroupOptions = [];
  String? _selectedEC;
  List<dynamic> _ecOptions = [];
  String? _selectedMaterial;
  List<dynamic> _materialOptions = [];
  
  final TextEditingController _dimLController = TextEditingController();
  final TextEditingController _dimDController = TextEditingController();
  final TextEditingController _dimHController = TextEditingController();
  final TextEditingController _itemCodeController = TextEditingController();

  String? _selectedCrop;
  List<dynamic> _cropOptions = [];

  bool _packingBag = false;
  bool _cartonBox = false;
  bool _polyBag = false;
  bool _coverCutting = false;
  bool _requireSlitCut = false;
  bool _newPatnCode = false;

  bool _singleDelivery = true;
  bool _scheduledDelivery = false;

  String? _selectedPlanterHolesNo;
  List<dynamic> _planterHolesNoOptions = [];
  String? _selectedPlanterHoleSize;
  List<dynamic> _planterHoleSizeOptions = [];
  String? _selectedPlanterHoleShape;
  List<dynamic> _planterHoleShapeOptions = [];
  String? _selectedSpace;
  List<dynamic> _spaceOptions = [];
  String? _selectedDrain;
  List<dynamic> _drainOptions = [];
  String? _selectedDrainSize;
  List<dynamic> _drainSizeOptions = [];
  String? _selectedDrainShape;
  List<dynamic> _drainShapeOptions = [];
  String? _selectedDrainPosition;
  List<dynamic> _drainPositionOptions = [];
  String? _selectedLifespan;
  List<dynamic> _lifespanOptions = [];
  String? _selectedSpecialTreatment;
  final List<String> _specialTreatmentOptions = ['None', 'Washed', 'Buffered'];

  final TextEditingController _diagramController = TextEditingController();
  final TextEditingController _patnCodeController = TextEditingController();

  final TextEditingController _deliveryDateController = TextEditingController();
  final TextEditingController _plantingDateController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  String? _selectedPod;
  List<dynamic> _podOptions = [];

  final List<Map<String, dynamic>> _scheduledDeliveries = [];
  final TextEditingController _totalQtyController = TextEditingController(text: "0");

  final TextEditingController _memoIndiaController = TextEditingController();
  final TextEditingController _memoJpnController = TextEditingController();

  Future<void> _pickDiagram() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result != null) {
      setState(() {
        _diagramController.text = result.files.single.name;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dimLController.addListener(_generateItemCode);
    _dimDController.addListener(_generateItemCode);
    _dimHController.addListener(_generateItemCode);
    _loadMasterData();
    _addScheduledDeliveryRow();
  }

  void _generateItemCode() {
    String pg = _selectedProductGroup ?? '';
    String ec = _selectedEC ?? '';
    String mat = _selectedMaterial ?? '';
    String l = _dimLController.text.trim();
    String d = _dimDController.text.trim();
    String h = _dimHController.text.trim();

    List<String> parts = [];
    if (pg.isNotEmpty) parts.add(pg);
    if (ec.isNotEmpty) parts.add(ec);
    if (mat.isNotEmpty) parts.add(mat);

    if (l.isNotEmpty || d.isNotEmpty || h.isNotEmpty) {
      parts.add('${l.isEmpty ? "0" : l}x${d.isEmpty ? "0" : d}x${h.isEmpty ? "0" : h}');
    }

    if (_itemCodeController.text != parts.join('-')) {
      _itemCodeController.text = parts.join('-');
    }
  }

  Future<void> _loadMasterData() async {
    try {
      final data = await _poMasterService.getPoMasterData();
      final portData = await _portMasterService.getPortMasterData();
      final customerData = await CustomerService.getCustomers();
      setState(() {
        _salesOptions = data['sales'] ?? [];
        _customerOptions = customerData;
        _productGroupOptions = data['products'] ?? [];
        _ecOptions = data['ecvalues'] ?? [];
        _materialOptions = data['materials'] ?? [];
        _cropOptions = data['crops'] ?? [];
        _planterHolesNoOptions = data['planterholes'] ?? [];
        _planterHoleSizeOptions = data['planterholesizes'] ?? [];
        _planterHoleShapeOptions = data['planterholeshapes'] ?? [];
        _spaceOptions = data['planterholespaces'] ?? [];
        _drainOptions = data['drains'] ?? [];
        _drainSizeOptions = data['drainsizes'] ?? [];
        _drainShapeOptions = data['drainshape'] ?? [];
        _drainPositionOptions = data['drainpositions'] ?? [];
        _lifespanOptions = data['lifespans'] ?? [];
        _podOptions = portData;
        _isLoadingData = false;
      });
    } catch (e) {
      debugPrint("Error loading master data: $e");
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _calculateTotalQty() {
    int total = 0;
    for (var row in _scheduledDeliveries) {
      total += int.tryParse((row['qty'] as TextEditingController).text) ?? 0;
    }
    if (_totalQtyController.text != total.toString()) {
      _totalQtyController.text = total.toString();
    }
  }

  /*
  bool _isDeliveryBeforePlanting(String delivery, String planting) {
    DateTime? parseDate(String dateStr) {
      try {
        if (dateStr.contains('/')) {
          final parts = dateStr.split('/');
          if (parts.length == 3) {
            return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        } else if (dateStr.contains('-')) {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          }
        }
      } catch (_) {}
      return null;
    }

    final d = parseDate(delivery);
    final p = parseDate(planting);
    if (d != null && p != null) {
      return d.isBefore(p);
    }
    return true;
  }
  */

  void _addScheduledDeliveryRow() {
    var qtyController = TextEditingController();
    qtyController.addListener(_calculateTotalQty);
    setState(() {
      _scheduledDeliveries.add({
        'deliveryDate': TextEditingController(),
        'plantingDate': TextEditingController(),
        'pod': null,
        'qty': qtyController,
      });
    });
  }

  void _removeScheduledDeliveryRow(int index) {
    setState(() {
      var row = _scheduledDeliveries.removeAt(index);
      (row['qty'] as TextEditingController).removeListener(_calculateTotalQty);
      (row['deliveryDate'] as TextEditingController).dispose();
      (row['plantingDate'] as TextEditingController).dispose();
      (row['qty'] as TextEditingController).dispose();
    });
    _calculateTotalQty();
  }

  void _clearDeliveryOptions() {
    setState(() {
      // Clear Single Delivery fields
      _deliveryDateController.clear();
      _plantingDateController.clear();
      _qtyController.clear();
      _selectedPod = null;

      // Clear Scheduled Delivery fields
      for (var row in _scheduledDeliveries) {
        (row['qty'] as TextEditingController).removeListener(_calculateTotalQty);
        (row['deliveryDate'] as TextEditingController).dispose();
        (row['plantingDate'] as TextEditingController).dispose();
        (row['qty'] as TextEditingController).dispose();
      }
      _scheduledDeliveries.clear();
    });
    _addScheduledDeliveryRow();
    _calculateTotalQty();
  }

  Future<void> _confirmAddScheduledDelivery(BuildContext context) async {
    if (_scheduledDeliveries.isNotEmpty) {
      for (var row in _scheduledDeliveries) {
        String dDate = (row['deliveryDate'] as TextEditingController).text.trim();
        String pDate = (row['plantingDate'] as TextEditingController).text.trim();
        String pod = row['pod']?.toString() ?? '';
        String qty = (row['qty'] as TextEditingController).text.trim();

        if (dDate.isEmpty || pDate.isEmpty || pod.isEmpty || qty.isEmpty) {
          Utils.showWarningToast(
            "Please fill all fields in all deliveries before adding a new one.",
            context: context,
          );
          return;
        }
      }

      bool hasDuplicate = false;
      for (int i = 0; i < _scheduledDeliveries.length; i++) {
        for (int j = i + 1; j < _scheduledDeliveries.length; j++) {
          var rowA = _scheduledDeliveries[i];
          var rowB = _scheduledDeliveries[j];
          
          String dDateA = (rowA['deliveryDate'] as TextEditingController).text.trim();
          String pDateA = (rowA['plantingDate'] as TextEditingController).text.trim();
          String podA = rowA['pod']?.toString() ?? '';
          String qtyA = (rowA['qty'] as TextEditingController).text.trim();
          
          String dDateB = (rowB['deliveryDate'] as TextEditingController).text.trim();
          String pDateB = (rowB['plantingDate'] as TextEditingController).text.trim();
          String podB = rowB['pod']?.toString() ?? '';
          String qtyB = (rowB['qty'] as TextEditingController).text.trim();
          
          if (dDateA == dDateB && pDateA == pDateB && podA == podB && qtyA == qtyB) {
            hasDuplicate = true;
            break;
          }
        }
        if (hasDuplicate) break;
      }

      if (hasDuplicate) {
        Utils.showWarningToast(
          "Duplicate delivery details found. Please ensure each delivery is unique.",
          context: context,
        );
        return;
      }
    }

    bool? add = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: MyText.titleMedium("Add Delivery", fontWeight: 600),
          content: MyText.bodyMedium("Want to add new delivery details?"),
          actions: [
            MyButton.text(
              onPressed: () => Navigator.of(context).pop(false),
              child: MyText.bodyMedium("No"),
            ),
            MyButton.rounded(
              onPressed: () => Navigator.of(context).pop(true),
              elevation: 0,
              backgroundColor: contentTheme.primary,
              child: MyText.bodyMedium("Yes", color: contentTheme.onPrimary),
            ),
          ],
        );
      },
    );
    if (add == true) _addScheduledDeliveryRow();
  }

  Future<void> _confirmRemoveScheduledDelivery(BuildContext context, int index) async {
    bool? remove = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: MyText.titleMedium("Delete Delivery", fontWeight: 600),
          content: MyText.bodyMedium("Want to delete this delivery detail?"),
          actions: [
            MyButton.text(
              onPressed: () => Navigator.of(context).pop(false),
              child: MyText.bodyMedium("No"),
            ),
            MyButton.rounded(
              onPressed: () => Navigator.of(context).pop(true),
              elevation: 0,
              backgroundColor: contentTheme.danger,
              child: MyText.bodyMedium("Yes", color: contentTheme.onPrimary),
            ),
          ],
        );
      },
    );
    if (remove == true) _removeScheduledDeliveryRow(index);
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
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _selectScheduledDate(BuildContext context, TextEditingController controller, int index, bool isDelivery) async {
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
      String newDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";

      setState(() {
        controller.text = newDate;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getMissingMasterData() async {
    List<Map<String, dynamic>> missingData = [];

    void checkMissing(String table, String column, String label, String? value, List<dynamic> options) {
      if (value == null || value.trim().isEmpty) {
        return;
      }
      bool exists = options.any((opt) {
        if (opt is String) {
          return opt.toLowerCase() == value.trim().toLowerCase();
        }
        return opt[column]?.toString().toLowerCase() == value.trim().toLowerCase();
      });
      if (!exists) {
        bool alreadyAdded = missingData.any((md) => md['table'] == table && md['value'] == value.trim());
        if (!alreadyAdded) {
          missingData.add({'table': table, 'column': column, 'label': label, 'value': value.trim(), 'options': options});
        }
      }
    }

    checkMissing('sales', 'SalesName', 'Sales', _selectedSales, _salesOptions);
    checkMissing('products', 'Product', 'Product Group', _selectedProductGroup, _productGroupOptions);
    checkMissing('ecvalues', 'EC', 'EC', _selectedEC, _ecOptions);
    checkMissing('materials', 'Material', 'Material', _selectedMaterial, _materialOptions);
    checkMissing('crops', 'CROP', 'Crop', _selectedCrop, _cropOptions);
    checkMissing('planterholes', 'PLANTERHOLES', 'Planter Holes No', _selectedPlanterHolesNo, _planterHolesNoOptions);
    checkMissing('planterholesizes', 'PLANTERHOLESIZE', 'Planter Hole Size', _selectedPlanterHoleSize, _planterHoleSizeOptions);
    checkMissing('planterholeshapes', 'PlanterHoleShape', 'Planter Hole Shape', _selectedPlanterHoleShape, _planterHoleShapeOptions);
    checkMissing('planterholespaces', 'PlanterHoleSpace', 'Space', _selectedSpace, _spaceOptions);
    checkMissing('drains', 'Drain', 'Drain', _selectedDrain, _drainOptions);
    checkMissing('drainsizes', 'DrainSize', 'Drain Size', _selectedDrainSize, _drainSizeOptions);
    checkMissing('drainshape', 'drainshape', 'Drain Shape', _selectedDrainShape, _drainShapeOptions);
    checkMissing('drainpositions', 'DrainPosition', 'Drain Position', _selectedDrainPosition, _drainPositionOptions);
    checkMissing('lifespans', 'Lifespan', 'Lifespan', _selectedLifespan, _lifespanOptions);

    void checkMissingPod(String? value, List<dynamic> options) {
      if (value == null || value.trim().isEmpty) {
        return;
      }
      bool exists = options.any((opt) {
        if (opt is String) {
          return opt.toLowerCase() == value.trim().toLowerCase();
        }
        return opt['portshortname']?.toString().toLowerCase() == value.trim().toLowerCase();
      });
      if (!exists) {
        bool alreadyAdded = missingData.any((md) => md['table'] == 'port' && md['value'] == value.trim());
        if (!alreadyAdded) {
          missingData.add({'table': 'port', 'column': 'portshortname', 'label': 'POD', 'value': value.trim(), 'options': options});
        }
      }
    }

    if (_singleDelivery) {
      checkMissingPod(_selectedPod, _podOptions);
    } else {
      for (var delivery in _scheduledDeliveries) {
        checkMissingPod(delivery['pod']?.toString(), _podOptions);
      }
    }

    return missingData;
  }

  Future<bool> _showAddMasterDataPopup(List<Map<String, dynamic>> missingData) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: MyText.titleMedium("Add New Master Data", fontWeight: 600),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium("The following values are not in the master table. Do you want to add them?"),
                  MySpacing.height(16),
                  ...missingData.map((data) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.circle_plus, size: 16, color: contentTheme.primary),
                        MySpacing.width(8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: MyTextStyle.bodyMedium(color: contentTheme.onBackground),
                              children: [
                                TextSpan(text: "${data['label']}: ", style: const TextStyle(fontWeight: FontWeight.w600)),
                                TextSpan(text: data['value']),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          actions: [
            MyButton.text(
              onPressed: () => Navigator.of(context).pop(false),
              child: MyText.bodyMedium("Cancel"),
            ),
            MyButton.rounded(
              onPressed: () => Navigator.of(context).pop(true),
              elevation: 0,
              backgroundColor: contentTheme.primary,
              child: MyText.bodyMedium("Add & Continue", color: contentTheme.onPrimary),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _checkAndSubmitOrder() async {
    setState(() => _isSubmitting = true);

    String currentItemCode = _itemCodeController.text.trim();

    if (currentItemCode.isEmpty) {
      if (mounted) {
        Utils.showErrorToast("Item Code is missing.", context: context);
      }
      setState(() => _isSubmitting = false);
      return;
    }

    final missingData = await _getMissingMasterData();
    if (missingData.isNotEmpty) {
      setState(() => _isSubmitting = false);
      bool shouldAdd = await _showAddMasterDataPopup(missingData);
      if (!shouldAdd) {
        return;
      }
      setState(() => _isSubmitting = true);

      for (var data in missingData) {
        if (data['table'] == 'port') {
          try {
            await _portMasterService.addPortMasterData(data['value']);
            setState(() {
              (data['options'] as List).add({'portshortname': data['value']});
            });
          } catch (e) {
            debugPrint("Failed to add new POD data: $e");
          }
        } else {
          try {
            await _poMasterService.addMasterData(data['table'], data['column'], data['value']);
            setState(() {
              (data['options'] as List).add({data['column']: data['value']});
            });
          } catch (e) {
            debugPrint("Failed to add new master data for ${data['table']}: $e");
          }
        }
      }
    }

    await _submitOrder();
  }

  Future<void> _submitOrder() async {
    setState(() {
      _isSubmitting = true;
    });

    final Map<String, dynamic> basePayload = {
      "sales": _selectedSales,
      "customer": _selectedCustomer,
      "product": _selectedProductGroup,
      "ec": _selectedEC,
      "material": _selectedMaterial,
      "crop": _selectedCrop,
      "packingBag": _packingBag ? "Yes" : "No",
      "cartonBox": _cartonBox ? "Yes" : "No",
      "polyBag": _polyBag ? "Yes" : "No",
      "coverCutting": _coverCutting ? "Yes" : "No",
      "requireSlitCut": _requireSlitCut ? "Yes" : "No",
      "l": _dimLController.text,
      "d": _dimDController.text,
      "h": _dimHController.text,
      "itemCode": _itemCodeController.text,
      "planter": _selectedPlanterHolesNo,
      "planterSize": _selectedPlanterHoleSize,
      "planterShape": _selectedPlanterHoleShape,
      "space": _selectedSpace,
      "drain": _selectedDrain,
      "drainSize": _selectedDrainSize,
      "drainShape": _selectedDrainShape,
      "drainPosition": _selectedDrainPosition,
      "lifespan": _selectedLifespan,
      "specialTreatment": _selectedSpecialTreatment,
      "diagram": _diagramController.text,
      "patnCode": _patnCodeController.text,
      "newPatn": _newPatnCode ? "Yes" : "No",
      "memo": _memoIndiaController.text,
      "memoJP": _memoJpnController.text,
      "orderStatus": "Pending",
      "orderDate": "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
    };

    List<Map<String, dynamic>> payloads = [];

    if (_singleDelivery) {
      payloads.add({
        ...basePayload,
        "orderId": _orderIdController.text,
        "deliveryLT": _deliveryDateController.text,
        "planting": _plantingDateController.text,
        "qty": _qtyController.text,
        "pod": _selectedPod,
      });
    } else {
      for (int i = 0; i < _scheduledDeliveries.length; i++) {
        var delivery = _scheduledDeliveries[i];
        String dDate = (delivery['deliveryDate'] as TextEditingController).text.trim();
        String pDate = (delivery['plantingDate'] as TextEditingController).text.trim();
        String qty = (delivery['qty'] as TextEditingController).text.trim();
        var pod = delivery['pod'];

        if (dDate.isEmpty && pDate.isEmpty && qty.isEmpty && pod == null) {
          continue;
        }

        payloads.add({
          ...basePayload,
          "orderId": _scheduledDeliveries.length > 1 ? "${_orderIdController.text}-${i + 1}" : _orderIdController.text,
          "deliveryLT": dDate,
          "planting": pDate,
          "qty": qty,
          "pod": pod,
        });
      }
    }

    if (payloads.isEmpty) {
      if (mounted) {
        Utils.showErrorToast("Please fill in delivery details.", context: context);
      }
      setState(() => _isSubmitting = false);
      return;
    }

    bool allSuccess = true;
    String errorMessage = '';

    for (var payload in payloads) {
      try {
        final response = await _purchaseOrderService.createPurchaseOrder(payload);
        if (response.statusCode != 200 && response.statusCode != 201) {
          allSuccess = false;
          errorMessage = "For Order ID ${payload['orderId']}: ${response.body}";
          break;
        }
      } catch (e) {
        allSuccess = false;
        errorMessage = e.toString();
        break;
      }
    }

    if (mounted) {
      if (allSuccess) {
        Navigator.pop(context);
      } else {
        Utils.showErrorToast("Failed to save Purchase Order: $errorMessage", context: context);
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        children: [
          
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, 
              children: [
                MyText.titleMedium(
                  "Create Order",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(
                        name: 'Purchase Order', route: '/purchase_order'),
                    MyBreadcrumbItem(name: 'New', active: true),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing),

          
          Padding(
            padding: MySpacing.x(flexSpacing / 2),
            child: MyFlex(
              children: [
                MyFlexItem(sizes: 'lg-12 md-12', child: _buildFormCard())
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    if (_isLoadingData) {
      return MyCard(
        borderRadiusAll: 8,
        shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
        paddingAll: 23,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return MyCard(
      borderRadiusAll: 8,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 23,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.file_plus, size: 20, color: contentTheme.primary),
              MySpacing.width(12),
              MyText.titleMedium("Purchase Order Details", fontWeight: 600),
            ],
          ),
          Divider(height: 40, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
          Form(
            key: _formKey,
            child: MyFlex(
              contentPadding: false,
              children: [
                MyFlexItem(
                  sizes: 'lg-3 md-6 sm-12',
                  child: _buildTextField(
                      "Order ID", "Enter Order ID", _orderIdController),
                ),
                MyFlexItem(
                  sizes: 'lg-3 md-6 sm-12',
                  child: _buildDropdownField(
                    "Sales", 
                    "Select Sales",
                    value: _selectedSales,
                    options: _salesOptions,
                    displayMember: 'SalesName',
                    valueMember: 'SalesName',
                    onChanged: (val) {
                      setState(() {
                        _selectedSales = val;
                      });
                    },
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-3 md-6 sm-12',
                  child: _buildDropdownField(
                    "Customer", 
                    "Select Customer",
                    value: _selectedCustomer,
                    options: _customerOptions,
                    displayMember: 'customername',
                    valueMember: 'customername',
                    onChanged: (val) {
                      setState(() {
                        _selectedCustomer = val;
                      });
                    },
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-12',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.titleMedium("Product Details", fontWeight: 600),
                      Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-2 md-6 sm-12',
                  child: _buildDropdownField("Product Group", "Select Product",
                      value: _selectedProductGroup,
                      options: _productGroupOptions,
                      displayMember: 'Product',
                      valueMember: 'Product',
                      onChanged: (val) {
                        setState(() => _selectedProductGroup = val);
                        _generateItemCode();
                      }),
                ),
                MyFlexItem(
                  sizes: 'lg-2 md-6 sm-12',
                  child: _buildDropdownField("EC", "Select EC",
                      value: _selectedEC,
                      options: _ecOptions,
                      displayMember: 'EC',
                      valueMember: 'EC',
                      onChanged: (val) {
                        setState(() => _selectedEC = val);
                        _generateItemCode();
                      }),
                ),
                MyFlexItem(
                  sizes: 'lg-2 md-6 sm-12',
                  child: _buildDropdownField("Material", "Select Material",
                      value: _selectedMaterial,
                      options: _materialOptions,
                      displayMember: 'Material',
                      valueMember: 'Material',
                      onChanged: (val) {
                        setState(() => _selectedMaterial = val);
                        _generateItemCode();
                      }),
                ),
                MyFlexItem(
                  sizes: 'lg-3 md-6 sm-12',
                  child: _buildDropdownField("Special Treatment", "Select Treatment",
                      value: _selectedSpecialTreatment,
                      options: _specialTreatmentOptions,
                      onChanged: (val) => setState(() => _selectedSpecialTreatment = val)),
                ),
                MyFlexItem(
                  sizes: 'lg-3 md-6 sm-12',
                  child: _buildDropdownField("Crop", "Select Crop",
                      value: _selectedCrop,
                      options: _cropOptions,
                      displayMember: 'CROP',
                      valueMember: 'CROP',
                      onChanged: (val) => setState(() => _selectedCrop = val)),
                ),
                MyFlexItem(
                  sizes: 'lg-3 md-6 sm-12',
                  child: Row(
                    children: [
                      Expanded(child: _buildTextField("L", "L", _dimLController, isNumber: true, maxLength: 3)),
                      MySpacing.width(8),
                      Expanded(child: _buildTextField("D", "D", _dimDController, isNumber: true, maxLength: 3)),
                      MySpacing.width(8),
                      Expanded(child: _buildTextField("H", "H", _dimHController, isNumber: true, maxLength: 3)),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-3 md-6 sm-12',
                  child: _buildTextField("Item Code", "Item Code", _itemCodeController, readOnly: true),
                ),
                MyFlexItem(
                  sizes: 'lg-3 md-6 sm-12',
                  child: _buildDropdownField("Lifespan", "Select Lifespan",
                      value: _selectedLifespan,
                      options: _lifespanOptions,
                      displayMember: 'Lifespan',
                      valueMember: 'Lifespan',
                      onChanged: (val) => setState(() => _selectedLifespan = val)),
                ),
                MyFlexItem(
                  sizes: 'lg-12 md-12 sm-12',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.labelMedium("Poly Bag", fontWeight: 600),
                            MySpacing.height(18),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _polyBag = !_polyBag;
                                  if (!_polyBag) {
                                    _coverCutting = false;
                                  }
                                });
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: _polyBag ? contentTheme.primary : Colors.transparent,
                                      border: Border.all(
                                        color: _polyBag ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _polyBag
                                        ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary)
                                        : null,
                                  ),
                                  MySpacing.width(8),
                                  MyText.bodyMedium(_polyBag ? "Yes" : "No", fontWeight: 600),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_polyBag)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText.labelMedium("Cover Cutting", fontWeight: 600),
                              MySpacing.height(18),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _coverCutting = !_coverCutting;
                                  });
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: _coverCutting ? contentTheme.primary : Colors.transparent,
                                        border: Border.all(
                                          color: _coverCutting ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: _coverCutting
                                          ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary)
                                          : null,
                                    ),
                                    MySpacing.width(8),
                                    MyText.bodyMedium(_coverCutting ? "Yes" : "No", fontWeight: 600),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.labelMedium("Packing Bag", fontWeight: 600),
                            MySpacing.height(18),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _packingBag = !_packingBag;
                                });
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: _packingBag ? contentTheme.primary : Colors.transparent,
                                      border: Border.all(
                                        color: _packingBag ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _packingBag
                                        ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary)
                                        : null,
                                  ),
                                  MySpacing.width(8),
                                  MyText.bodyMedium(_packingBag ? "Yes" : "No", fontWeight: 600),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.labelMedium("Carton Box", fontWeight: 600),
                            MySpacing.height(18),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _cartonBox = !_cartonBox;
                                });
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: _cartonBox ? contentTheme.primary : Colors.transparent,
                                      border: Border.all(
                                        color: _cartonBox ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: _cartonBox
                                        ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary)
                                        : null,
                                  ),
                                  MySpacing.width(8),
                                  MyText.bodyMedium(_cartonBox ? "Yes" : "No", fontWeight: 600),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_coverCutting) ...[
                  MyFlexItem(
                    sizes: 'lg-12',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MySpacing.height(16),
                        MyText.titleMedium("Cover Cutting Details", fontWeight: 600),
                        Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
                      ],
                    ),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildDropdownField("Planter Holes No", "Select No",
                        value: _selectedPlanterHolesNo,
                        options: _planterHolesNoOptions,
                        displayMember: 'PLANTERHOLES',
                        valueMember: 'PLANTERHOLES',
                        onChanged: (val) => setState(() => _selectedPlanterHolesNo = val)),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildDropdownField("Planter Hole Size", "Select Size",
                        value: _selectedPlanterHoleSize,
                        options: _planterHoleSizeOptions,
                        displayMember: 'PLANTERHOLESIZE',
                        valueMember: 'PLANTERHOLESIZE',
                        onChanged: (val) => setState(() => _selectedPlanterHoleSize = val)),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildDropdownField("Planter Hole Shape", "Select Shape",
                        value: _selectedPlanterHoleShape,
                        options: _planterHoleShapeOptions,
                        displayMember: 'PlanterHoleShape',
                        valueMember: 'PlanterHoleShape',
                        onChanged: (val) => setState(() => _selectedPlanterHoleShape = val)),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildDropdownField("Space", "Select Space",
                        value: _selectedSpace,
                        options: _spaceOptions,
                        displayMember: 'PlanterHoleSpace',
                        valueMember: 'PlanterHoleSpace',
                        onChanged: (val) => setState(() => _selectedSpace = val)),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildDropdownField("Drain", "Select Drain",
                        value: _selectedDrain,
                        options: _drainOptions,
                        displayMember: 'Drain',
                        valueMember: 'Drain',
                        onChanged: (val) => setState(() => _selectedDrain = val)),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildDropdownField("Drain Size", "Select Drain Size",
                        value: _selectedDrainSize,
                        options: _drainSizeOptions,
                        displayMember: 'DrainSize',
                        valueMember: 'DrainSize',
                        onChanged: (val) => setState(() => _selectedDrainSize = val)),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildDropdownField("Drain Shape", "Select Drain Shape",
                        value: _selectedDrainShape,
                        options: _drainShapeOptions,
                        displayMember: 'drainshape',
                        valueMember: 'drainshape',
                        onChanged: (val) => setState(() => _selectedDrainShape = val)),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildDropdownField("Drain Position", "Select Position",
                        value: _selectedDrainPosition,
                        options: _drainPositionOptions,
                        displayMember: 'DrainPosition',
                        valueMember: 'DrainPosition',
                        onChanged: (val) => setState(() => _selectedDrainPosition = val)),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.labelMedium("Require Slit Cut", fontWeight: 600),
                        MySpacing.height(18),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _requireSlitCut = !_requireSlitCut;
                            });
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: _requireSlitCut ? contentTheme.primary : Colors.transparent,
                                  border: Border.all(
                                    color: _requireSlitCut ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: _requireSlitCut
                                    ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary)
                                    : null,
                              ),
                              MySpacing.width(8),
                              MyText.bodyMedium(_requireSlitCut ? "Yes" : "No", fontWeight: 600),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildTextField(
                      "Diagram",
                      "Upload Diagram",
                      _diagramController,
                      readOnly: true,
                      onTap: _pickDiagram,
              suffixIcon: Icon(LucideIcons.cloud_upload, size: 18, color: contentTheme.primary),
                      isRequired: false,
                    ),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildTextField("Patn Code", "Enter Patn Code", _patnCodeController),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.labelMedium("New Patn Code", fontWeight: 600),
                        MySpacing.height(18),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _newPatnCode = !_newPatnCode;
                            });
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Row(
                            children: [
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: _newPatnCode ? contentTheme.primary : Colors.transparent,
                                  border: Border.all(
                                    color: _newPatnCode ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: _newPatnCode
                                    ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary)
                                    : null,
                              ),
                              MySpacing.width(8),
                              MyText.bodyMedium(_newPatnCode ? "Yes" : "No", fontWeight: 600),
                            ],
                          ),
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
                      MyText.titleMedium("Delivery Options", fontWeight: 600),
                      Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-12',
                  child: Row(
                    children: [
                      _buildCustomRadio("Single Delivery", _singleDelivery, () {
                        setState(() {
                          _singleDelivery = true;
                          _scheduledDelivery = false;
                        });
                      }),
                      MySpacing.width(32),
                      _buildCustomRadio("Scheduled Delivery", _scheduledDelivery, () {
                        setState(() {
                          _scheduledDelivery = true;
                          _singleDelivery = false;
                        });
                      }),
                    ],
                  ),
                ),
                if (_singleDelivery) ...[
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildTextField("Delivery Date", "Select Delivery Date", _deliveryDateController,
                      isDate: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Delivery Date is required';
                        /*
                        if (_plantingDateController.text.isNotEmpty) {
                          if (!_isDeliveryBeforePlanting(value, _plantingDateController.text)) {
                            return 'Must be before Planting Date';
                          }
                        }
                        */
                        return null;
                      },
                      suffixIcon: InkWell(
                        onTap: () => _selectDate(context, _deliveryDateController),
                        child: Icon(LucideIcons.calendar, size: 18, color: contentTheme.primary),
                      ),
                    ),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildTextField("Planting Date", "Select Planting Date", _plantingDateController,
                      isDate: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Planting Date is required';
                        /*
                        if (_deliveryDateController.text.isNotEmpty) {
                          if (!_isDeliveryBeforePlanting(_deliveryDateController.text, value)) {
                            return 'Must be after Delivery Date';
                          }
                        }
                        */
                        return null;
                      },
                      suffixIcon: InkWell(
                        onTap: () => _selectDate(context, _plantingDateController),
                        child: Icon(LucideIcons.calendar, size: 18, color: contentTheme.primary),
                      ),
                    ),
                  ),
                  MyFlexItem(
                    sizes: 'lg-2 md-4 sm-12',
                    child: _buildDropdownField("POD", "Select POD",
                        value: _selectedPod,
                        options: _podOptions,
                        displayMember: 'portshortname',
                        valueMember: 'portshortname',
                        onChanged: (val) => setState(() => _selectedPod = val)),
                  ),
                  MyFlexItem(
                    sizes: 'lg-2 md-4 sm-12',
                    child: _buildTextField("QTY", "Enter QTY", _qtyController, isNumber: true),
                  ),
                  MyFlexItem(
                    sizes: 'lg-2 md-4 sm-12',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.labelMedium("Action", fontWeight: 600, color: Colors.transparent),
                        MySpacing.height(8),
                        TextButton.icon(
                          onPressed: _clearDeliveryOptions,
                    icon: Icon(LucideIcons.refresh_cw, size: 16, color: contentTheme.danger),
                          label: MyText.labelMedium("Clear Options", color: contentTheme.danger, fontWeight: 600),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_scheduledDelivery) ...[
                  for (int i = 0; i < _scheduledDeliveries.length; i++) ...[
                    MyFlexItem(
                      sizes: 'lg-3 md-6 sm-12',
                      child: _buildTextField("Delivery Date", "Select Delivery Date", _scheduledDeliveries[i]['deliveryDate'] as TextEditingController,
                          readOnly: i != _scheduledDeliveries.length - 1,
                          isDate: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Delivery Date is required';
                            /*
                            final plantingCtrl = _scheduledDeliveries[i]['plantingDate'] as TextEditingController;
                            if (plantingCtrl.text.isNotEmpty) {
                              if (!_isDeliveryBeforePlanting(value, plantingCtrl.text)) {
                                return 'Must be before Planting Date';
                              }
                            }
                            */
                            return null;
                          },
                          suffixIcon: i == _scheduledDeliveries.length - 1
                              ? InkWell(
                                  onTap: () => _selectScheduledDate(context, _scheduledDeliveries[i]['deliveryDate'] as TextEditingController, i, true),
                                  child: Icon(LucideIcons.calendar, size: 18, color: contentTheme.primary),
                                )
                              : Icon(LucideIcons.calendar, size: 18, color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
                      ),
                    ),
                    MyFlexItem(
                      sizes: 'lg-3 md-6 sm-12',
                      child: _buildTextField("Planting Date", "Select Planting Date", _scheduledDeliveries[i]['plantingDate'] as TextEditingController,
                          readOnly: i != _scheduledDeliveries.length - 1,
                          isDate: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Planting Date is required';
                            /*
                            final deliveryCtrl = _scheduledDeliveries[i]['deliveryDate'] as TextEditingController;
                            if (deliveryCtrl.text.isNotEmpty) {
                              if (!_isDeliveryBeforePlanting(deliveryCtrl.text, value)) {
                                return 'Must be after Delivery Date';
                              }
                            }
                            */
                            return null;
                          },
                          suffixIcon: i == _scheduledDeliveries.length - 1
                              ? InkWell(
                                  onTap: () => _selectScheduledDate(context, _scheduledDeliveries[i]['plantingDate'] as TextEditingController, i, false),
                                  child: Icon(LucideIcons.calendar, size: 18, color: contentTheme.primary),
                                )
                              : Icon(LucideIcons.calendar, size: 18, color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
                      ),
                    ),
                    MyFlexItem(
                      sizes: 'lg-2 md-4 sm-12',
                      child: _buildDropdownField("POD", "Select POD",
                          value: _scheduledDeliveries[i]['pod'],
                          options: _podOptions,
                          displayMember: 'portshortname',
                          valueMember: 'portshortname',
                          onChanged: i == _scheduledDeliveries.length - 1 
                              ? (val) => setState(() => _scheduledDeliveries[i]['pod'] = val)
                              : null),
                    ),
                    MyFlexItem(
                      sizes: 'lg-2 md-4 sm-12',
                      child: _buildTextField("QTY", "Enter QTY", _scheduledDeliveries[i]['qty'] as TextEditingController, 
                          isNumber: true,
                          readOnly: i != _scheduledDeliveries.length - 1),
                    ),
                    MyFlexItem(
                      sizes: 'lg-2 md-4 sm-12',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.labelMedium("Action", fontWeight: 600, color: Colors.transparent),
                          MySpacing.height(8),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              if (i == _scheduledDeliveries.length - 1)
                                InkWell(
                                  onTap: () => _confirmAddScheduledDelivery(context),
                                  child: Container(
                                    padding: MySpacing.all(16),
                                    decoration: BoxDecoration(
                                      color: contentTheme.primary.withValues(alpha: 20 / 255),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(LucideIcons.plus, size: 20, color: contentTheme.primary),
                                  ),
                                ),
                              if (_scheduledDeliveries.length > 1)
                                InkWell(
                                  onTap: () => _confirmRemoveScheduledDelivery(context, i),
                                  child: Container(
                                    padding: MySpacing.all(16),
                                    decoration: BoxDecoration(
                                      color: contentTheme.danger.withValues(alpha: 20 / 255),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                              child: Icon(LucideIcons.trash_2, size: 20, color: contentTheme.danger),
                                  ),
                                ),
                              if (i == _scheduledDeliveries.length - 1)
                                TextButton.icon(
                                  onPressed: _clearDeliveryOptions,
                            icon: Icon(LucideIcons.refresh_cw, size: 16, color: contentTheme.danger),
                                  label: MyText.labelMedium("Clear Options", color: contentTheme.danger, fontWeight: 600),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  MyFlexItem(
                    sizes: 'lg-12',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 200,
                          child: _buildTextField("Total Order QTY", "0", _totalQtyController, readOnly: true),
                        ),
                      ],
                    ),
                  ),
                ],
                MyFlexItem(
              sizes: 'lg-6 md-6 sm-12',
              child: _buildTextField("Memo(India)", "Enter Memo", _memoIndiaController, maxLines: 3, isRequired: false),
                ),
                MyFlexItem(
              sizes: 'lg-6 md-6 sm-12',
              child: _buildTextField("Memo(Jpn)", "Enter Memo", _memoJpnController, maxLines: 3, isRequired: false, textInputAction: TextInputAction.done, onFieldSubmitted: (_) {
                if (_formKey.currentState!.validate()) {
                  _checkAndSubmitOrder();
                }
              }),
                ),
                MyFlexItem(sizes: 'lg-12', child: MySpacing.height(24)),
                MyFlexItem(
                  sizes: 'lg-12',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyButton.text(
                        onPressed: () => Navigator.pop(context),
                        child: MyText.labelMedium("Cancel",
                            color: contentTheme.onBackground),
                      ),
                      MySpacing.width(16),
                      MyButton.rounded(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _checkAndSubmitOrder();
                                }
                              },
                        elevation: 0,
                        padding: MySpacing.xy(24, 16),
                        backgroundColor: contentTheme.primary,
                        child: _isSubmitting
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(color: contentTheme.onPrimary, strokeWidth: 2),
                              )
                            : MyText.labelMedium("Create Order", color: contentTheme.onPrimary, fontWeight: 600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
            if (isDate) DateInputFormatter(),
          ],
          validator: validator ?? (isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) return '$label is required';
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

  Widget _buildCustomRadio(String label, bool value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: value ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                width: 1.5,
              ),
            ),
            child: value
                ? Center(
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: contentTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          MySpacing.width(8),
          MyText.bodyMedium(label, fontWeight: 600),
        ],
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
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