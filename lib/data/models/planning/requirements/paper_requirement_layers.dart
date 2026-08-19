import 'package:dongtam/data/models/planning/requirements/paper_requirement_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class PaperRequirementLayerModel {
  final int layerId;
  final int layerIndex;
  final String layerRole;
  final String paperCode;
  final int weightGsm;
  final String? fluteType;
  final int paperRollWidth;
  final double availableStock;
  final double shortageQty;
  final bool isEnoughQty;

  //FK
  final int requirementId;
  final PaperRequirementModel? requirements;

  PaperRequirementLayerModel({
    required this.layerId,
    required this.layerIndex,
    required this.layerRole,
    required this.paperCode,
    required this.weightGsm,
    required this.paperRollWidth,
    required this.availableStock,
    required this.shortageQty,
    required this.isEnoughQty,
    this.fluteType,

    required this.requirementId,
    required this.requirements,
  });

  factory PaperRequirementLayerModel.fromJson(Map<String, dynamic> json) {
    return PaperRequirementLayerModel(
      layerId: json["layerId"] ?? 0,
      layerIndex: json["layerIndex"] ?? 0,
      layerRole: json["layerRole"] ?? "",
      paperCode: json["paperCode"] ?? "",
      weightGsm: json["weightGsm"] ?? 0,
      fluteType: json["fluteType"] ?? '',
      paperRollWidth: json["paperRollWidth"] ?? 0,
      availableStock: toDouble(json["availableStock"]),
      shortageQty: toDouble(json["shortageQty"]),
      isEnoughQty: json["isEnoughQty"] ?? false,

      //FK
      requirementId: json["requirementId"] ?? 0,
      requirements:
          json["requirements"] != null
              ? PaperRequirementModel.fromJson(json["requirements"])
              : null,
    );
  }
}
