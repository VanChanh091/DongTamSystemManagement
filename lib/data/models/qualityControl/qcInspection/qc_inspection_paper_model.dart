import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class QcInspectionPaperModel {
  final int inspecPaperId;
  final DateTime timeInspection;

  //user input
  final int? numberPallet;
  final double machineSpeed;
  final double moisture;
  final double steamPressure;
  final double preheaterTemp;
  final double fctValue;
  final double patValue;

  final Map<String, bool> checkList;
  final String checkedBy;

  final String? note;

  //FK
  final int planningId;
  final PlanningPaperModel? paper;

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
    required this.checkList,
    required this.checkedBy,
    this.note,

    //FK
    required this.planningId,
    this.paper,
  });

  factory QcInspectionPaperModel.fromJson(Map<String, dynamic> json) {
    return QcInspectionPaperModel(
      inspecPaperId: json["inspecPaperId"],
      timeInspection:
          json["timeInspection"] != null ? DateTime.parse(json["timeInspection"]) : DateTime.now(),
      numberPallet: json["numberPallet"] ?? 0,
      machineSpeed: toDouble(json["machineSpeed"]),
      moisture: toDouble(json["moisture"]),
      steamPressure: toDouble(json["steamPressure"]),
      preheaterTemp: toDouble(json["preheaterTemp"]),
      fctValue: toDouble(json["fctValue"]),
      patValue: toDouble(json["patValue"]),
      checkList: Map<String, bool>.from(json["checkList"] ?? {}),
      checkedBy: json["checkedBy"] ?? "",
      note: json["note"] ?? "",

      //FK
      planningId: json["planningId"],
      paper:
          json["PlanningPaper"] != null ? PlanningPaperModel.fromJson(json["PlanningPaper"]) : null,
    );
  }
}
