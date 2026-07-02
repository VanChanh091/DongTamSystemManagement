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
}
