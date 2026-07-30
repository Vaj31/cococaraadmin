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
import 'package:ccpladmin/services/purchase_order_service.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:ccpladmin/features/po/presentation/views/po_checklist_screen.dart';
import 'package:ccpladmin/features/po/presentation/views/assign_suppliers_screen.dart';
import 'package:ccpladmin/features/po/presentation/views/production_status_screen.dart';
import 'package:ccpladmin/features/po/presentation/views/qc_status_screen.dart';
import 'package:ccpladmin/features/po/presentation/views/images_screen.dart';
import 'package:ccpladmin/features/po/presentation/views/dispatch_docs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ViewPolistScreen extends StatefulWidget {
  final PolistModel data;

  const ViewPolistScreen({super.key, required this.data});

  @override
  _ViewPolistScreenState createState() => _ViewPolistScreenState();
}

class _ViewPolistScreenState extends State<ViewPolistScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  late TabController _tabController;
  int _selectedMenuIndex = 0;
  bool _isOrderDetailsLoading = false;
  bool _isSaving = false;
  bool _hasExistingExcess = false;
  bool _hasExistingCcExcess = false;

  final GlobalKey<PoChecklistScreenState> _checklistKey = GlobalKey<PoChecklistScreenState>();
  final GlobalKey<AssignSuppliersScreenState> _assignSuppliersKey = GlobalKey<AssignSuppliersScreenState>();

  final List<Map<String, dynamic>> _menuItems = [
    {"title": "Order Details", "icon": LucideIcons.file_text},
    {"title": "PO Checklist", "icon": LucideIcons.square_check},
    {"title": "Assign Suppliers", "icon": LucideIcons.users},
    {"title": "Production Status", "icon": LucideIcons.factory},
    {"title": "QC Status", "icon": LucideIcons.clipboard_check},
    {"title": "Images", "icon": LucideIcons.image},
    {"title": "Dispatch Docs", "icon": LucideIcons.truck},
  ];

  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _salesController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _ecController = TextEditingController();
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _cropController = TextEditingController();
  final TextEditingController _dimLController = TextEditingController();
  final TextEditingController _dimDController = TextEditingController();
  final TextEditingController _dimHController = TextEditingController();
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _packingBagController = TextEditingController();
  final TextEditingController _cartonBoxController = TextEditingController();
  final TextEditingController _polyBagController = TextEditingController();
  final TextEditingController _coverCuttingController = TextEditingController();
  final TextEditingController _planterHolesNoController = TextEditingController();
  final TextEditingController _planterHoleSizeController = TextEditingController();
  final TextEditingController _planterHoleShapeController = TextEditingController();
  final TextEditingController _spaceController = TextEditingController();
  final TextEditingController _drainController = TextEditingController();
  final TextEditingController _drainSizeController = TextEditingController();
  final TextEditingController _drainShapeController = TextEditingController();
  final TextEditingController _drainPositionController = TextEditingController();
  final TextEditingController _lifespanController = TextEditingController();
  final TextEditingController _specialTreatmentController = TextEditingController();
  final TextEditingController _diagramController = TextEditingController();
  final TextEditingController _patnCodeController = TextEditingController();
  final TextEditingController _newPatnController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
  final TextEditingController _plantingDateController = TextEditingController();
  final TextEditingController _podController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _memoIndiaController = TextEditingController();
  final TextEditingController _memoJpnController = TextEditingController();
  final TextEditingController _excessController = TextEditingController();
  final TextEditingController _ccExcessController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _ccTotalController = TextEditingController();
  final TextEditingController _shippingIdController = TextEditingController();
  final TextEditingController _etaController = TextEditingController();
  final TextEditingController _gwController = TextEditingController();
  final TextEditingController _prodStartController = TextEditingController();
  final TextEditingController _prodEndController = TextEditingController();
  final TextEditingController _prodLTController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _careerController = TextEditingController();
  final TextEditingController _trackingNumberController = TextEditingController();
  final TextEditingController _forwarderController = TextEditingController();
  final TextEditingController _othersDeliveryDateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _deliveryMonthController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _deliveryFeeController = TextEditingController();
  final TextEditingController _invCreationDateController = TextEditingController();
  final TextEditingController _purchaseAmountController = TextEditingController();
  final TextEditingController _requestMonthController = TextEditingController();
  final TextEditingController _requestAmountController = TextEditingController();
  final TextEditingController _grossProfitController = TextEditingController();
  final TextEditingController _grossProfitMarginController = TextEditingController();
  final TextEditingController _coverCuttingCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _menuItems.length, vsync: this);
    _tabController.addListener(() {
      if (_selectedMenuIndex != _tabController.index) {
        setState(() {
          _selectedMenuIndex = _tabController.index;
        });
      }
    });
    _fetchFullOrderDetails();
  }

  String _formatQty(dynamic qty) {
    if (qty == null) return '';
    double? parsed = double.tryParse(qty.toString());
    if (parsed != null) {
      return parsed.toInt().toString();
    }
    return qty.toString();
  }

  Future<void> _fetchFullOrderDetails() async {
    setState(() {
      _isOrderDetailsLoading = true;
    });

    try {
      final service = PurchaseOrderService();
      final data = await service.getPurchaseOrder(widget.data.orderId);
      
      if (data != null) {
        setState(() {
          final orderData = data is List ? data.first : data;

          String val(String key) => orderData[key]?.toString() ?? '';

          _orderIdController.text = val('orderId');
          _salesController.text = val('sales');
          _customerController.text = val('customer');
          _productController.text = val('product');
          _ecController.text = val('ec');
          _materialController.text = val('material');
          _cropController.text = val('crop');
          _dimLController.text = val('l');
          _dimDController.text = val('d');
          _dimHController.text = val('h');
          _itemCodeController.text = val('itemCode');
          _packingBagController.text = val('packingBag');
          _cartonBoxController.text = val('cartonBox');
          _polyBagController.text = val('polyBag');
          _coverCuttingController.text = val('coverCutting');
          _planterHolesNoController.text = val('planter');
          _planterHoleSizeController.text = val('planterSize');
          _planterHoleShapeController.text = val('planterShape');
          _spaceController.text = val('space');
          _drainController.text = val('drain');
          _drainPositionController.text = val('drainPosition');
          _lifespanController.text = val('lifespan');
          _deliveryDateController.text = val('deliveryLT');
          _plantingDateController.text = val('planting');
          _qtyController.text = _formatQty(val('qty'));
          _memoIndiaController.text = val('memo');
          _drainSizeController.text = val('drainSize');
          _drainShapeController.text = val('drainShape');
          _diagramController.text = val('diagram');
          _podController.text = val('pod');
          _specialTreatmentController.text = val('specialTreatment');

          _memoJpnController.text = val('memoJP');
          _patnCodeController.text = val('patnCode');
          _newPatnController.text = val('newPatn');
          _excessController.text = val('excess');
          _ccExcessController.text = val('ccExcess');
          _hasExistingExcess = val('excess').isNotEmpty;
          _hasExistingCcExcess = val('ccExcess').isNotEmpty;
          
          String shippingIdVal = val('shippingId');
          _shippingIdController.text = (shippingIdVal.isEmpty || shippingIdVal.toLowerCase() == 'null') ? 'Not Assigned' : shippingIdVal;
          
          double poQty = double.tryParse(val('qty').replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
          double excess = double.tryParse(val('excess').replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
          double ccExcess = double.tryParse(val('ccExcess').replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
          _totalController.text = (poQty + excess).toInt().toString();
          _ccTotalController.text = (poQty + ccExcess).toInt().toString();
          _etaController.text = val('eta');
          _gwController.text = val('gw');
          _prodStartController.text = val('prodStart');
          _prodEndController.text = val('prodEnd');
          _prodLTController.text = val('prodLT');
          _daysController.text = val('days');
          _careerController.text = val('career');
          _trackingNumberController.text = val('trackingNumber');
          _forwarderController.text = val('forwarder');
          _othersDeliveryDateController.text = val('othersDeliveryDate');
          _timeController.text = val('time');
          _deliveryMonthController.text = val('deliveryMonth');
          _vehicleController.text = val('vehicle');
          _deliveryFeeController.text = val('deliveryFee');
          _invCreationDateController.text = val('invCreationDate');
          _purchaseAmountController.text = val('purchaseAmount');
          _requestMonthController.text = val('requestMonth');
          _requestAmountController.text = val('requestAmount');
          _grossProfitController.text = val('grossProfit');
          _grossProfitMarginController.text = val('grossProfitMargin');

          _coverCuttingCodeController.text = "Planter Details: ${_getPlanterCode(widget.data)}\nDrain Details: ${_getDrainCode(widget.data)}";
        });
      }
    } catch (e) {
      debugPrint('Failed to load full order details: $e');
      if (mounted) {
        Utils.showErrorToast("Failed to load order details: $e", context: context);
      }
    } finally {
      setState(() {
        _isOrderDetailsLoading = false;
      });
    }
  }

  String _getPlanterCode(PolistModel data) {
    List<String> parts = [data.planter, data.planterShape, data.planterSize, data.space]
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

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    try {
      if (_selectedMenuIndex == 1) { // PO Checklist
        await _checklistKey.currentState?.savePalletConfig();
        final service = PurchaseOrderService();
        await service.updatePurchaseOrder(
            widget.data.orderId, {
              'excess': _excessController.text,
              'ccexcess': _ccExcessController.text
            });
            
        _checklistKey.currentState?.markExcessAsSaved();

        Utils.showSuccessToast(
          "Data Saved successfully!",
          context: context,
        );
        await _fetchFullOrderDetails();
      }
      else if (_selectedMenuIndex == 2) {
        await _assignSuppliersKey.currentState?.saveAssignedSuppliers();
        Utils.showSuccessToast(
          "Assigned Suppliers saved successfully!",
          context: context,
        );
      }
      // Add other save logic for other tabs here
      else {
        Utils.showInfoToast(
          "No save action for this tab.",
          context: context,
        );
      }
    } catch (e) {
      debugPrint("Failed to save data: $e");
      Utils.showErrorToast(
        "Error saving data: $e",
        context: context,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderIdController.dispose();
    _salesController.dispose();
    _customerController.dispose();
    _productController.dispose();
    _ecController.dispose();
    _materialController.dispose();
    _cropController.dispose();
    _dimLController.dispose();
    _dimDController.dispose();
    _dimHController.dispose();
    _itemCodeController.dispose();
    _packingBagController.dispose();
    _cartonBoxController.dispose();
    _polyBagController.dispose();
    _coverCuttingController.dispose();
    _planterHolesNoController.dispose();
    _planterHoleSizeController.dispose();
    _planterHoleShapeController.dispose();
    _spaceController.dispose();
    _drainController.dispose();
    _drainSizeController.dispose();
    _drainShapeController.dispose();
    _drainPositionController.dispose();
    _lifespanController.dispose();
    _specialTreatmentController.dispose();
    _diagramController.dispose();
    _patnCodeController.dispose();
    _newPatnController.dispose();
    _deliveryDateController.dispose();
    _plantingDateController.dispose();
    _podController.dispose();
    _qtyController.dispose();
    _memoIndiaController.dispose();
    _memoJpnController.dispose();
    _excessController.dispose();
    _ccExcessController.dispose();
    _totalController.dispose();
    _ccTotalController.dispose();
    _shippingIdController.dispose();
    _etaController.dispose();
    _gwController.dispose();
    _prodStartController.dispose();
    _prodEndController.dispose();
    _prodLTController.dispose();
    _daysController.dispose();
    _careerController.dispose();
    _trackingNumberController.dispose();
    _forwarderController.dispose();
    _othersDeliveryDateController.dispose();
    _timeController.dispose();
    _deliveryMonthController.dispose();
    _vehicleController.dispose();
    _deliveryFeeController.dispose();
    _invCreationDateController.dispose();
    _purchaseAmountController.dispose();
    _requestMonthController.dispose();
    _requestAmountController.dispose();
    _grossProfitController.dispose();
    _grossProfitMarginController.dispose();
    _coverCuttingCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Padding(
        padding: MySpacing.x(flexSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  _menuItems[_selectedMenuIndex]['title'],
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Purchase Order', route: '/purchase_order'),
                    MyBreadcrumbItem(name: _menuItems[_selectedMenuIndex]['title'], active: true),
                  ],
                ),
              ],
            ),
            MySpacing.height(flexSpacing),
            MyCard(
              paddingAll: 23,
              borderRadiusAll: 8,
              shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: contentTheme.primary,
                    labelColor: contentTheme.primary,
                    unselectedLabelColor: contentTheme.onBackground,
                    tabAlignment: TabAlignment.start,
                    tabs: _menuItems.map((item) {
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item['icon'], size: 18),
                            MySpacing.width(8),
                            Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  MySpacing.height(24),
                  _buildSummaryHeader(),
                  MySpacing.height(24),
                  Divider(height: 1, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
                  MySpacing.height(24),
                  _buildActiveContent(),
                  MySpacing.height(24),
                  Divider(height: 1, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
                  MySpacing.height(24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyButton.rounded(
                        onPressed: () => Navigator.pop(context),
                        elevation: 0,
                        padding: MySpacing.xy(24, 16),
                        backgroundColor: contentTheme.primary,
                        child: MyText.bodyMedium("Back",
                            color: contentTheme.onPrimary, fontWeight: 600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildSummaryHeader() {
    bool isAssignSuppliers = _selectedMenuIndex == 2;
    String flexSize = 'lg-2 md-4 sm-6';

    return MyFlex(
      contentPadding: false,
      children: [
        _buildHeaderItem("Order ID", widget.data.orderId, LucideIcons.file_digit, sizes: flexSize),
        _buildHeaderItem("Order Date", widget.data.orderDate, LucideIcons.calendar, sizes: flexSize),
        if (!isAssignSuppliers) ...[
          _buildHeaderItem("Shipping ID", _shippingIdController.text.isNotEmpty ? _shippingIdController.text : 'Not Assigned', LucideIcons.truck, sizes: flexSize),
          _buildHeaderItem("Status", widget.data.orderStatus, LucideIcons.activity, sizes: flexSize),
        ],
        _buildHeaderItem("Item Code", widget.data.itemCode, LucideIcons.tag, sizes: flexSize),
        _buildHeaderItem("QTY", _totalController.text.isNotEmpty ? _totalController.text : _formatQty(widget.data.qty), LucideIcons.hash, sizes: flexSize),
        if (isAssignSuppliers && widget.data.coverCutting.toString().toLowerCase() == 'yes')
          _buildHeaderItem("CC QTY", _ccTotalController.text.isNotEmpty ? _ccTotalController.text : '0', LucideIcons.hash, sizes: flexSize),
      ],
    );
  }

  
  MyFlexItem _buildHeaderItem(String label, String value, IconData icon, {String sizes = 'lg-2 md-4 sm-6'}) {
    return MyFlexItem(
      sizes: sizes,
      child: Container(
        padding: 
           MySpacing.all(12),
        decoration: BoxDecoration(
          color: contentTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: contentTheme.onBackground.withValues(alpha: 10 / 255)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
                MySpacing.width(6),
                MyText.labelSmall(label, color: contentTheme.onBackground.withValues(alpha: 100 / 255), fontWeight: 600),
              ],
            ),
            MySpacing.height(4),
            MyText.bodyMedium(value, fontWeight: 700),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContent() {
    if (_isOrderDetailsLoading && _selectedMenuIndex == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (_selectedMenuIndex) {
      case 0:
        return _buildOrderDetailsForm();
      case 1:
        return PoChecklistScreen(
          key: _checklistKey, 
          data: widget.data,
          excessController: _excessController,
          ccExcessController: _ccExcessController,
          prodStartController: _prodStartController,
          prodEndController: _prodEndController,
          prodLTController: _prodLTController,
          daysController: _daysController,
          hasExistingExcess: _hasExistingExcess,
          hasExistingCcExcess: _hasExistingCcExcess,
          onDataFetched: () {
            if (mounted) {
              setState(() {});
              _fetchFullOrderDetails();
            }
          },
        );
      case 2:
        return AssignSuppliersScreen(key: _assignSuppliersKey, data: widget.data);
      case 3:
        return ProductionStatusScreen(data: widget.data);
      case 4:
        return QcStatusScreen(data: widget.data);
      case 5:
        return ImagesScreen(data: widget.data);
      case 6:
        return DispatchDocsScreen(data: widget.data);
      default:
        return Center(
            child: MyText.bodyLarge("${_menuItems[_selectedMenuIndex]['title']} Content"));
    }
  }

  Widget _buildOrderDetailsForm() {
    return Form(
      child: MyFlex(
        contentPadding: false,
        children: [
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Order ID", _orderIdController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Sales", _salesController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Customer", _customerController),
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
            child: _buildTextField("Product Group", _productController),
          ),
          MyFlexItem(
            sizes: 'lg-2 md-6 sm-12',
            child: _buildTextField("EC", _ecController),
          ),
          MyFlexItem(
            sizes: 'lg-2 md-6 sm-12',
            child: _buildTextField("Material", _materialController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Special Treatment", _specialTreatmentController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Crop", _cropController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: Row(
              children: [
                Expanded(child: _buildTextField("L", _dimLController)),
                MySpacing.width(8),
                Expanded(child: _buildTextField("D", _dimDController)),
                MySpacing.width(8),
                Expanded(child: _buildTextField("H", _dimHController)),
              ],
            ),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Item Code", _itemCodeController),
          ),
          MyFlexItem(
            sizes: 'lg-12 md-12 sm-12',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCheckboxField("Poly Bag", _polyBagController),
                ),
                if (_polyBagController.text.toLowerCase() == 'yes')
                  Expanded(
                    child: _buildCheckboxField("Cover Cutting", _coverCuttingController),
                  ),
                Expanded(
                  child: _buildCheckboxField("Packing Bag", _packingBagController),
                ),
                Expanded(
                  child: _buildCheckboxField("Carton Box", _cartonBoxController),
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
                MyText.titleMedium("Cover Cutting Details", fontWeight: 600),
                Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
              ],
            ),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Planter Holes No", _planterHolesNoController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Planter Hole Size", _planterHoleSizeController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Planter Hole Shape", _planterHoleShapeController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Space", _spaceController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Drain", _drainController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Drain Size", _drainSizeController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Drain Shape", _drainShapeController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Drain Position", _drainPositionController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Lifespan", _lifespanController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Diagram", _diagramController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Patn Code", _patnCodeController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildCheckboxField("New Patn Code", _newPatnController),
          ),

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
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Delivery Date", _deliveryDateController),
          ),
          MyFlexItem(
            sizes: 'lg-3 md-6 sm-12',
            child: _buildTextField("Planting Date", _plantingDateController),
          ),
          MyFlexItem(
            sizes: 'lg-2 md-4 sm-12',
            child: _buildTextField("POD", _podController),
          ),
          MyFlexItem(
            sizes: 'lg-2 md-4 sm-12',
            child: _buildTextField("QTY", _qtyController),
          ),
          
          MyFlexItem(
            sizes: 'lg-6 md-6 sm-12',
            child: _buildTextField("Memo(India)", _memoIndiaController, maxLines: 3),
          ),
          MyFlexItem(
            sizes: 'lg-6 md-6 sm-12',
            child: _buildTextField("Memo(Jpn)", _memoJpnController, maxLines: 3),
          ),
          
          MyFlexItem(
            sizes: 'lg-12',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MySpacing.height(16),
                MyText.titleMedium("Excess Details", fontWeight: 600),
                Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
              ],
            ),
          ),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Item Code", _itemCodeController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("PO QTY", _qtyController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Excess", _excessController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Total", _totalController)),
          if (widget.data.coverCutting.toString().toLowerCase() == 'yes') ...[
            MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Cover Cutting Code", _coverCuttingCodeController, maxLines: 2)),
            MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("PO QTY", _qtyController)),
            MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("CC Excess", _ccExcessController)),
            MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("CC Total", _ccTotalController)),
          ],
          
          MyFlexItem(
            sizes: 'lg-12',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MySpacing.height(16),
                MyText.titleMedium("Production Details", fontWeight: 600),
                Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
              ],
            ),
          ),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Production Start", _prodStartController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Production End", _prodEndController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Production L/T", _prodLTController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Days", _daysController)),
          
          MyFlexItem(
            sizes: 'lg-12',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MySpacing.height(16),
                MyText.titleMedium("Shipping Details", fontWeight: 600),
                Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
              ],
            ),
          ),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Shipping ID", _shippingIdController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("ETA", _etaController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("G/W", _gwController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Carrier", _careerController)),
          
          MyFlexItem(
            sizes: 'lg-12',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MySpacing.height(16),
                MyText.titleMedium("Transporter Details", fontWeight: 600),
                Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
              ],
            ),
          ),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Tracking Number", _trackingNumberController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Forwarder", _forwarderController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Delivery Date", _othersDeliveryDateController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Time", _timeController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Delivery Month", _deliveryMonthController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Vehicle", _vehicleController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Delivery Fee", _deliveryFeeController)),
          
          MyFlexItem(
            sizes: 'lg-12',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MySpacing.height(16),
                MyText.titleMedium("Invoice Details", fontWeight: 600),
                Divider(height: 8, color: contentTheme.onBackground.withValues(alpha: 20 / 255)),
              ],
            ),
          ),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Invoice Date", _invCreationDateController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Purchase Amount", _purchaseAmountController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Invoice Month", _requestMonthController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Invoice Amount", _requestAmountController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Gross Profit", _grossProfitController)),
          MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildTextField("Gross Profit Margin", _grossProfitMarginController)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(label, fontWeight: 600),
        MySpacing.height(8),
        TextFormField(
          controller: controller,
          readOnly: true,
          maxLines: maxLines,
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

  Widget _buildCheckboxField(String label, TextEditingController controller) {
    bool isChecked = controller.text.toLowerCase() == 'yes';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(label, fontWeight: 600),
        MySpacing.height(18),
        Row(
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: isChecked ? contentTheme.primary : Colors.transparent,
                border: Border.all(
                  color: isChecked ? contentTheme.primary : contentTheme.onBackground.withValues(alpha: 100 / 255),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isChecked ? Icon(LucideIcons.check, size: 14, color: contentTheme.onPrimary) : null,
            ),
            MySpacing.width(8),
            MyText.bodyMedium(isChecked ? "Yes" : "No", fontWeight: 600),
          ],
        ),
      ],
    );
  }
}