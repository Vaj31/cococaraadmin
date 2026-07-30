import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ccpladmin/features/masters/presentation/providers/masters_providers.dart';

class PalletListScreen extends ConsumerStatefulWidget {
  const PalletListScreen({super.key});

  @override
  ConsumerState<PalletListScreen> createState() => _PalletListScreenState();
}

class _PalletListScreenState extends ConsumerState<PalletListScreen> with UIMixin {

  @override
  Widget build(BuildContext context) {
    final palletState = ref.watch(palletListProvider);

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
                  "Pallet List",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Processing'),
                    MyBreadcrumbItem(name: 'Pallet List', active: true),
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
              child: palletState.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: MyText.bodyMedium("Failed to load pallets: $error"),
                  ),
                ),
                data: (palletData) {
                  return LayoutBuilder(builder: (context, constraints) {
                    double minWidth = constraints.maxWidth > 1250 ? constraints.maxWidth : 1250;
                    return SingleChildScrollView(
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
                                color: contentTheme.primary.withAlpha(40),
                                child: Row(
                                  children: [
                                    SizedBox(width: 140, child: MyText.labelLarge("Shipping ID", fontWeight: 600)),
                                    SizedBox(width: 150, child: MyText.labelLarge("Supplier", fontWeight: 600)),
                                    SizedBox(width: 150, child: MyText.labelLarge("Temp Pallet ID", fontWeight: 600)),
                                    SizedBox(width: 150, child: MyText.labelLarge("Cococara Pallet ID", fontWeight: 600)),
                                    SizedBox(width: 130, child: MyText.labelLarge("Pallet Height", fontWeight: 600)),
                                    SizedBox(width: 130, child: MyText.labelLarge("Net Weight", fontWeight: 600)),
                                    SizedBox(width: 130, child: MyText.labelLarge("Gross Weight", fontWeight: 600)),
                                    SizedBox(width: 130, child: MyText.labelLarge("Total Package", fontWeight: 600)),
                                    const SizedBox(width: 48),
                                  ],
                                ),
                              ),
                              ...palletData.map((data) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: contentTheme.onBackground.withAlpha(20))),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      tilePadding: MySpacing.x(16),
                                      title: Row(
                                        children: [
                                          SizedBox(width: 140, child: MyText.bodyMedium(data['shippingId'] ?? '')),
                                          SizedBox(width: 150, child: MyText.bodyMedium(data['supplier'] ?? '')),
                                          SizedBox(width: 150, child: MyText.bodyMedium(data['tempPalletId'] ?? '')),
                                          SizedBox(width: 150, child: MyText.bodyMedium(data['cococaraPalletId'] ?? '')),
                                          SizedBox(width: 130, child: MyText.bodyMedium(data['palletHeight'] ?? '')),
                                          SizedBox(width: 130, child: MyText.bodyMedium(data['netWeight'] ?? '')),
                                          SizedBox(width: 130, child: MyText.bodyMedium(data['grossWeight'] ?? '')),
                                          SizedBox(width: 130, child: MyText.bodyMedium(data['totalPackage'] ?? '')),
                                        ],
                                      ),
                                      children: [
                                        Container(
                                          padding: MySpacing.xy(16, 8),
                                          color: contentTheme.background.withAlpha(50),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Container(
                                                padding: MySpacing.xy(12, 8),
                                                color: contentTheme.primary.withAlpha(20),
                                                child: Row(
                                                  children: [
                                                    Expanded(child: MyText.bodySmall("Layer Number", fontWeight: 600)),
                                                    Expanded(child: MyText.bodySmall("Order ID", fontWeight: 600)),
                                                    Expanded(child: MyText.bodySmall("Item Code", fontWeight: 600)),
                                                    Expanded(child: MyText.bodySmall("Count of Package", fontWeight: 600)),
                                                    Expanded(child: MyText.bodySmall("Package Type", fontWeight: 600)),
                                                  ],
                                                ),
                                              ),
                                              ...(data['layerDetails'] as List<Map<String, String>>).map((layer) {
                                                return Container(
                                                  padding: MySpacing.xy(12, 6),
                                                  decoration: BoxDecoration(
                                                    border: Border(bottom: BorderSide(color: contentTheme.onBackground.withAlpha(20))),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(child: MyText.bodySmall(layer['layerNumber']?.isEmpty ?? true ? '-' : layer['layerNumber']!)),
                                                      Expanded(child: MyText.bodySmall(layer['orderId']?.isEmpty ?? true ? '-' : layer['orderId']!)),
                                                      Expanded(child: MyText.bodySmall(layer['itemCode']?.isEmpty ?? true ? '-' : layer['itemCode']!)),
                                                      Expanded(child: MyText.bodySmall(layer['countOfPackage']?.isEmpty ?? true ? '-' : layer['countOfPackage']!)),
                                                      Expanded(child: MyText.bodySmall(layer['packageType']?.isEmpty ?? true ? '-' : layer['packageType']!)),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
