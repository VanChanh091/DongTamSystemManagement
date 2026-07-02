import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class QcInspectionPaperModel {
  final int inspecPaperId;
  final TimeOfDay timeInspection;

  //user input
  final int? numberPallet;
  final int machineSpeed;
  final double moisture;
  final double steamPressure;
  final double preheaterTemp;
  final double fctValue;
  final double patValue;

  final Map<String, bool> checklist;
  final String checkedBy;

  //FK
  final int planningId;

  QcInspectionPaperModel({
    required this.inspecPaperId,
    required this.timeInspection,
    this.numberPallet,
    required this.machineSpeed,
    required this.moisture,
    required this.steamPressure,
    required this.preheaterTemp,
    required this.fctValue,
    required this.patValue,
    required this.checklist,
    required this.checkedBy,

    //FK
    required this.planningId,
  });

  factory QcInspectionPaperModel.fromJson(Map<String, dynamic> json) {
    return QcInspectionPaperModel(
      inspecPaperId: json["inspecPaperId"],
      timeInspection:
          json["timeInspection"] != null && json["timeInspection"] != ""
              ? parseTimeOfDay(json["timeInspection"])
              : const TimeOfDay(hour: 0, minute: 0),
      numberPallet: json["numberPallet"] ?? 0,
      machineSpeed: json["machineSpeed"] ?? 0,
      moisture: toDouble(json["lengthPaperPlanning"]),
      steamPressure: toDouble(json["steamPressure"]),
      preheaterTemp: toDouble(json["preheaterTemp"]),
      fctValue: toDouble(json["fctValue"]),
      patValue: toDouble(json["patValue"]),
      checklist: Map<String, bool>.from(json["checklist"] ?? {}),
      checkedBy: json["checkedBy"] ?? "",

      //FK
      planningId: json["planningId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //user input
      "numberPallet": numberPallet,
      "machineSpeed": machineSpeed,
      "moisture": moisture,
      "steamPressure": steamPressure,
      "preheaterTemp": preheaterTemp,
      "fctValue": fctValue,
      "patValue": patValue,
      "checklist": checklist,
      "planningId": planningId,
    };
  }
}
