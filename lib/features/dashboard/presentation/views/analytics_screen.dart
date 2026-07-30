import 'package:ccpladmin/helpers/theme/app_theme.dart';
import 'package:ccpladmin/helpers/utils/mixins/ui_mixin.dart';
import 'package:ccpladmin/helpers/utils/my_shadow.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb.dart';
import 'package:ccpladmin/helpers/widgets/my_breadcrumb_item.dart';
import 'package:ccpladmin/helpers/widgets/my_card.dart';
import 'package:ccpladmin/helpers/widgets/my_container.dart';
import 'package:ccpladmin/helpers/widgets/my_flex.dart';
import 'package:ccpladmin/helpers/widgets/my_flex_item.dart';
import 'package:ccpladmin/helpers/widgets/my_progress_bar.dart';
import 'package:ccpladmin/helpers/widgets/my_spacing.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/view/layouts/layout.dart';
import 'package:ccpladmin/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin, UIMixin {

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    if (state.isLoading) {
      return Layout(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  "Dashboard",
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Analytics'),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing),
          Padding(
            padding: MySpacing.x(flexSpacing / 2),
            child: MyFlex(children: [
              MyFlexItem(sizes: 'lg-3 md-6', child: buildTotalPOsCard(state, notifier)),
              MyFlexItem(sizes: 'lg-3 md-6', child: buildPendingChecklistsCard(state, notifier)),
              MyFlexItem(sizes: 'lg-3 md-6', child: buildTotalShipmentsCard(state, notifier)),
              MyFlexItem(sizes: 'lg-3 md-6', child: buildUpcomingCutoffsCard(state, notifier)),
              MyFlexItem(sizes: 'lg-8 md-12', child: buildMonthlyOrderIntakeChart(state, notifier)),
              MyFlexItem(sizes: 'lg-4 md-12', child: buildProductionProgressChart(state, notifier)),
              MyFlexItem(sizes: 'lg-6 md-12', child: buildLinerDistributionTable(state)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget buildPopUpMenu(AnalyticsNotifier notifier) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == "refresh") {
          notifier.refreshData();
        }
      },
      offset: const Offset(0, 20),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
            value: "refresh",
            padding: MySpacing.xy(16, 8),
            height: 10,
            child: MyText.bodySmall("Refresh Report", fontWeight: 600)),
      ],
      child: const Icon(
        LucideIcons.ellipsis_vertical,
        size: 20,
      ),
    );
  }

  Widget buildOverView(IconData icon, Color color, String title, subTitle,
      IconData tradIcon, Color tradColor, String per, AnalyticsNotifier notifier) {
    return MyCard(
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      borderRadiusAll: 8,
      paddingAll: 23,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyContainer(
                  height: 44,
                  width: 44,
                  borderRadiusAll: 8,
                  paddingAll: 0,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: color.withAlpha(36),
                  child: Icon(icon, color: color),
                ),
                MySpacing.height(12),
                MyText.bodyMedium(title, muted: true, fontWeight: 700),
                MySpacing.height(12),
                MyText.bodyLarge(subTitle, fontWeight: 600, muted: true),
                MySpacing.height(12),
                Row(
                  children: [
                    Icon(tradIcon, color: tradColor, size: 20),
                    MySpacing.width(4),
                    MyText.bodyMedium(per, fontWeight: 600),
                  ],
                )
              ],
            ),
          ),
          buildPopUpMenu(notifier)
        ],
      ),
    );
  }

  Widget buildTotalPOsCard(AnalyticsState state, AnalyticsNotifier notifier) {
    return buildOverView(
      LucideIcons.shopping_bag,
      contentTheme.primary,
      "Total Purchase Orders",
      "${state.totalPOs}",
      LucideIcons.trending_up,
      contentTheme.success,
      'Live Sync',
      notifier,
    );
  }

  Widget buildPendingChecklistsCard(AnalyticsState state, AnalyticsNotifier notifier) {
    return buildOverView(
      LucideIcons.clipboard_list,
      Colors.purpleAccent,
      "Pending Checklists",
      "${state.pendingChecklists}",
      LucideIcons.info,
      state.pendingChecklists > 0 ? contentTheme.danger : contentTheme.success,
      state.pendingChecklists > 0 ? "Requires Action" : "All Configured",
      notifier,
    );
  }

  Widget buildTotalShipmentsCard(AnalyticsState state, AnalyticsNotifier notifier) {
    return buildOverView(
      LucideIcons.ship,
      Colors.blue,
      "Total Shipments",
      "${state.totalShipments}",
      LucideIcons.trending_up,
      contentTheme.success,
      'Active Schedules',
      notifier,
    );
  }

  Widget buildUpcomingCutoffsCard(AnalyticsState state, AnalyticsNotifier notifier) {
    return buildOverView(
      LucideIcons.calendar,
      Colors.brown,
      "Upcoming Cutoffs",
      "${state.upcomingCutoffs}",
      LucideIcons.alarm_clock,
      state.upcomingCutoffs > 0 ? contentTheme.danger : contentTheme.success,
      "7-Day Window",
      notifier,
    );
  }

  Widget buildMonthlyOrderIntakeChart(AnalyticsState state, AnalyticsNotifier notifier) {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 8,
      padding: MySpacing.only(left: 23, right: 23, bottom: 20, top: 23),
      child: SizedBox(
        height: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium("Monthly Order Intake Volumes (pcs)", fontWeight: 600),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => notifier.refreshData(),
                ),
              ],
            ),
            MySpacing.height(12),
            Expanded(
              child: state.monthlyOrderTrendChart.isEmpty
                  ? Center(
                      child: MyText.bodyMedium("No synced purchase orders found", muted: true),
                    )
                  : SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0)),
                      tooltipBehavior: notifier.chartTooltip,
                      series: [
                        ColumnSeries<ChartSampleData, String>(
                          name: 'Ordered Qty',
                          color: contentTheme.primary,
                          dataSource: state.monthlyOrderTrendChart,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          xValueMapper: (ChartSampleData data, _) => data.x.toString(),
                          yValueMapper: (ChartSampleData data, _) => data.y,
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductionProgressChart(AnalyticsState state, AnalyticsNotifier notifier) {
    return MyCard(
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      borderRadiusAll: 8,
      paddingAll: 23,
      child: SizedBox(
        height: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.titleMedium("Production Status Distribution", fontWeight: 600),
            MySpacing.height(12),
            Expanded(
              child: state.productionStatusChart.isEmpty
                  ? Center(
                      child: MyText.bodyMedium("No active production runs", muted: true),
                    )
                  : SfCircularChart(
                      tooltipBehavior: notifier.chartTooltip,
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        overflowMode: LegendItemOverflowMode.wrap,
                      ),
                      series: <CircularSeries>[
                        PieSeries<ChartSampleData, String>(
                          dataSource: state.productionStatusChart,
                          xValueMapper: (ChartSampleData data, _) => data.x.toString(),
                          yValueMapper: (ChartSampleData data, _) => data.y,
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.inside,
                          ),
                        )
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildLinerDistributionTable(AnalyticsState state) {
    int totalLinerShipments = state.linerDistributionChart.fold<int>(0, (sum, data) => sum + (data.y?.toInt() ?? 0));

    Widget buildLinerRow(String liner, int count, double percentage) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: MyText.bodyMedium(liner, fontWeight: 600, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: MyText.bodyMedium("$count Shipments", fontWeight: 600),
          ),
          Expanded(
            flex: 4,
            child: MyProgressBar(
              progress: percentage,
              height: 6,
              radius: 4,
              inactiveColor: theme.dividerColor,
              activeColor: contentTheme.primary,
            ),
          ),
        ],
      );
    }

    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 8,
      paddingAll: 23,
      child: SizedBox(
        height: 380,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.titleMedium("Shipping Carrier Volumes (Liners)", fontWeight: 600),
            const Divider(height: 30),
            Row(
              children: [
                Expanded(flex: 3, child: MyText.bodyMedium("Liner / Carrier", fontWeight: 600)),
                Expanded(flex: 2, child: MyText.bodyMedium("Shipments", fontWeight: 600)),
                Expanded(flex: 4, child: MyText.bodyMedium("Share", fontWeight: 600)),
              ],
            ),
            const Divider(height: 30),
            Expanded(
              child: state.linerDistributionChart.isEmpty
                  ? Center(
                      child: MyText.bodyMedium("No shipping liner records", muted: true),
                    )
                  : ListView.separated(
                      itemCount: state.linerDistributionChart.length,
                      separatorBuilder: (context, index) => MySpacing.height(16),
                      itemBuilder: (context, index) {
                        final data = state.linerDistributionChart[index];
                        final count = data.y?.toInt() ?? 0;
                        final percent = totalLinerShipments > 0 ? count / totalLinerShipments : 0.0;
                        return buildLinerRow(data.x.toString(), count, percent);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
