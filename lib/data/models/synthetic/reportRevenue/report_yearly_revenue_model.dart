import 'package:dongtam/utils/helper/helper_model.dart';

class YearRevenueData {
  final Map<int, int> months; // { 1: 0, 2: 50000000, ..., 12: 12000000 }
  final int yearTotal; // Tổng cả năm đó

  YearRevenueData({required this.months, required this.yearTotal});

  factory YearRevenueData.fromJson(Map<String, dynamic> json) {
    final rawMonths = json['months'] as Map<String, dynamic>? ?? {};
    final Map<int, int> parsedMonths = {};
    rawMonths.forEach((key, value) {
      final month = int.tryParse(key);
      if (month != null) {
        parsedMonths[month] = toInt(value);
      }
    });

    return YearRevenueData(months: parsedMonths, yearTotal: toInt(json['yearTotal']));
  }
}

// Model for each customer in the yearly revenue report
class CustomerYearRevenue {
  final String customerId;
  final String customerName;
  final int currentDebt;
  final Map<int, YearRevenueData> years; // { 2024: YearRevenueData, 2025: YearRevenueData }
  final int grandTotal; // Tổng tất cả các năm cộng lại

  CustomerYearRevenue({
    required this.customerId,
    required this.customerName,
    required this.currentDebt,
    required this.years,
    required this.grandTotal,
  });

  factory CustomerYearRevenue.fromJson(Map<String, dynamic> json) {
    final rawYears = json['years'] as Map<String, dynamic>? ?? {};
    final Map<int, YearRevenueData> parsedYears = {};

    rawYears.forEach((key, value) {
      final year = int.tryParse(key);
      if (year != null && value is Map<String, dynamic>) {
        parsedYears[year] = YearRevenueData.fromJson(value);
      }
    });

    return CustomerYearRevenue(
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      currentDebt: toInt(json['currentDebt']),
      years: parsedYears,
      grandTotal: toInt(json['grandTotal']),
    );
  }
}

class MultiYearSummary {
  final Map<int, YearRevenueData> years; // Tổng cộng tất cả ds
  final int grandTotal;
  final int totalCurrentDebt;

  MultiYearSummary({required this.years, required this.grandTotal, required this.totalCurrentDebt});

  factory MultiYearSummary.fromJson(Map<String, dynamic> json) {
    final rawYears = json['years'] as Map<String, dynamic>? ?? {};
    final Map<int, YearRevenueData> parsedYears = {};

    rawYears.forEach((key, value) {
      final year = int.tryParse(key);
      if (year != null && value is Map<String, dynamic>) {
        parsedYears[year] = YearRevenueData.fromJson(value);
      }
    });

    return MultiYearSummary(
      years: parsedYears,
      grandTotal: toInt(json['grandTotal']),
      totalCurrentDebt: toInt(json['totalCurrentDebt']),
    );
  }
}
