import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class ReportPaperModel {
  final int? reportPaperId;
  final DateTime dayReport;
  final int qtyProduced;
  final int lackOfQty;
  final double qtyWasteNorm;
  final String shiftProduction;
  final String shiftManagement;

  final int planningId;
  final PlanningPaper? planningPaper;

  ReportPaperModel({
    this.reportPaperId,
    required this.dayReport,
    required this.qtyProduced,
    required this.lackOfQty,
    required this.qtyWasteNorm,
    required this.shiftProduction,
    required this.shiftManagement,

    required this.planningId,
    this.planningPaper,
  });

  factory ReportPaperModel.fromJson(Map<String, dynamic> json) {
    return ReportPaperModel(
      reportPaperId: json['reportPaperId'] ?? 0,
      dayReport: DateTime.parse(json['dayReport']),
      qtyProduced: json['qtyProduced'] ?? 0,
      lackOfQty: json['lackOfQty'] ?? 0,
      qtyWasteNorm: toDouble(json['qtyWasteNorm']),
      shiftProduction: json['shiftProduction'] ?? "",
      shiftManagement: json['shiftManagement'] ?? "",
      planningId: json['planningId'] ?? 0,
      planningPaper:
          json['PlanningPaper'] != null ? PlanningPaper.fromJson(json['PlanningPaper']) : null,
    );
  }
}
