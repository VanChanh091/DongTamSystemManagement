class QcSampleSubmitModel {
  final int sampleIndex;
  final Map<String, bool> checklist;

  QcSampleSubmitModel({required this.sampleIndex, required this.checklist});

  factory QcSampleSubmitModel.fromJson(Map<String, dynamic> json) {
    return QcSampleSubmitModel(
      sampleIndex: json['sampleIndex'] ?? 0,
      checklist:
          json['checklist'] is Map<String, dynamic>
              ? Map<String, bool>.from(json['checklist'])
              : const {},
    );
  }

  Map<String, dynamic> toJson() => {"sampleIndex": sampleIndex, "checklist": checklist};
}
