class InspectionUiModel {
  final String criteriaCode;
  final String criteriaName;
  final double variance;
  final String? machine;
  final bool? isRequired;

  InspectionUiModel({
    required this.criteriaCode,
    required this.criteriaName,
    required this.variance,
    this.machine,
    this.isRequired,
  });

  // Trong class InspectionUiModel
  String get displayVariance {
    if (variance <= 0 && criteriaCode != "WARPPAGE") return "—";
    final unit = criteriaCode == "WARPPAGE" ? "cm" : "mm";
    return "±$variance $unit";
  }
}
