import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/utils.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ccpladmin/features/masters/presentation/views/add_customer_screen.dart';
import 'package:ccpladmin/features/masters/presentation/providers/masters_providers.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> with SingleTickerProviderStateMixin, UIMixin {
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersState = ref.watch(customerListProvider);

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
                  "Customer Master",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Masters'),
                    MyBreadcrumbItem(name: 'Customers', active: true),
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
              shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyText.bodyMedium("Customer List", fontWeight: 600),
                      ),
                      SizedBox(
                        width: 250,
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Search all data...",
                            hintStyle: TextStyle(fontSize: 13, color: contentTheme.onBackground.withAlpha(150)),
                            prefixIcon: Icon(LucideIcons.search, size: 18, color: contentTheme.onBackground.withAlpha(150)),
                            filled: true,
                            fillColor: contentTheme.background.withAlpha(50),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: contentTheme.onBackground.withAlpha(30)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: contentTheme.primary, width: 1.5),
                            ),
                            contentPadding: MySpacing.xy(12, 8),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      MySpacing.width(16),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Get.to(() => const AddCustomerScreen());
                          if (result == true) {
                            ref.read(customerListProvider.notifier).fetchCustomers();
                          }
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: contentTheme.primary,
                          padding: MySpacing.xy(16, 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.plus, size: 18, color: contentTheme.onPrimary),
                            MySpacing.width(8),
                            MyText.labelMedium("Add Customer", color: contentTheme.onPrimary, fontWeight: 600),
                          ],
                        ),
                      )
                    ],
                  ),
                  MySpacing.height(16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: contentTheme.onBackground.withAlpha(20), width: 0.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Container(
                          padding: MySpacing.xy(16, 12),
                          decoration: BoxDecoration(
                            color: contentTheme.primary.withAlpha(40),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: MyText.labelLarge("Customer Name", fontWeight: 600, color: contentTheme.primary)),
                              Expanded(flex: 2, child: MyText.labelLarge("Contact Person", fontWeight: 600, color: contentTheme.primary)),
                              Expanded(flex: 2, child: MyText.labelLarge("Email", fontWeight: 600, color: contentTheme.primary)),
                              Expanded(flex: 2, child: MyText.labelLarge("Mobile", fontWeight: 600, color: contentTheme.primary)),
                              Expanded(flex: 1, child: MyText.labelLarge("Status", fontWeight: 600, color: contentTheme.primary)),
                              SizedBox(width: 120, child: Center(child: MyText.labelLarge("Action", fontWeight: 600, color: contentTheme.primary))),
                            ],
                          ),
                        ),
                        customersState.when(
                          loading: () => Padding(
                            padding: MySpacing.y(24),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, _) => Padding(
                            padding: MySpacing.y(24),
                            child: Center(child: MyText.bodyMedium("Could not load customers: $error")),
                          ),
                          data: (customersList) {
                            final filteredList = customersList.where((c) {
                              if (_searchQuery.isEmpty) return true;
                              return (c['customername']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                                     (c['contactperson']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                                     (c['email']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
                            }).toList();

                            if (filteredList.isEmpty) {
                              return Padding(
                                padding: MySpacing.y(24),
                                child: Center(child: MyText.bodyMedium("No customers found")),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                bool isLast = index == filteredList.length - 1;
                                return _CustomerExpandableRow(
                                  customer: filteredList[index],
                                  isEven: index % 2 == 0,
                                  isLast: isLast,
                                  ref: ref,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerExpandableRow extends StatefulWidget {
  final Map<String, dynamic> customer;
  final bool isEven;
  final bool isLast;
  final WidgetRef ref;

  const _CustomerExpandableRow({
    required this.customer,
    required this.isEven,
    required this.isLast,
    required this.ref,
  });

  @override
  State<_CustomerExpandableRow> createState() => _CustomerExpandableRowState();
}

class _CustomerExpandableRowState extends State<_CustomerExpandableRow> with UIMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          hoverColor: contentTheme.primary.withAlpha(10),
          child: Container(
            padding: MySpacing.xy(16, 12),
            decoration: BoxDecoration(
              color: widget.isEven ? Colors.transparent : contentTheme.background.withAlpha(10),
              border: widget.isLast
                  ? null
                  : Border(bottom: BorderSide(color: contentTheme.onBackground.withAlpha(20), width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: MyText.bodyMedium(widget.customer['customername'] ?? '', fontWeight: 600)),
                Expanded(flex: 2, child: MyText.bodyMedium(widget.customer['contactperson'] ?? '-')),
                Expanded(flex: 2, child: MyText.bodyMedium(widget.customer['email'] ?? '-')),
                Expanded(flex: 2, child: MyText.bodyMedium(widget.customer['mobileno1'] ?? '-')),
                Expanded(flex: 1, child: Align(alignment: Alignment.centerLeft, child: _buildStatusChip(widget.customer['status'] ?? 'Active'))),
                SizedBox(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        child: Icon(
                          _isExpanded ? LucideIcons.chevron_up : LucideIcons.chevron_down,
                          size: 20,
                          color: contentTheme.onBackground.withAlpha(160),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: IconButton(
                          onPressed: () async {
                            final result = await Get.to(() => AddCustomerScreen(editCustomer: widget.customer));
                            if (result == true) {
                              widget.ref.read(customerListProvider.notifier).fetchCustomers();
                            }
                          },
                          icon: Icon(LucideIcons.pencil, size: 18, color: contentTheme.primary),
                          tooltip: "Edit",
                          padding: MySpacing.zero,
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: IconButton(
                          onPressed: () {
                            Get.dialog(AlertDialog(
                              title: const Text("Delete Customer"),
                              content: Text("Are you sure you want to delete ${widget.customer['customername']}?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Get.back();
                                    final success = await widget.ref
                                        .read(customerListProvider.notifier)
                                        .deleteCustomer(widget.customer['seqnum']);
                                    if (!success) {
                                      Utils.showErrorToast("Could not delete customer", context: context);
                                    }
                                  },
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ));
                          },
                          icon: const Icon(LucideIcons.trash_2, size: 18, color: Colors.redAccent),
                          tooltip: "Delete",
                          padding: MySpacing.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0),
          secondChild: Container(
            width: double.infinity,
            padding: MySpacing.all(20),
            decoration: BoxDecoration(
              color: contentTheme.primary.withAlpha(10),
              border: widget.isLast
                  ? null
                  : Border(bottom: BorderSide(color: contentTheme.onBackground.withAlpha(20), width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.labelMedium("Contact Numbers", fontWeight: 600, color: contentTheme.primary),
                      MySpacing.height(12),
                      _buildDetailRow("Mobile 1", widget.customer['mobileno1']),
                      MySpacing.height(12),
                      _buildDetailRow("Mobile 2", widget.customer['mobileno2']),
                      MySpacing.height(12),
                      _buildDetailRow("Phone 1", widget.customer['phoneno1']),
                    ],
                  ),
                ),
                MySpacing.width(24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.labelMedium("Billing Address", fontWeight: 600, color: contentTheme.primary),
                      MySpacing.height(12),
                      _buildDetailRow("Address", widget.customer['billingaddress']),
                      MySpacing.height(12),
                      _buildDetailRow("Zip Code", widget.customer['billingzipcode']),
                    ],
                  ),
                ),
                MySpacing.width(24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.labelMedium("Shipping Address", fontWeight: 600, color: contentTheme.primary),
                      MySpacing.height(12),
                      _buildDetailRow("Address", widget.customer['shippingaddress']),
                      MySpacing.height(12),
                      _buildDetailRow("Zip Code", widget.customer['shippingzipcode']),
                    ],
                  ),
                ),
              ],
            ),
          ),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodySmall(label.toUpperCase(), fontWeight: 700, color: contentTheme.onBackground.withAlpha(140), fontSize: 10, letterSpacing: 1.1),
        MySpacing.height(4),
        MyText.bodyMedium((value == null || value.trim().isEmpty) ? '--' : value, fontWeight: 600, color: contentTheme.onBackground),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    bool isActive = status.toLowerCase() == 'active';
    Color color = isActive ? const Color(0xFF10B981) : const Color(0xFFF43F5E);
    return Container(
      padding: MySpacing.xy(8, 4),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 0.5),
      ),
      child: MyText.bodySmall(
        status,
        color: color,
        fontWeight: 600,
        fontSize: 11,
      ),
    );
  }
}
