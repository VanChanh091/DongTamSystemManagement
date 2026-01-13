import 'package:dongtam/utils/helper/helper_model.dart';

class AdminFluteRatioModel {
  int? fluteRatioId;
  String fluteName;
  double ratio;

  bool isDraft;

  AdminFluteRatioModel({
    this.fluteRatioId,
    required this.fluteName,
    required this.ratio,
    this.isDraft = false,
  });

  factory AdminFluteRatioModel.fromJson(Map<String, dynamic> json) {
    return AdminFluteRatioModel(
      fluteRatioId: json['fluteRatioId'] ?? 0,
      fluteName: json['fluteName'] ?? "",
      ratio: toDouble(json['ratio']),
    );
  }

  Map<String, dynamic> toJson() {
    return {"fluteName": fluteName, "ratio": ratio};
  }
}
