import 'package:dongtam/utils/helper/helper_model.dart';

class AdminInspectionBoxModel {
  int? criteriaBoxId;
  String criteriaBoxCode;
  String criteriaBoxName;
  double variance;
  String machine;

  bool isDraft;

  AdminInspectionBoxModel({
    required this.criteriaBoxId,
    required this.criteriaBoxCode,
    required this.criteriaBoxName,
    required this.variance,
    required this.machine,
    this.isDraft = false,
  });

  factory AdminInspectionBoxModel.fromJson(Map<String, dynamic> json) {
    return AdminInspectionBoxModel(
      criteriaBoxId: json["criteriaBoxId"] ?? 0,
      criteriaBoxCode: json["criteriaBoxCode"] ?? "",
      criteriaBoxName: json["criteriaBoxName"] ?? "",
      variance: toDouble(json["variance"]),
      machine: json["machine"] ?? "",
    );
  }
}
