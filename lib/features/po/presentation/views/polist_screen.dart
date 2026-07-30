import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/widgets/my_flex.dart';
import 'package:ccpladmin/helpers/widgets/my_flex_item.dart';
import 'package:ccpladmin/helpers/widgets/my_list_extension.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_button.dart';
import 'package:ccpladmin/model/polist_model.dart';
import 'package:ccpladmin/services/shipping_schedule_service.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:ccpladmin/features/po/presentation/views/create_polist_screen.dart';
import 'package:ccpladmin/features/po/presentation/views/edit_polist_screen.dart';
import 'package:ccpladmin/features/po/presentation/views/view_polist_screen.dart'; 
import 'package:ccpladmin/features/po/presentation/providers/po_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class PolistScreen extends ConsumerStatefulWidget {
  const PolistScreen({super.key});

  @override
  ConsumerState<PolistScreen> createState() => _PolistScreenState();
}

class _PolistScreenState extends ConsumerState<PolistScreen>
    with SingleTickerProviderStateMixin, UIMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  Map<String, Color> _shippingColors = {};



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(polistProvider.notifier).fetchPolist();
      _fetchShippingColors();
    });
  }

  Future<void> _fetchShippingColors() async {
    try {
      final shippingScheduleService = ShippingScheduleService();
      final rawData = await shippingScheduleService.getAll();
      Map<String, Color> colors = {};
      for (var item in rawData) {
        String shippingId = item['shippingid']?.toString() ?? '';
        String? colorStr = item['color']?.toString();
        if (shippingId.isNotEmpty && colorStr != null && colorStr.isNotEmpty && colorStr != 'null') {
          try {
            colors[shippingId] = Color(int.parse(colorStr, radix: 16));
          } catch (_) {}
        }
      }
      if (mounted) {
        setState(() {
          _shippingColors = colors;
        });
      }
    } catch (e) {
      debugPrint("Error fetching shipping colors: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final state = ref.watch(polistProvider);
    final notifier = ref.read(polistProvider.notifier);

    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  "Purchase Order",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Purchase Order List', active: true),
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
                MyFlexItem(sizes: 'lg-12 md-12', child: productOrder(state, notifier))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget productOrder(PolistState state, PolistNotifier notifier) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<PolistModel> filteredList = state.po;
    if (_searchText.isNotEmpty) {
      filteredList = state.po.where((data) {
        String search = _searchText.toLowerCase();
        bool match(String? value) =>
            value != null && value.toLowerCase().contains(search);

        return match(data.revision) ||
            match(data.orderId) ||
            match(data.orderDate) ||
            match(data.shippingId) ||
            match(data.deliveryDate) ||
            match(data.sales) ||
            match(data.customer) ||
            match(data.itemCode) ||
            match(data.planterCode) ||
            match(data.drainCode) ||
            match(data.qty) ||
            match(data.orderStatus) ||
            match(data.product) ||
            match(data.planting) ||
            match(data.deliveryLT) ||
            match(data.material) ||
            match(data.l) ||
            match(data.d) ||
            match(data.h) ||
            match(data.ec) ||
            match(data.crop) ||
            match(data.planter) ||
            match(data.planterSize) ||
            match(data.planterShape) ||
            match(data.space) ||
            match(data.drain) ||
            match(data.drainPosition) ||
            match(data.lifespan) ||
            match(data.memo);
      }).toList();
    }
    int totalItems = filteredList.length;
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

    List<PolistModel> currentData = [];
    if (totalItems > 0) {
      currentData = filteredList.sublist(startIndex, endIndex);
    }

    return MyCard(
      borderRadiusAll: 8,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 23,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium("Purchase Order", fontWeight: 600),
              Row(
                children: [
                   MyButton.rounded(
                     onPressed: () async {
                       await Navigator.push(
                         context,
                         MaterialPageRoute(
                             builder: (context) => const CreatePolistScreen()),
                       );
                       notifier.fetchPolist();
                     },
                     elevation: 0,
                     padding: MySpacing.xy(20, 16),
                     backgroundColor: contentTheme.primary,
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Icon(
                           LucideIcons.plus,
                           color: contentTheme.onPrimary,
                           size: 18,
                         ),
                         MySpacing.width(8),
                         MyText.labelLarge(
                           "New Purchase Order",
                           color: contentTheme.onPrimary,
                           fontWeight: 600,
                         ),
                       ],
                     ),
                   ),
                ],
              ),
            ],
          ),
          MySpacing.height(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search all data...",
                    hintStyle: TextStyle(
                        fontSize: 13,
                        color: contentTheme.onBackground.withValues(alpha: 150 / 255)),
                    prefixIcon: Icon(LucideIcons.search,
                        size: 18,
                        color: contentTheme.onBackground.withValues(alpha: 150 / 255)),
                    filled: true,
                    fillColor: contentTheme.background.withValues(alpha: 50 / 255),
                    contentPadding: MySpacing.xy(12, 8),
                    isDense: true,
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
                      borderSide: BorderSide(
                          color: contentTheme.primary.withValues(alpha: 100 / 255)),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),

            ],
          ),

          MySpacing.height(20),
          if (filteredList.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.black.withValues(alpha: 0.3),
                        width: 0.8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: contentTheme.primary.withValues(alpha: 40 / 255),
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.black.withValues(alpha: 0.3),
                                width: 0.8),
                          ),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _headerCell('Rev', width: 45),
                              _headerCell('Order Id', flex: 6),
                              _headerCell('Order Date', flex: 5),
                              _headerCell('Shipping ID', flex: 6),
                              _headerCell('Delivery Date', flex: 5),
                              _headerCell('Sales', flex: 6),
                              _headerCell('Item Code', flex: 8),
                              _headerCell('Planter Code', flex: 8),
                              _headerCell('Drain Code', flex: 8),
                              _headerCell('QTY', width: 55),
                              _headerCell('Action', width: 128, hasRightBorder: false, center: true),
                            ],
                          ),
                        ),
                      ),
                      ...currentData.mapIndexed((index, data) {
                        return _PolistExpandableRow(
                          data: data,
                          isEven: index % 2 == 0,
                          notifier: notifier,
                          rowColor: _shippingColors[data.shippingId],
                          isLast: index == currentData.length - 1,
                        );
                      }),
                    ],
                  ),
                ),

                 MySpacing.height(20),
                 _buildPaginationControls(totalPages, totalItems, startIndex + 1, endIndex),
              ],
            )
          else
            Center(
              child: Padding(
                padding: MySpacing.y(40),
                child: Column(
                  children: [
                  Icon(LucideIcons.search_x,
                        size: 40,
                        color: contentTheme.onBackground.withValues(alpha: 100 / 255)),
                    MySpacing.height(10),
                    MyText.bodyMedium("No records found for '$_searchText'",
                        color: contentTheme.onBackground.withValues(alpha: 150 / 255)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _headerText(String text) {
    return MyText.labelLarge(
      text,
      fontWeight: 700,
      color: contentTheme.primary,
      fontSize: 14,
      maxLines: 1,
    );
  }

  Widget _headerCell(String text, {double? width, int? flex, bool hasRightBorder = true, bool center = false}) {
    final cellContent = Container(
      width: width,
      padding: MySpacing.xy(6, 16),
      alignment: center ? Alignment.center : Alignment.centerLeft,
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
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: _headerText(text),
      ),
    );

    if (flex != null) {
      return Expanded(
        flex: flex,
        child: cellContent,
      );
    }
    return cellContent;
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
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

class _PolistExpandableRow extends StatefulWidget {
  final PolistModel data;
  final bool isEven;
  final PolistNotifier notifier;
  final Color? rowColor;
  final bool isLast;

  const _PolistExpandableRow({
    required this.data,
    required this.isEven,
    required this.notifier,
    required this.isLast,
    this.rowColor,
  });

  @override
  State<_PolistExpandableRow> createState() => _PolistExpandableRowState();
}

class _PolistExpandableRowState extends State<_PolistExpandableRow>
    with UIMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          hoverColor: contentTheme.primary.withValues(alpha: 10 / 255),
          child: Container(
            decoration: BoxDecoration(
              color: widget.rowColor ??
                  (widget.isEven
                      ? Colors.transparent
                      : contentTheme.background.withValues(alpha: 10 / 255)),
              border: Border(
                  bottom: (widget.isLast && !_isExpanded)
                      ? BorderSide.none
                      : BorderSide(
                          color: Colors.black.withValues(alpha: 0.3),
                          width: 0.8)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _rowCell(widget.data.revision.isNotEmpty ? widget.data.revision : "--", width: 45),
                  _rowCell(widget.data.orderId.isNotEmpty ? widget.data.orderId : "--", flex: 6),
                  _rowCell(widget.data.orderDate.isNotEmpty ? widget.data.orderDate : "--", flex: 5),
                  _rowCell(
                      widget.data.shippingId.isNotEmpty && widget.data.shippingId.toLowerCase() != 'null'
                          ? widget.data.shippingId
                          : "Not Assigned",
                      flex: 6),
                  _rowCell(widget.data.deliveryLT.isNotEmpty ? widget.data.deliveryLT : "--", flex: 5),
                  _rowCell(widget.data.sales.isNotEmpty ? widget.data.sales : "--", flex: 6),
                  _rowCell(widget.data.itemCode.isNotEmpty ? widget.data.itemCode : "--", flex: 8),
                  _rowCell(_getPlanterCode(widget.data), flex: 8),
                  _rowCell(_getDrainCode(widget.data), flex: 8),
                  _rowCell(widget.data.qty.isNotEmpty ? widget.data.qty : "--", width: 55),
                  Container(
                    width: 128,
                    padding: MySpacing.y(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 32,
                          child: Icon(
                            _isExpanded
                                ? LucideIcons.chevron_up
                                : LucideIcons.chevron_down,
                            size: 20,
                            color: contentTheme.onBackground.withValues(alpha: 160 / 255),
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ViewPolistScreen(data: widget.data),
                                ),
                              );
                            },
                            icon: Icon(LucideIcons.settings,
                                size: 18, color: contentTheme.success),
                            tooltip: "View",
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditPolistScreen(data: widget.data),
                                ),
                              );
                              widget.notifier.fetchPolist();
                            },
                            icon: Icon(LucideIcons.pencil,
                                size: 18, color: contentTheme.primary),
                            tooltip: "Edit",
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: MyText.titleMedium("Delete Purchase Order",
                                      fontWeight: 600),
                                  content: MyText.bodyMedium(
                                      "Are you sure you want to delete this order?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: MyText.bodyMedium("Cancel"),
                                      ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        widget.notifier.deletePolist(widget.data.orderId);
                                      },
                                      child: MyText.bodyMedium("Delete", color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(LucideIcons.trash_2,
                                size: 18, color: Colors.redAccent),
                            tooltip: "Delete",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0),
          secondChild: Container(
            width: double.infinity,
            padding: MySpacing.all(20),
            decoration: BoxDecoration(
                color: contentTheme.primary.withValues(alpha: 10 / 255),
                border: Border(
                    bottom: widget.isLast
                        ? BorderSide.none
                        : BorderSide(
                            color: Colors.black.withValues(alpha: 0.3),
                            width: 0.8))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailItem("Order Status", widget.data.orderStatus,
                              isHighlight: true),
                          _detailItem("Customer", widget.data.customer),
                          _detailItem("Product", widget.data.product),
                          _detailItem("Planting", widget.data.planting),
                          _detailItem("Delivery LT", widget.data.deliveryLT),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailItem("Material", widget.data.material),
                          _detailItem("Dimensions (LxDxH)",
                              "${widget.data.l} x ${widget.data.d} x ${widget.data.h}"),
                          _detailItem("EC", widget.data.ec),
                          _detailItem("Crop", widget.data.crop),
                          _detailItem("Excess", widget.data.excess.isNotEmpty ? widget.data.excess : "0"),
                          _detailItem("Total QTY", _getTotalQty(widget.data)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailItem("Planter", widget.data.planter),
                          _detailItem("Planter Size", widget.data.planterSize),
                          _detailItem(
                              "Planter Shape", widget.data.planterShape),
                          _detailItem("Space", widget.data.space),
                          if (widget.data.coverCutting.toLowerCase() == 'yes') ...[
                            _detailItem("CC Excess", widget.data.ccExcess.isNotEmpty ? widget.data.ccExcess : "0"),
                            _detailItem("CC Total", _getCcTotalQty(widget.data)),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailItem("Drain", widget.data.drain),
                          _detailItem("Drain Size", widget.data.drainSize),
                          _detailItem("Drain Shape", widget.data.drainShape),
                          _detailItem("Drain Position", widget.data.drainPosition),
                          _detailItem("Lifespan", widget.data.lifespan),
                          _detailItem("Memo", widget.data.memo),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _detailItem(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: MySpacing.bottom(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodySmall(label.toUpperCase(),
              fontWeight: 700,
              color: contentTheme.onBackground.withValues(alpha: 140 / 255),
              fontSize: 11),
          MySpacing.height(4),
          MyText.bodyMedium(
            value.isEmpty ? "-" : value,
            fontWeight: 600,
            color:
                isHighlight ? contentTheme.primary : contentTheme.onBackground,
          ),
        ],
      ),
    );
  }

  String _getTotalQty(PolistModel data) {
    double poQty = double.tryParse(data.qty.replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    double excess = double.tryParse(data.excess.replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    return (poQty + (poQty * excess / 100)).toInt().toString();
  }

  String _getCcTotalQty(PolistModel data) {
    double poQty = double.tryParse(data.qty.replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    double ccExcess = double.tryParse(data.ccExcess.replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 0;
    return (poQty + (poQty * ccExcess / 100)).toInt().toString();
  }

  Widget _rowCell(String text, {double? width, int? flex, bool center = false}) {
    Widget cell = Container(
      padding: MySpacing.xy(6, 12),
      width: width,
      alignment: center ? Alignment.center : Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
              color: Colors.black.withValues(alpha: 0.3),
              width: 0.8),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: MyText.bodyMedium(
          text,
          maxLines: 1,
        ),
      ),
    );

    if (flex != null) {
      return Expanded(
        flex: flex,
        child: cell,
      );
    }
    return cell;
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
}
