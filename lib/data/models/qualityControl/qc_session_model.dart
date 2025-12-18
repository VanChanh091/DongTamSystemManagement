import 'package:dongtam/data/models/qualityControl/qc_sample_result_model.dart';

class QcSessionModel {
  final int qcSessionId;
  final int totalSample;
  final String processType;
  final String checkedBy;
  final String status;

  //FK
  final int planningId;
  final int planningBoxId;

  final QcSampleResultModel? samples;

  QcSessionModel({
    required this.qcSessionId,
    required this.processType,
    required this.totalSample,
    required this.checkedBy,
    required this.status,
    required this.planningId,
    required this.planningBoxId,

    required this.samples,
  });

  factory QcSessionModel.fromJson(Map<String, dynamic> json) {
    return QcSessionModel(
      qcSessionId: json['qcSessionId'] ?? 0,
      totalSample: json['totalSample'] ?? 0,
      processType: json['processType'] ?? "",
      checkedBy: json['checkedBy'] ?? "",
      status: json['status'] ?? "",

      //FK
      planningId: json['planningId'] ?? 0,
      planningBoxId: json['planningBoxId'] ?? 0,
      samples: json['samples'] != null ? QcSampleResultModel.fromJson(json['samples']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "processType": processType,
      "totalSample": totalSample,
      "planningId": planningId,
      "planningBoxId": planningBoxId,
    };
  }
}
