import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class ReportBoxModel {
  final int? reportBoxId;
  final DateTime dayReport;
  final int qtyProduced;
  final int lackOfQty;
  final double wasteLoss;
  final String shiftManagement;

  final int planningBoxId;
  final PlanningBox? planningBox;

  ReportBoxModel({
    this.reportBoxId,
    required this.dayReport,
    required this.qtyProduced,
    required this.lackOfQty,
    required this.wasteLoss,
    required this.shiftManagement,
    required this.planningBoxId,
    this.planningBox,
  });

  factory ReportBoxModel.fromJson(Map<String, dynamic> json) {
    return ReportBoxModel(
      reportBoxId: json['reportBoxId'] ?? 0,
      dayReport: DateTime.parse(json['dayReport']),
      qtyProduced: json['qtyProduced'] ?? 0,
      lackOfQty: json['lackOfQty'] ?? 0,
      wasteLoss: toDouble(json['wasteLoss']),
      shiftManagement: json['shiftManagement'] ?? "",
      planningBoxId: json['planningBoxId'] ?? 0,
      planningBox:
          json['PlanningBox'] != null
              ? PlanningBox.fromJson(json['PlanningBox'])
              : null,
    );
  }
}
