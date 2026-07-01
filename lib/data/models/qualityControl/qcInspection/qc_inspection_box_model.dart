import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class QcInspectionBoxModel {
  final int inspecBoxId;
  final TimeOfDay timeInspection;
  final Map<String, bool> checklist;
  final String checkedBy;

  //FK
  final int planningId;

  QcInspectionBoxModel({
    required this.inspecBoxId,
    required this.timeInspection,
    required this.checklist,
    required this.checkedBy,
    required this.planningId,
  });

  factory QcInspectionBoxModel.fromJson(Map<String, dynamic> json) {
    return QcInspectionBoxModel(
      inspecBoxId: json["inspecBoxId"],
      timeInspection:
          json["timeInspection"] != null && json["timeInspection"] != ""
              ? parseTimeOfDay(json["timeInspection"])
              : const TimeOfDay(hour: 0, minute: 0),
      checklist: Map<String, bool>.from(json["checklist"] ?? {}),
      checkedBy: json["checkedBy"] ?? "",

      //FK
      planningId: json["planningId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"checklist": checklist, "planningId": planningId};
  }
}
