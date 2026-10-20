import 'package:dongtam/utils/helper/helper_model.dart';

class ProductionReportModel {
  final String dimensionKey;
  final double totalPaperTon;
  final double totalLength;
  final double totalScrapKg;
  final double scrapRate;
  final double averageSpeed;
  final double totalRevenue;
  final double? fulfillmentRate;
  final double? timeAdherenceRate;
  final int totalQcErrors;
  final double qcErrorPerTon;

  ProductionReportModel({
    required this.dimensionKey,
    required this.totalPaperTon,
    required this.totalLength,
    required this.totalScrapKg,
    required this.scrapRate,
    required this.averageSpeed,
    required this.totalRevenue,
    this.fulfillmentRate,
    this.timeAdherenceRate,
    required this.totalQcErrors,
    required this.qcErrorPerTon,
  });

  factory ProductionReportModel.fromJson(Map<String, dynamic> json) {
    return ProductionReportModel(
      dimensionKey: json['dimensionKey']?.toString() ?? '',
      totalPaperTon: toDouble(json['totalPaperTon']),
      totalLength: toDouble(json['totalLength']),
      totalScrapKg: toDouble(json['totalScrapKg']),
      scrapRate: toDouble(json['scrapRate']),
      averageSpeed: toDouble(json['averageSpeed']),
      totalRevenue: toDouble(json['totalRevenue']),
      fulfillmentRate: json['fulfillmentRate'] != null ? toDouble(json['fulfillmentRate']) : null,
      timeAdherenceRate:
          json['timeAdherenceRate'] != null ? toDouble(json['timeAdherenceRate']) : null,
      totalQcErrors: toInt(json['totalQcErrors']),
      qcErrorPerTon: toDouble(json['qcErrorPerTon']),
    );
  }
}

class ProductionCombinedReportModel {
  final List<ProductionReportModel> machines;
  final List<ProductionReportModel> workers;

  ProductionCombinedReportModel({
    required this.machines,
    required this.workers,
  });

  factory ProductionCombinedReportModel.fromJson(Map<String, dynamic> json) {
    return ProductionCombinedReportModel(
      machines: (json['machines'] as List<dynamic>? ?? [])
          .map((e) => ProductionReportModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      workers: (json['workers'] as List<dynamic>? ?? [])
          .map((e) => ProductionReportModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
