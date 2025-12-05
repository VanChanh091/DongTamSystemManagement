import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';

class InboundHistory {
  final int inboundId;
  final DateTime dateInbound;
  final int inboundQty;

  //FK
  final int? planningId;
  final int? planningBoxId;

  final PlanningPaper? planningPaper;
  final PlanningBox? planningBox;

  InboundHistory({
    required this.inboundId,
    required this.dateInbound,
    required this.inboundQty,

    required this.planningId,
    required this.planningBoxId,
    this.planningPaper,
    this.planningBox,
  });

  factory InboundHistory.fromJson(Map<String, dynamic> json) {
    return InboundHistory(
      inboundId: json['inboundId'],
      dateInbound: DateTime.parse(json['dateInbound']),
      inboundQty: json['inboundQty'] ?? 0,

      planningId: json['planningId'] ?? 0,
      planningBoxId: json['planningBoxId'] ?? 0,

      planningPaper:
          json['PlanningPaper'] != null ? PlanningPaper.fromJson(json['PlanningPaper']) : null,
      planningBox: json['PlanningBox'] != null ? PlanningBox.fromJson(json['PlanningBox']) : null,
    );
  }
}
