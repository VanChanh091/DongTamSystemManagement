import 'package:dongtam/utils/helper/helper_model.dart';

class MonthlyRevenueReport {
  final String date; // YYYY-MM-DD
  final int orderApprovedAmount; // DS nhận đơn
  final int productionAmount; // DS sản xuất
  final int salesAmount; // DS bán hàng
  final int returnAmount; // DS trả về

  MonthlyRevenueReport({
    required this.date,
    required this.orderApprovedAmount,
    required this.productionAmount,
    required this.salesAmount,
    required this.returnAmount,
  });

  factory MonthlyRevenueReport.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueReport(
      date: json['date']?.toString() ?? '',
      orderApprovedAmount: toInt(json['orderApprovedAmount']),
      productionAmount: toInt(json['productionAmount']),
      salesAmount: toInt(json['salesAmount']),
      returnAmount: toInt(json['returnAmount']),
    );
  }
}

class MonthlyRevenueSummary {
  final int totalOrderApproved;
  final int totalProduction;
  final int totalSales;
  final int totalReturn;

  MonthlyRevenueSummary({
    required this.totalOrderApproved,
    required this.totalProduction,
    required this.totalSales,
    required this.totalReturn,
  });

  factory MonthlyRevenueSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueSummary(
      totalOrderApproved: toInt(json['totalOrderApproved']),
      totalProduction: toInt(json['totalProduction']),
      totalSales: toInt(json['totalSales']),
      totalReturn: toInt(json['totalReturn']),
    );
  }
}
