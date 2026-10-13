import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class InspectionRequestModel {
  final int inspectionId;
  final DateTime? requestedAt;
  final String requestedBy;
  final DateTime? arrivedAt;
  final String? completedBy;
  final String status;
  final bool? result;

  //FK
  final int planningId;
  final PlanningPaperModel? PlanningPaper;

  InspectionRequestModel({
    required this.inspectionId,
    this.requestedAt,
    required this.requestedBy,
    this.arrivedAt,
    this.completedBy,
    required this.status,
    this.result,
    required this.planningId,
    this.PlanningPaper,
  });

  factory InspectionRequestModel.fromJson(Map<String, dynamic> json) {
    return InspectionRequestModel(
      inspectionId: toInt(json["inspectionId"]),
      requestedAt:
          json["requestedAt"] != null && json["requestedAt"] != ""
              ? DateTime.tryParse(json["requestedAt"].toString())
              : null,
      requestedBy: json["requestedBy"] ?? "",
      arrivedAt:
          json["arrivedAt"] != null && json["arrivedAt"] != ""
              ? DateTime.tryParse(json["arrivedAt"].toString())
              : null,
      completedBy: json["completedBy"],
      status: json["status"] ?? "pending",
      result: json["result"] as bool?,
      planningId: toInt(json["planningId"]),
      PlanningPaper:
          json["PlanningPaper"] != null ? PlanningPaperModel.fromJson(json["PlanningPaper"]) : null,
    );
  }

  bool get isPending => status == "pending";
  bool get isInProgress => status == "in_progress";
  bool get isWaiting => isPending || isInProgress;
  bool get isPassed => status == "passed";
  bool get isFailed => status == "failed";
}
