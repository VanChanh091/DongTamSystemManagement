import 'package:dongtam/data/models/planning/box_machine_time.dart';

class QcInspectionBoxModel {
  final int inspecBoxId;
  final DateTime timeInspection;
  final Map<String, bool> checkList;
  final String checkedBy;

  //FK
  final int boxTimeId;
  final BoxMachineTime? boxTime;

  QcInspectionBoxModel({
    required this.inspecBoxId,
    required this.timeInspection,
    required this.checkList,
    required this.checkedBy,
    required this.boxTimeId,
    this.boxTime,
  });

  factory QcInspectionBoxModel.fromJson(Map<String, dynamic> json) {
    return QcInspectionBoxModel(
      inspecBoxId: json["inspecBoxId"],
      timeInspection:
          json["timeInspection"] != null ? DateTime.parse(json["timeInspection"]) : DateTime.now(),
      checkList: Map<String, bool>.from(json["checkList"] ?? {}),
      checkedBy: json["checkedBy"] ?? "",

      //FK
      boxTimeId: json["boxTimeId"],
      boxTime:
          json["PlanningBoxTime"] != null ? BoxMachineTime.fromJson(json["PlanningBoxTime"]) : null,
    );
  }
}
