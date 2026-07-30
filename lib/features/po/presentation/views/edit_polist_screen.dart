import 'package:ccpladmin/services/po_master_service.dart';
import 'package:ccpladmin/services/port_master_service.dart';
import 'package:ccpladmin/services/purchase_order_service.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

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
import 'package:ccpladmin/model/polist_model.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ccpladmin/features/po/presentation/providers/po_providers.dart';

class EditPolistScreen extends ConsumerStatefulWidget {
  final PolistModel data;

  const EditPolistScreen({super.key, required this.data});

  @override
  ConsumerState<EditPolistScreen> createState() => _EditPolistScreenState();
}

class _EditPolistScreenState extends ConsumerState<EditPolistScreen>
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
  bool _newPatnCode = false;

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

  final TextEditingController _memoIndiaController = TextEditingController();
  final TextEditingController _memoJpnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dimLController.addListener(_generateItemCode);
    _dimDController.addListener(_generateItemCode);
    _dimHController.addListener(_generateItemCode);
    _loadAndPopulateData();
  }

  Future<void> _loadAndPopulateData() async {
    await _loadMasterData();
    await _fetchAndPopulateOrderDetails();
    setState(() {
      _isLoadingData = false;
    });
  }

  Future<void> _loadMasterData() async {
    try {
      final data = await _poMasterService.getPoMasterData();
      final portData = await _portMasterService.getPortMasterData();
      setState(() {
        _salesOptions = data['sales'] ?? [];
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
        _drainPositionOptions = data['drainpositions'] ?? [];
        _lifespanOptions = data['lifespans'] ?? [];
        _podOptions = portData;
      });
    } catch (e) {
      debugPrint("Error loading master data: $e");
    }
  }

  Future<void> _fetchAndPopulateOrderDetails() async {
    try {
      final orderDetails = await _purchaseOrderService.getPurchaseOrder(widget.data.orderId);
      if (orderDetails != null) {
        final orderData = orderDetails is List ? orderDetails.first : orderDetails;
        
        String val(String key) => orderData[key]?.toString() ?? '';

        setState(() {
          _orderIdController.text = val('orderId');
          _selectedSales = val('sales');
          _selectedProductGroup = val('product');
          _selectedEC = val('ec');
          _selectedMaterial = val('material');
          _dimLController.text = val('l');
          _dimDController.text = val('d');
          _dimHController.text = val('h');
          _itemCodeController.text = val('itemCode');
          _selectedCrop = val('crop');

          _selectedPlanterHolesNo = val('planter');
          _selectedPlanterHoleSize = val('planterSize');
          _selectedPlanterHoleShape = val('planterShape');
          _selectedSpace = val('space');
          _selectedDrain = val('drain');
          _selectedDrainSize = val('drainSize');
          _selectedDrainPosition = val('drainPosition');
          _selectedLifespan = val('lifespan');
          _selectedSpecialTreatment = val('specialTreatment');
          _packingBag = val('packingBag').toLowerCase() == 'yes';
          _cartonBox = val('cartonBox').toLowerCase() == 'yes';
          _polyBag = val('polyBag').toLowerCase() == 'yes';
          _diagramController.text = val('diagram');
          _patnCodeController.text = val('patnCode');
          _newPatnCode = val('newPatn').toLowerCase() == 'yes';

          if (val('planter').isNotEmpty || val('planterSize').isNotEmpty || val('diagram').isNotEmpty) {
            _coverCutting = true;
          }

          _deliveryDateController.text = val('deliveryLT');
          _plantingDateController.text = val('planting');
          _selectedPod = val('pod');
          _qtyController.text = val('qty');

          _memoIndiaController.text = val('memo');
          _memoJpnController.text = val('memoJP');

        });
      }
    } catch (e) {
      debugPrint('Failed to load full order details for editing: $e');
      if (mounted) {
        Utils.showErrorToast("Failed to load order details: $e", context: context);
      }
    }
  }

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

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      Utils.showWarningToast(
        "Please fill all required fields",
        context: context,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final Map<String, dynamic> payload = {
      "orderId": _orderIdController.text,
      "sales": _selectedSales,
      "product": _selectedProductGroup,
      "ec": _selectedEC,
      "material": _selectedMaterial,
      "crop": _selectedCrop,
      "packingBag": _packingBag ? "Yes" : "No",
      "cartonBox": _cartonBox ? "Yes" : "No",
      "polyBag": _polyBag ? "Yes" : "No",
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
      "drainPosition": _selectedDrainPosition,
      "lifespan": _selectedLifespan,
      "specialTreatment": _selectedSpecialTreatment,
      "diagram": _diagramController.text,
      "patnCode": _patnCodeController.text,
      "newPatn": _newPatnCode ? "Yes" : "No",
      "memo": _memoIndiaController.text,
      "memoJP": _memoJpnController.text,
      "deliveryLT": _deliveryDateController.text,
      "planting": _plantingDateController.text,
      "qty": _qtyController.text,
      "pod": _selectedPod,
    };

    try {
      final response = await _purchaseOrderService.updatePurchaseOrder(widget.data.orderId, payload);
      if (response.statusCode == 200) {
        ref.read(polistProvider.notifier).fetchPolist();
        Navigator.pop(context);
        Utils.showSuccessToast(
          "Order updated successfully!",
          context: context,
        );
      } else {
        Utils.showErrorToast(
          "Update failed: ${response.body}",
          context: context,
        );
      }
    } catch (e) {
      Utils.showErrorToast(
        "An error occurred: $e",
        context: context,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _orderIdController.dispose();
    _dimLController.removeListener(_generateItemCode); _dimLController.dispose();
    _dimDController.removeListener(_generateItemCode); _dimDController.dispose();
    _dimHController.removeListener(_generateItemCode); _dimHController.dispose();
    _itemCodeController.dispose();
    _diagramController.dispose();
    _patnCodeController.dispose();
    _deliveryDateController.dispose();
    _plantingDateController.dispose();
    _qtyController.dispose();
    _memoIndiaController.dispose();
    _memoJpnController.dispose();
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
                  "Edit Order",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Purchase Order', route: '/purchase_order'),
                    MyBreadcrumbItem(name: 'Edit', active: true),
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
      return Center(child: CircularProgressIndicator());
    }
    // The form structure is copied from create_polist_screen.dart and adapted for editing.
    // This is a very long widget tree, so it's not fully expanded here for brevity.
    // The key is that it uses the same _buildTextField and _buildDropdownField helpers.
    return MyCard(
        borderRadiusAll: 8,
        shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
        paddingAll: 23,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyFlex(
                contentPadding: false,
                children: [
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildTextField(
                        "Order ID", "Order ID", _orderIdController, readOnly: true),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildDropdownField("Sales", "Select Sales",
                        value: _selectedSales,
                        options: _salesOptions,
                        displayMember: 'SalesName',
                        valueMember: 'SalesName',
                        onChanged: (val) => setState(() => _selectedSales = val)),
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
                                    if (!_polyBag) _coverCutting = false;
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
                                      child: _polyBag ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary) : null,
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
                                  onTap: () => setState(() => _coverCutting = !_coverCutting),
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
                                        child: _coverCutting ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary) : null,
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
                                onTap: () => setState(() => _packingBag = !_packingBag),
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
                                      child: _packingBag ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary) : null,
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
                                onTap: () => setState(() => _cartonBox = !_cartonBox),
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
                                      child: _cartonBox ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary) : null,
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
                    MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildDropdownField("Planter Holes No", "Select No", value: _selectedPlanterHolesNo, options: _planterHolesNoOptions, displayMember: 'PLANTERHOLES', valueMember: 'PLANTERHOLES', onChanged: (val) => setState(() => _selectedPlanterHolesNo = val))),
                    MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildDropdownField("Planter Hole Size", "Select Size", value: _selectedPlanterHoleSize, options: _planterHoleSizeOptions, displayMember: 'PLANTERHOLESIZE', valueMember: 'PLANTERHOLESIZE', onChanged: (val) => setState(() => _selectedPlanterHoleSize = val))),
                    MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildDropdownField("Planter Hole Shape", "Select Shape", value: _selectedPlanterHoleShape, options: _planterHoleShapeOptions, displayMember: 'PlanterHoleShape', valueMember: 'PlanterHoleShape', onChanged: (val) => setState(() => _selectedPlanterHoleShape = val))),
                    MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildDropdownField("Space", "Select Space", value: _selectedSpace, options: _spaceOptions, displayMember: 'PlanterHoleSpace', valueMember: 'PlanterHoleSpace', onChanged: (val) => setState(() => _selectedSpace = val))),
                    MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildDropdownField("Drain", "Select Drain", value: _selectedDrain, options: _drainOptions, displayMember: 'Drain', valueMember: 'Drain', onChanged: (val) => setState(() => _selectedDrain = val))),
                    MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildDropdownField("Drain Size", "Select Drain Size", value: _selectedDrainSize, options: _drainSizeOptions, displayMember: 'DrainSize', valueMember: 'DrainSize', onChanged: (val) => setState(() => _selectedDrainSize = val))),
                    MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildDropdownField("Drain Position", "Select Position", value: _selectedDrainPosition, options: _drainPositionOptions, displayMember: 'DrainPosition', valueMember: 'DrainPosition', onChanged: (val) => setState(() => _selectedDrainPosition = val))),
                    MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildDropdownField("Lifespan", "Select Lifespan", value: _selectedLifespan, options: _lifespanOptions, displayMember: 'Lifespan', valueMember: 'Lifespan', onChanged: (val) => setState(() => _selectedLifespan = val))),
            MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Diagram", "Upload Diagram", _diagramController, readOnly: true, onTap: _pickDiagram, suffixIcon: Icon(LucideIcons.cloud_upload, size: 18, color: contentTheme.primary), isRequired: false)),
                    MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Patn Code", "Enter Patn Code", _patnCodeController)),
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
                                  child: _newPatnCode ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary) : null,
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
                  MyFlexItem(sizes: 'lg-12', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [MySpacing.height(16), MyText.titleMedium("Delivery Options", fontWeight: 600), Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255))])),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildTextField("Delivery Date", "Select Delivery Date", _deliveryDateController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _deliveryDateController),
                      suffixIcon: Icon(LucideIcons.calendar, size: 18, color: contentTheme.primary),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Delivery Date is required';
                        if (_plantingDateController.text.isNotEmpty) {
                          if (!_isDeliveryBeforePlanting(value, _plantingDateController.text)) {
                            return 'Must be before Planting Date';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  MyFlexItem(
                    sizes: 'lg-3 md-6 sm-12',
                    child: _buildTextField("Planting Date", "Select Planting Date", _plantingDateController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _plantingDateController),
                      suffixIcon: Icon(LucideIcons.calendar, size: 18, color: contentTheme.primary),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Planting Date is required';
                        if (_deliveryDateController.text.isNotEmpty) {
                          if (!_isDeliveryBeforePlanting(_deliveryDateController.text, value)) {
                            return 'Must be after Delivery Date';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  MyFlexItem(sizes: 'lg-2 md-4 sm-12', child: _buildDropdownField("POD", "Select POD", value: _selectedPod, options: _podOptions, displayMember: 'portshortname', valueMember: 'portshortname', onChanged: (val) => setState(() => _selectedPod = val))),
                  MyFlexItem(sizes: 'lg-2 md-4 sm-12', child: _buildTextField("QTY", "Enter QTY", _qtyController, isNumber: true)),
                  MyFlexItem(sizes: 'lg-6 md-6 sm-12', child: _buildTextField("Memo(India)", "Enter Memo", _memoIndiaController, maxLines: 3, isRequired: false)),
                  MyFlexItem(
                    sizes: 'lg-6 md-6 sm-12',
                    child: _buildTextField(
                      "Memo(Jpn)",
                      "Enter Memo",
                      _memoJpnController,
                      maxLines: 3,
                      isRequired: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (_formKey.currentState!.validate()) {
                          _submitUpdate();
                        }
                      },
                    ),
                  ),
                ],
              ),

              MySpacing.height(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyButton.text(
                    onPressed: () => Navigator.pop(context),
                    child: MyText.labelMedium("Cancel", color: contentTheme.onBackground),
                  ),
                  MySpacing.width(16),
                  MyButton.rounded(
                    onPressed: _isSubmitting ? null : _submitUpdate,
                    elevation: 0,
                    padding: MySpacing.xy(24, 16),
                    backgroundColor: contentTheme.primary,
                    child: _isSubmitting
                        ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: contentTheme.onPrimary, strokeWidth: 2))
                        : MyText.labelMedium("Save Changes", color: contentTheme.onPrimary, fontWeight: 600),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {bool readOnly = false,
      VoidCallback? onTap,
      Widget? suffixIcon,
      bool isRequired = true,
      int maxLines = 1,
      bool isNumber = false,
      int? maxLength,
      bool isSmall = false,
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
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          focusNode: focusNode,
          textInputAction: textInputAction ?? (readOnly ? TextInputAction.none : TextInputAction.next),
          onFieldSubmitted: onFieldSubmitted,
          inputFormatters: [
            if (isNumber) FilteringTextInputFormatter.digitsOnly,
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
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
            hintStyle: MyTextStyle.bodySmall(color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
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
            fillColor: readOnly
                ? contentTheme.onBackground.withValues(alpha: 10 / 255)
                : contentTheme.background,
            isDense: isSmall,
            contentPadding:
                isSmall ? MySpacing.xy(12, 12) : MySpacing.all(16),
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