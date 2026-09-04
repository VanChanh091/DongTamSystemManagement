class PaperClassificationItem {
  final int classificationId;
  final String paperCode;
  final String layerType;
  final String supplierName;

  PaperClassificationItem({
    required this.classificationId,
    required this.paperCode,
    required this.layerType,
    required this.supplierName,
  });

  factory PaperClassificationItem.fromJson(Map<String, dynamic> json) {
    return PaperClassificationItem(
      classificationId: json['classificationId'] ?? 0,
      paperCode: json['paperCode'] ?? '',
      layerType: json['layerType'] ?? 'NONE',
      supplierName: json['supplierName'] ?? '',
    );
  }
}
