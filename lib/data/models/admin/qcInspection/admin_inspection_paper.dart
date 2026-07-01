import 'package:dongtam/utils/helper/helper_model.dart';

class AdminInspectionPaperModel {
  int? criteriaPaperId;
  String criteriaPaperCode;
  String criteriaPaperName;
  bool isRequired;
  double variance;

  bool isDraft;

  AdminInspectionPaperModel({
    required this.criteriaPaperId,
    required this.criteriaPaperCode,
    required this.criteriaPaperName,
    required this.isRequired,
    required this.variance,
    this.isDraft = false,
  });

  factory AdminInspectionPaperModel.fromJson(Map<String, dynamic> json) {
    return AdminInspectionPaperModel(
      criteriaPaperId: json["criteriaPaperId"] ?? 0,
      criteriaPaperCode: json["criteriaPaperCode"] ?? "",
      criteriaPaperName: json["criteriaPaperName"] ?? "",
      isRequired: json["isRequired"] ?? false,
      variance: toDouble(json["variance"]),
    );
  }
}
