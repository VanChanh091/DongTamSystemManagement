import 'package:dongtam/utils/helper/helper_model.dart';

class CustomerDailyRevenueRow {
  final String customerId;
  final String customerName;
  final Map<int, double> dailyAmounts; // { 1: 500000.0, 2: 0.0, ..., 31: 1200000.0 }
  final double totalCustomerSales; // Tổng cả tháng của riêng khách này
  final double totalCustomerDebt; // Dư nợ còn lại của các đơn trong tháng

  CustomerDailyRevenueRow({
    required this.customerId,
    required this.customerName,
    required this.dailyAmounts,
    required this.totalCustomerSales,
    required this.totalCustomerDebt,
  });

  factory CustomerDailyRevenueRow.fromJson(Map<String, dynamic> json) {
    // Parse key dạng String ("1", "2") thành int (1, 2)
    final rawDaily = json['dailyAmounts'] as Map<String, dynamic>? ?? {};
    final Map<int, double> parsedDaily = {};

    rawDaily.forEach((key, value) {
      final day = int.tryParse(key);
      if (day != null) {
        parsedDaily[day] = toDouble(value);
      }
    });

    return CustomerDailyRevenueRow(
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      dailyAmounts: parsedDaily,
      totalCustomerSales: toDouble(json['totalCustomerSales']),
      totalCustomerDebt: toDouble(json['totalCustomerDebt']),
    );
  }
}

class DailyRevenueSummary {
  final double totalMonthSales;
  final double totalMonthDebt;
  final Map<int, double> dailyTotals;

  DailyRevenueSummary({
    required this.totalMonthSales,
    required this.totalMonthDebt,
    required this.dailyTotals,
  });

  factory DailyRevenueSummary.fromJson(Map<String, dynamic> json) {
    final rawDaily = json['dailyTotals'] as Map<String, dynamic>? ?? {};
    final Map<int, double> parsedDaily = {};
    rawDaily.forEach((key, value) {
      final day = int.tryParse(key);
      if (day != null) {
        parsedDaily[day] = toDouble(value);
      }
    });

    return DailyRevenueSummary(
      totalMonthSales: toDouble(json['totalMonthSales']),
      totalMonthDebt: toDouble(json['totalMonthDebt']),
      dailyTotals: parsedDaily,
    );
  }
}
