class QcSampleResultModel {
  final int qcResultId;
  final int sampleIndex;
  final Map<String, bool> checklist;
  final bool hasFail;

  //FK
  final int qcSessionId;

  QcSampleResultModel({
    required this.qcResultId,
    required this.sampleIndex,
    required this.checklist,
    required this.hasFail,

    //FK
    required this.qcSessionId,
  });

  factory QcSampleResultModel.fromJson(Map<String, dynamic> json) {
    return QcSampleResultModel(
      qcResultId: json['qcResultId'],
      sampleIndex: json['sampleIndex'],
      checklist: Map<String, bool>.from(json['checklist']),
      hasFail: json['hasFail'],

      //FK
      qcSessionId: json['qcSessionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"checklist": checklist, "qcSessionId": qcSessionId};
  }
}
