import 'package:dongtam/utils/helper/helper_model.dart';

class MonthlyErrorReportRow {
  String machine;
  String employeeName;
  Map<int, int> dailyErrors; // { 1: 0, 2: 5, ..., 31: 2 }
  int totalErrors; // Tổng số lỗi trong tháng

  MonthlyErrorReportRow({
    required this.machine,
    required this.employeeName,
    required this.dailyErrors,
    required this.totalErrors,
  });

  factory MonthlyErrorReportRow.fromJson(Map<String, dynamic> json) {
    return MonthlyErrorReportRow(
      machine: json['machine']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      dailyErrors: parseIntIntMap(json['dailyErrors']),
      totalErrors: toInt(json['totalErrors']),
    );
  }
}

class MonthlyErrorReportSummary {
  int totalError;
  Map<int, int> dailyTotals;

  MonthlyErrorReportSummary({required this.totalError, required this.dailyTotals});

  factory MonthlyErrorReportSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyErrorReportSummary(
      totalError: toInt(json['totalError']),
      dailyTotals: parseIntIntMap(json['dailyTotals']),
    );
  }
}

class MonthlyErrorReport {
  int daysInMonth;
  MonthlyErrorReportSummary summary;
  List<MonthlyErrorReportRow> data;

  MonthlyErrorReport({required this.daysInMonth, required this.data, required this.summary});

  factory MonthlyErrorReport.fromJson(Map<String, dynamic> json) {
    return MonthlyErrorReport(
      daysInMonth: toInt(json['daysInMonth']),
      summary: MonthlyErrorReportSummary.fromJson(json['summary'] ?? {}),
      data:
          json["data"] != null
              ? List<MonthlyErrorReportRow>.from(
                json["data"].map((x) => MonthlyErrorReportRow.fromJson(x)),
              )
              : [],
    );
  }
}
