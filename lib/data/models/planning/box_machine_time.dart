import "package:dongtam/data/models/planning/planning_box_model.dart";
import "package:dongtam/utils/helper/helper_model.dart";
import "package:flutter/material.dart";

class BoxMachineTimeModel {
  final int boxTimeId, runningPlan;
  final TimeOfDay? timeRunning;
  final DateTime? dayCompleted, dayStart;
  final double? wasteBox, rpWasteLoss;
  final int? qtyProduced;
  final String machine;
  final String? shiftManagement;
  final bool isRequestCheck;
  final String status, statusCheck;
  final int? sortPlanning;

  final int planningBoxId;
  final PlanningBoxModel? planningBox;

  BoxMachineTimeModel({
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
    required this.isRequestCheck,
    required this.status,
    required this.statusCheck,
    this.sortPlanning,
    required this.planningBoxId,
    this.planningBox,
  });

  int get remainRunningPlan {
    final rp = runningPlan;
    final produced = qtyProduced ?? 0;
    final remain = rp - produced;
    return remain > 0 ? remain : 0;
  }

  static String formatTimeOfDay({required TimeOfDay timeOfDay}) {
    final hour = timeOfDay.hour.toString().padLeft(2, "0");
    final minute = timeOfDay.minute.toString().padLeft(2, "0");
    return "$hour:$minute";
  }

  factory BoxMachineTimeModel.fromJson(Map<String, dynamic> json) {
    return BoxMachineTimeModel(
      boxTimeId: json["boxTimeId"] ?? 0,
      runningPlan: json["runningPlan"] ?? 0,
      timeRunning:
          json["timeRunning"] != null && json["timeRunning"] != ""
              ? parseTimeOfDay(json["timeRunning"])
              : null,
      dayStart:
          json["dayStart"] != null && json["dayStart"] != ""
              ? DateTime.tryParse(json["dayStart"])
              : null,
      dayCompleted:
          json["dayCompleted"] != null && json["dayCompleted"] != ""
              ? DateTime.tryParse(json["dayCompleted"])
              : null,
      wasteBox: toDouble(json["wasteBox"]),
      rpWasteLoss: toDouble(json["rpWasteLoss"]),
      qtyProduced: json["qtyProduced"] ?? 0,
      machine: json["machine"] ?? "",
      shiftManagement: json["shiftManagement"] ?? "",
      isRequestCheck: json["isRequestCheck"] ?? false,
      status: json["status"] ?? "",
      statusCheck: json["statusCheck"] ?? "",
      sortPlanning: json["sortPlanning"] ?? 0,

      //FK
      planningBoxId: json["planningBoxId"] ?? 0,
      planningBox:
          json["PlanningBox"] != null ? PlanningBoxModel.fromJson(json["PlanningBox"]) : null,
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
