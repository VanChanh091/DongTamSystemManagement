import 'package:dongtam/utils/helper/helper_model.dart';

class AdminPaperFactorModel {
  final int paperFactorId;
  final String layerType;
  final String paperType;
  final double? rollLossPercent;
  final double? processLossPercent;
  final int? coefficient;

  AdminPaperFactorModel({
    required this.paperFactorId,
    required this.layerType,
    required this.paperType,
    this.rollLossPercent,
    this.processLossPercent,
    this.coefficient,
  });

  factory AdminPaperFactorModel.fromJson(Map<String, dynamic> json) {
    return AdminPaperFactorModel(
      paperFactorId: json['paperFactorId'],
      layerType: json['layerType'] ?? "",
      paperType: json['paperType'] ?? "",
      rollLossPercent: toDouble(json['rollLossPercent']),
      processLossPercent: toDouble(json['processLossPercent']),
      coefficient: json['coefficient'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layerType': layerType,
      'paperType': paperType,
      'rollLossPercent': rollLossPercent,
      'processLossPercent': processLossPercent,
      'coefficient': coefficient,
    };
  }
}
