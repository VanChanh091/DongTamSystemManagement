import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class QcInspectionPaperModel {
  final int inspecPaperId;
  final DateTime timeInspection;

  //user input
  final double moisture;
  final double steamPressure;
  final double preheaterTemp;
  final double fctValue;
  final double patValue;

  final Map<String, bool?> checkList;
  final String checkedBy;

  final String? note;
  final bool result;
  final String? imgError;

  //FK
  final int planningId;
  final PlanningPaperModel? paper;

  QcInspectionPaperModel({
    required this.inspecPaperId,
    required this.timeInspection,
    required this.moisture,
    required this.steamPressure,
    required this.preheaterTemp,
    required this.fctValue,
    required this.patValue,
    required this.checkList,
    required this.checkedBy,
    required this.result,
    this.note,
    this.imgError,

    //FK
    required this.planningId,
    this.paper,
  });

  factory QcInspectionPaperModel.fromJson(Map<String, dynamic> json) {
    return QcInspectionPaperModel(
      inspecPaperId: json["inspecPaperId"],
      timeInspection:
          json["timeInspection"] != null ? DateTime.parse(json["timeInspection"]) : DateTime.now(),
      moisture: toDouble(json["moisture"]),
      steamPressure: toDouble(json["steamPressure"]),
      preheaterTemp: toDouble(json["preheaterTemp"]),
      fctValue: toDouble(json["fctValue"]),
      patValue: toDouble(json["patValue"]),
      checkList:
          (json["checkList"] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as bool?)) ??
          {},
      checkedBy: json["checkedBy"] ?? "",
      note: json["note"] ?? "",
      result: json["result"] ?? false,
      imgError: json["imgError"] ?? "",

      //FK
      planningId: json["planningId"],
      paper:
          json["PlanningPaper"] != null ? PlanningPaperModel.fromJson(json["PlanningPaper"]) : null,
    );
  }
}
