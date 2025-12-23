import 'package:dongtam/data/models/planning/time_overflow_planning.dart';
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

  final TimeOverflowPlanning? timeOverflow;

  PlanningStage({
    required this.planningBoxId,
    required this.machine,
    this.dayStart,
    this.dayCompleted,
    this.timeRunning,
    this.qtyProduced,
    this.runningPlan,
    this.wasteBox,
    this.rpWasteLoss,
    this.shiftManagement,

    this.timeOverflow,
  });

  int get remainRunningPlan {
    final remain = (runningPlan ?? 0) - (qtyProduced ?? 0);
    return remain > 0 ? remain : 0;
  }

  factory PlanningStage.fromJson(Map<String, dynamic> json) {
    return PlanningStage(
      planningBoxId: json['planningBoxId'],
      dayStart:
          json['dayStart'] != null && json['dayStart'] != ''
              ? DateTime.tryParse(json['dayStart'])
              : null,
      dayCompleted:
          json['dayCompleted'] != null && json['dayCompleted'] != ''
              ? DateTime.tryParse(json['dayCompleted'])
              : null,
      timeRunning:
          json['timeRunning'] != null && json['timeRunning'] != ''
              ? parseTimeOfDay(json['timeRunning'])
              : null,
      qtyProduced: json['qtyProduced'] ?? 0,
      runningPlan: json['runningPlan'] ?? 0,
      wasteBox: toDouble(json['wasteBox']),
      rpWasteLoss: toDouble(json['rpWasteLoss']),
      machine: json['machine'] ?? "",
      shiftManagement: json['shiftManagement'] ?? "",
      timeOverflow:
          json['timeOverFlow'] != null ? TimeOverflowPlanning.fromJson(json['timeOverFlow']) : null,
    );
  }
}
