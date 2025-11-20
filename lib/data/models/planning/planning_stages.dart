import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class PlanningStage {
  final int planningBoxId;
  final DateTime? dayStart;
  final DateTime? dayCompleted;
  final TimeOfDay? timeRunning;
  final int? qtyProduced;
  final int? runningPlan;
  final double? wasteBox;
  final double? rpWasteLoss;
  final String machine;
  final String? shiftManagement;

  PlanningStage({
    this.dayStart,
    this.dayCompleted,
    this.timeRunning,
    this.qtyProduced,
    this.runningPlan,
    this.wasteBox,
    this.rpWasteLoss,
    required this.machine,
    this.shiftManagement,
    required this.planningBoxId,
  });

  factory PlanningStage.fromJson(Map<String, dynamic> json) {
    return PlanningStage(
      dayStart: json['dayStart'] != null ? DateTime.tryParse(json['dayStart']) : null,
      dayCompleted: json['dayCompleted'] != null ? DateTime.tryParse(json['dayCompleted']) : null,
      qtyProduced: json['qtyProduced'] ?? 0,
      runningPlan: json['runningPlan'] ?? 0,
      wasteBox: json['wasteBox'] != null ? toDouble(json['wasteBox']) : null,
      rpWasteLoss: json['rpWasteLoss'] != null ? toDouble(json['rpWasteLoss']) : null,
      machine: json['machine'] ?? "",
      shiftManagement: json['shiftManagement'] ?? "",
      planningBoxId: json['planningBoxId'],
    );
  }
}
