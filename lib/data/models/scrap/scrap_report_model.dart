import 'package:dongtam/utils/helper/helper_model.dart';

class ScrapReportModel {
  final int scrapId;
  // final String type;

  final double? qtyForklift;
  final double? qtyInventory;
  final double? qtyCoreTube;
  final double? qtyOther;
  final double totalQtyScrap;

  final String shiftProduction;
  final String reportedBy;
  final DateTime? reportedAt;

  ScrapReportModel({
    required this.scrapId,

    // required this.type,
    this.qtyForklift,
    this.qtyInventory,
    this.qtyCoreTube,
    this.qtyOther,

    required this.shiftProduction,
    required this.reportedBy,
    required this.reportedAt,
    required this.totalQtyScrap,
  });

  factory ScrapReportModel.fromJson(Map<String, dynamic> json) {
    return ScrapReportModel(
      scrapId: json['scrapId'] ?? 0,

      // type: json['type'] ?? "",
      qtyForklift: toDouble(json['qtyForklift']),
      qtyInventory: toDouble(json['qtyInventory']),
      qtyCoreTube: toDouble(json['qtyCoreTube']),
      qtyOther: toDouble(json['qtyOther']),
      totalQtyScrap: toDouble(json['totalQtyScrap']),

      shiftProduction: json['shiftProduction'] ?? "",
      reportedBy: json['reportedBy'] ?? "",
      reportedAt:
          json['reportedAt'] != null && json['reportedAt'].toString().isNotEmpty
              ? DateTime.tryParse(json['reportedAt'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scrapId': scrapId,

      // 'type': type,
      'qtyForklift': qtyForklift,
      'qtyInventory': qtyInventory,
      'qtyCoreTube': qtyCoreTube,
      'qtyOther': qtyOther,

      'shiftProduction': shiftProduction,
      'reportedBy': reportedBy,
      'reportedAt': reportedAt!.toIso8601String(),
    };
  }
}
