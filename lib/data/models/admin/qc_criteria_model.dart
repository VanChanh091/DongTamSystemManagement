class QcCriteriaModel {
  int? qcCriteriaId;
  String processType;
  String criteriaCode;
  String criteriaName;
  bool isRequired;

  bool isDraft;

  QcCriteriaModel({
    required this.qcCriteriaId,
    required this.processType,
    required this.criteriaCode,
    required this.criteriaName,
    required this.isRequired,
    this.isDraft = false,
  });

  factory QcCriteriaModel.fromJson(Map<String, dynamic> json) {
    return QcCriteriaModel(
      qcCriteriaId: json['qcCriteriaId'] ?? 0,
      processType: json['processType'] ?? "",
      criteriaCode: json['criteriaCode'] ?? "",
      criteriaName: json['criteriaName'] ?? "",
      isRequired: json['isRequired'] ?? false,
    );
  }
}
