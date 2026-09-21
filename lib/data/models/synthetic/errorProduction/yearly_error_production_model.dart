import 'package:dongtam/utils/helper/helper_model.dart';

class ErrorStatMetric {
  int errorCount;
  double tonnage;
  double errorRate;

  ErrorStatMetric({required this.errorCount, required this.tonnage, required this.errorRate});

  factory ErrorStatMetric.fromJson(Map<String, dynamic> json) {
    return ErrorStatMetric(
      errorCount: toInt(json['errorCount']),
      tonnage: toDouble(json['tonnage']),
      errorRate: toDouble(json['errorRate']),
    );
  }
}

class YearlyErrorReportRow {
  String criteriaCode;
  String criteriaName;
  Map<int, ErrorStatMetric> monthlyMetrics; // key = 1..12
  ErrorStatMetric totalMetrics;

  YearlyErrorReportRow({
    required this.criteriaCode,
    required this.criteriaName,
    required this.monthlyMetrics,
    required this.totalMetrics,
  });

  factory YearlyErrorReportRow.fromJson(Map<String, dynamic> json) {
    return YearlyErrorReportRow(
      criteriaCode: json['criteriaCode']?.toString() ?? '',
      criteriaName: json['criteriaName']?.toString() ?? '',
      monthlyMetrics: parseIntModelMap(json['monthlyMetrics'], ErrorStatMetric.fromJson),
      totalMetrics: ErrorStatMetric.fromJson(json['totalMetrics'] ?? {}),
    );
  }
}

class YearlyErrorReportSummary {
  double totalTonnage;
  int totalErrorCount;
  double totalErrorRate;
  Map<int, ErrorStatMetric> monthlyMetrics;

  YearlyErrorReportSummary({
    required this.totalTonnage,
    required this.totalErrorCount,
    required this.totalErrorRate,
    required this.monthlyMetrics,
  });

  factory YearlyErrorReportSummary.fromJson(Map<String, dynamic> json) {
    return YearlyErrorReportSummary(
      totalTonnage: toDouble(json['totalTonnage']),
      totalErrorCount: toInt(json['totalErrorCount']),
      totalErrorRate: toDouble(json['totalErrorRate']),
      monthlyMetrics: parseIntModelMap(json['monthlyMetrics'], ErrorStatMetric.fromJson),
    );
  }
}

class YearlyErrorReport {
  YearlyErrorReportSummary summary;
  List<YearlyErrorReportRow> data;

  YearlyErrorReport({required this.summary, required this.data});

  factory YearlyErrorReport.fromJson(Map<String, dynamic> json) {
    return YearlyErrorReport(
      summary: YearlyErrorReportSummary.fromJson(json['summary'] ?? {}),
      data:
          json["data"] != null
              ? List<YearlyErrorReportRow>.from(
                json["data"].map((x) => YearlyErrorReportRow.fromJson(x)),
              )
              : [],
    );
  }
}
