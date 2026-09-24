import 'package:dongtam/utils/helper/helper_model.dart';

class PaperRequirementGhepKhoSummary {
  final dynamic ghepKho;
  final double totalQty;
  final double totalPrice;
  final int count;

  PaperRequirementGhepKhoSummary({
    required this.ghepKho,
    required this.totalQty,
    required this.totalPrice,
    required this.count,
  });

  factory PaperRequirementGhepKhoSummary.fromJson(Map<String, dynamic> json) {
    return PaperRequirementGhepKhoSummary(
      ghepKho: json['ghepKho'] ?? '',
      totalQty: toDouble(json['totalQty']),
      totalPrice: toDouble(json['totalPrice']),
      count: toInt(json['count']),
    );
  }
}
