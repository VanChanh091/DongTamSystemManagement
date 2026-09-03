import "package:dongtam/data/models/planning/planning_paper_model.dart";
import "package:dongtam/data/models/planning/requirements/paper_requirement_layers.dart";
import "package:dongtam/utils/helper/helper_model.dart";

class PaperRequirementModel {
  final int requirementId;
  final int paperRollWidth;
  final double totalRequiredQty;
  final String inventoryStatus;

  //FK
  final int planningId;
  final PlanningPaperModel? planningPaper;
  final List<PaperRequirementLayerModel>? layers;

  PaperRequirementModel({
    required this.requirementId,
    required this.paperRollWidth,
    required this.totalRequiredQty,
    required this.inventoryStatus,

    //FK
    required this.planningId,
    this.planningPaper,
    this.layers,
  });

  factory PaperRequirementModel.fromJson(Map<String, dynamic> json) {
    return PaperRequirementModel(
      requirementId: json["requirementId"] ?? 0,
      paperRollWidth: json["paperRollWidth"] ?? 0,
      totalRequiredQty: toDouble(json["totalRequiredQty"]),
      inventoryStatus: json["inventoryStatus"] ?? "",

      //FK
      planningId: json["planningId"] ?? 0,
      planningPaper:
          json["PlanningPaper"] != null ? PlanningPaperModel.fromJson(json["PlanningPaper"]) : null,
      layers:
          json["layers"] != null
              ? List<PaperRequirementLayerModel>.from(
                json["layers"].map((x) => PaperRequirementLayerModel.fromJson(x)),
              )
              : null,
    );
  }
}
