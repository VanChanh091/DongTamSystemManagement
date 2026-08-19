import "package:dongtam/data/models/planning/planning_paper_model.dart";
import "package:dongtam/data/models/planning/requirements/paper_requirement_layers.dart";

class PaperRequirementModel {
  final int requirementId;
  final int totalRequiredQty;
  final String inventoryStatus;

  //FK
  final int planningId;
  final PlanningPaperModel? planningPaper;
  final List<PaperRequirementLayerModel>? layers;

  PaperRequirementModel({
    required this.requirementId,
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
      totalRequiredQty: json["totalRequiredQty"] ?? 0,
      inventoryStatus: json["inventoryStatus"] ?? "",

      //FK
      planningId: json["planningId"] ?? 0,
      planningPaper:
          json["planningPaper"] != null ? PlanningPaperModel.fromJson(json["planningPaper"]) : null,
      layers:
          json["layers"] != null
              ? List<PaperRequirementLayerModel>.from(
                json["layers"].map((x) => PaperRequirementLayerModel.fromJson(x)),
              )
              : null,
    );
  }
}
