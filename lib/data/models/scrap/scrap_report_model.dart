import "package:dongtam/utils/helper/helper_model.dart";

class ScrapReportModel {
  final int scrapId;

  final double? qtyForklift;
  final double? qtyInventory;
  final double? qtyCoreTube;
  final double? qtyOther;
  final double qtyProduction;
  final double totalQtyScrap;

  final String machine;
  final String shiftProduction;

  final String reportedBy;
  final DateTime? reportedAt;
  final DateTime? dayCompleted;

  final String? rejectReason;
  final String status;

  ScrapReportModel({
    required this.scrapId,

    this.qtyForklift,
    this.qtyInventory,
    this.qtyCoreTube,
    this.qtyOther,
    required this.qtyProduction,

    required this.machine,
    required this.shiftProduction,
    required this.reportedBy,
    this.reportedAt,
    this.dayCompleted,
    required this.totalQtyScrap,
    required this.rejectReason,
    required this.status,
  });

  factory ScrapReportModel.fromJson(Map<String, dynamic> json) {
    return ScrapReportModel(
      scrapId: json["scrapId"] ?? 0,

      qtyForklift: toDouble(json["qtyForklift"]),
      qtyInventory: toDouble(json["qtyInventory"]),
      qtyCoreTube: toDouble(json["qtyCoreTube"]),
      qtyOther: toDouble(json["qtyOther"]),
      qtyProduction: toDouble(json["qtyProduction"]),
      totalQtyScrap: toDouble(json["totalQtyScrap"]),

      machine: json["machine"] ?? "",
      shiftProduction: json["shiftProduction"] ?? "",
      reportedBy: json["reportedBy"] ?? "",
      reportedAt:
          json["reportedAt"] != null && json["reportedAt"].toString().isNotEmpty
              ? DateTime.tryParse(json["reportedAt"].toString())
              : null,
      dayCompleted:
          json["dayCompleted"] != null && json["dayCompleted"].toString().isNotEmpty
              ? DateTime.tryParse(json["dayCompleted"].toString())
              : null,
      rejectReason: json["rejectReason"] ?? "",
      status: json["status"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "scrapId": scrapId,

      // "type": type,
      "qtyForklift": qtyForklift,
      "qtyInventory": qtyInventory,
      "qtyCoreTube": qtyCoreTube,
      "qtyOther": qtyOther,

      "shiftProduction": shiftProduction,
      "reportedBy": reportedBy,
      "reportedAt": reportedAt!.toIso8601String(),
    };
  }
}
