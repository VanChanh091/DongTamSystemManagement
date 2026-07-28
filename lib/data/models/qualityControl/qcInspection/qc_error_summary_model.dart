class QcErrorSummaryModel {
  final String key;
  final String name;
  final int count;

  QcErrorSummaryModel({required this.key, required this.name, required this.count});

  factory QcErrorSummaryModel.fromJson(Map<String, dynamic> json) {
    return QcErrorSummaryModel(
      key: json["key"] ?? "",
      name: json["name"] ?? "",
      count: json["count"] ?? 0,
    );
  }
}
