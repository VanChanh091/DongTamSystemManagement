import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class BoxMachineTime {
  final int boxTimeId, runningPlan;
  final TimeOfDay? timeRunning;
  final DateTime? dayCompleted, dayStart;
  final double? wasteBox, rpWasteLoss;
  final int? qtyProduced;
  final String machine;
  final String? shiftManagement;
  final String status;
  final int? sortPlanning;

  BoxMachineTime({
    required this.boxTimeId,
    required this.runningPlan,
    this.timeRunning,
    this.dayStart,
    this.dayCompleted,
    this.wasteBox,
    this.rpWasteLoss,
    this.qtyProduced,
    required this.machine,
    this.shiftManagement,
    required this.status,
    this.sortPlanning,
  });

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  factory BoxMachineTime.fromJson(Map<String, dynamic> json) {
    return BoxMachineTime(
      boxTimeId: json['boxTimeId'],
      runningPlan: json['runningPlan'] ?? 0,
      timeRunning:
          json['timeRunning'] != null && json['timeRunning'] != ''
              ? parseTimeOfDay(json['timeRunning'])
              : null,
      dayStart:
          json['dayStart'] != null && json['dayStart'] != ''
              ? DateTime.tryParse(json['dayStart'])
              : null,
      dayCompleted:
          json['dayCompleted'] != null && json['dayCompleted'] != ''
              ? DateTime.tryParse(json['dayCompleted'])
              : null,
      wasteBox: toDouble(json['wasteBox']),
      rpWasteLoss: toDouble(json['rpWasteLoss']),
      qtyProduced: json['qtyProduced'] ?? 0,
      machine: json['machine'] ?? "",
      shiftManagement: json['shiftManagement'] ?? "",
      status: json['status'] ?? "",
      sortPlanning: json['sortPlanning'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "dayStart": dayStart,
      "dayCompleted": dayCompleted,
      "wasteBox": wasteBox,
      "qtyProduced": qtyProduced,
      "shiftManagement": shiftManagement,
      "rpWasteLoss": rpWasteLoss,
    };
  }
}
