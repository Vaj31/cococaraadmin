import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ccpladmin/services/purchase_order_service.dart';
import 'package:ccpladmin/services/shipping_schedule_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class AnalyticsState {
  final bool isLoading;
  final int totalPOs;
  final int pendingChecklists;
  final double totalOrderVolume;
  final int totalShipments;
  final int ongoingProduction;
  final int completedProduction;
  final int upcomingCutoffs;
  final List<ChartSampleData> productionStatusChart;
  final List<ChartSampleData> linerDistributionChart;
  final List<ChartSampleData> monthlyOrderTrendChart;

  AnalyticsState({
    this.isLoading = true,
    this.totalPOs = 0,
    this.pendingChecklists = 0,
    this.totalOrderVolume = 0.0,
    this.totalShipments = 0,
    this.ongoingProduction = 0,
    this.completedProduction = 0,
    this.upcomingCutoffs = 0,
    this.productionStatusChart = const [],
    this.linerDistributionChart = const [],
    this.monthlyOrderTrendChart = const [],
  });

  AnalyticsState copyWith({
    bool? isLoading,
    int? totalPOs,
    int? pendingChecklists,
    double? totalOrderVolume,
    int? totalShipments,
    int? ongoingProduction,
    int? completedProduction,
    int? upcomingCutoffs,
    List<ChartSampleData>? productionStatusChart,
    List<ChartSampleData>? linerDistributionChart,
    List<ChartSampleData>? monthlyOrderTrendChart,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      totalPOs: totalPOs ?? this.totalPOs,
      pendingChecklists: pendingChecklists ?? this.pendingChecklists,
      totalOrderVolume: totalOrderVolume ?? this.totalOrderVolume,
      totalShipments: totalShipments ?? this.totalShipments,
      ongoingProduction: ongoingProduction ?? this.ongoingProduction,
      completedProduction: completedProduction ?? this.completedProduction,
      upcomingCutoffs: upcomingCutoffs ?? this.upcomingCutoffs,
      productionStatusChart: productionStatusChart ?? this.productionStatusChart,
      linerDistributionChart: linerDistributionChart ?? this.linerDistributionChart,
      monthlyOrderTrendChart: monthlyOrderTrendChart ?? this.monthlyOrderTrendChart,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final _poService = PurchaseOrderService();
  final _shippingService = ShippingScheduleService();

  AnalyticsNotifier() : super(AnalyticsState()) {
    refreshData();
  }

  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true);
    try {
      final posFuture = _poService.getPurchaseOrders();
      final schedulesFuture = _shippingService.getAll();

      final results = await Future.wait([posFuture, schedulesFuture]);
      final List<dynamic> pos = results[0];
      final List<dynamic> schedules = results[1];

      // 1. Calculate PO stats
      int pendingCheck = 0;
      double totalVolume = 0.0;
      Map<String, double> monthlyOrderQty = {};

      for (var po in pos) {
        // Check if excess configured
        final excessStr = po['excess']?.toString() ?? '';
        if (excessStr.trim().isEmpty) {
          pendingCheck++;
        }

        // Qty
        final qtyStr = po['qty']?.toString() ?? po['QTY']?.toString() ?? '0';
        final qtyVal = double.tryParse(qtyStr) ?? 0.0;
        totalVolume += qtyVal;

        // Monthly Trend
        final orderDateStr = po['orderDate']?.toString() ?? po['orderdate']?.toString() ?? '';
        if (orderDateStr.isNotEmpty) {
          final date = _parseCustomDate(orderDateStr);
          if (date != null) {
            String monthKey = DateFormat('MMM yyyy').format(date);
            monthlyOrderQty[monthKey] = (monthlyOrderQty[monthKey] ?? 0.0) + qtyVal;
          }
        }
      }

      debugPrint("Processed POs. Pending Checklists: $pendingCheck. Total Volume: $totalVolume. Monthly Groups: ${monthlyOrderQty.keys}");

      // 2. Calculate Shipping/Production stats
      int ongoingProd = 0;
      int completedProd = 0;
      int upcomingCut = 0;
      Map<String, int> productionStatusCounts = {};
      Map<String, int> linerCounts = {};

      final now = DateTime.now();

      for (var s in schedules) {
        final prodStatus = (s['productionStatus'] ?? s['productionstatus'] ?? 'planned').toString().toLowerCase().trim();
        if (prodStatus == 'on going') {
          ongoingProd++;
        } else if (prodStatus == 'completed') {
          completedProd++;
        }

        if (prodStatus.isNotEmpty) {
          productionStatusCounts[prodStatus] = (productionStatusCounts[prodStatus] ?? 0) + 1;
        }

        // Upcoming Cutoff check (within next 7 days)
        final cutoffStr = s['cutoff']?.toString() ?? '';
        if (cutoffStr.isNotEmpty) {
          final cutoffDate = _parseCustomDate(cutoffStr);
          if (cutoffDate != null) {
            final difference = cutoffDate.difference(now).inDays;
            if (difference >= 0 && difference <= 7) {
              upcomingCut++;
            }
          }
        }

        // Liner distribution
        final linerStr = (s['liner'] ?? 'Unknown').toString().trim();
        if (linerStr.isNotEmpty) {
          linerCounts[linerStr] = (linerCounts[linerStr] ?? 0) + 1;
        }
      }

      // Format Chart Data
      List<ChartSampleData> prodStatusData = [];
      productionStatusCounts.forEach((status, count) {
        String formattedStatus = status.split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
        prodStatusData.add(ChartSampleData(x: formattedStatus, y: count));
      });

      List<ChartSampleData> linerData = [];
      linerCounts.forEach((liner, count) {
        linerData.add(ChartSampleData(x: liner, y: count));
      });

      // Sort monthly keys chronologically if possible
      List<ChartSampleData> monthlyData = [];
      var sortedKeys = monthlyOrderQty.keys.toList();
      try {
        sortedKeys.sort((a, b) {
          DateTime dateA = DateFormat('MMM yyyy').parse(a);
          DateTime dateB = DateFormat('MMM yyyy').parse(b);
          return dateA.compareTo(dateB);
        });
      } catch (_) {}

      for (var key in sortedKeys) {
        monthlyData.add(ChartSampleData(x: key, y: monthlyOrderQty[key]));
      }

      state = state.copyWith(
        isLoading: false,
        totalPOs: pos.length,
        pendingChecklists: pendingCheck,
        totalOrderVolume: totalVolume,
        totalShipments: schedules.length,
        ongoingProduction: ongoingProd,
        completedProduction: completedProd,
        upcomingCutoffs: upcomingCut,
        productionStatusChart: prodStatusData,
        linerDistributionChart: linerData,
        monthlyOrderTrendChart: monthlyData,
      );
      debugPrint("Dashboard data updated successfully: POs=${state.totalPOs}, Shipments=${state.totalShipments}, MonthlyCharts=${state.monthlyOrderTrendChart.length}, StatusCharts=${state.productionStatusChart.length}");
    } catch (e, stackTrace) {
      state = state.copyWith(isLoading: false);
      debugPrint("Error loading dashboard analytics: $e");
      debugPrint("Stacktrace: $stackTrace");
    }
  }

  DateTime? _parseCustomDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } catch (_) {}
    }
    return null;
  }

  final TooltipBehavior chartTooltip = TooltipBehavior(
      enable: true,
      format: 'point.x : point.y',
      tooltipPosition: TooltipPosition.pointer);
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});

class ChartSampleData {
  ChartSampleData({
    required this.x,
    required this.y,
  });

  final dynamic x;
  final num? y;
}
