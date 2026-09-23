import 'package:dongtam/data/models/planning/box_machine_time.dart';

class QcInspectionBoxModel {
  final int inspecBoxId;
  final DateTime timeInspection;
  final Map<String, bool?> checkList;
  final String checkedBy;
  final String? note;

  //FK
  final int boxTimeId;
  final BoxMachineTimeModel? boxTime;

  QcInspectionBoxModel({
    required this.inspecBoxId,
    required this.timeInspection,
    required this.checkList,
    required this.checkedBy,
    this.note,

    //FK
    required this.boxTimeId,
    this.boxTime,
  });

  factory QcInspectionBoxModel.fromJson(Map<String, dynamic> json) {
    return QcInspectionBoxModel(
      inspecBoxId: json["inspecBoxId"],
      timeInspection:
          json["timeInspection"] != null ? DateTime.parse(json["timeInspection"]) : DateTime.now(),
      checkList: (json["checkList"] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as bool?),
          ) ??
          {},
      checkedBy: json["checkedBy"] ?? "",
      note: json["note"] ?? "",

      //FK
      boxTimeId: json["boxTimeId"],
      boxTime:
          json["PlanningBoxTime"] != null
              ? BoxMachineTimeModel.fromJson(json["PlanningBoxTime"])
              : null,
    );
  }
}
