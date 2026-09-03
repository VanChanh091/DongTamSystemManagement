import 'package:dongtam/data/models/admin/paperCode/paper_classification_model.dart';

class PaperBasisWeightModel {
  int? basisWeightId;
  int basisWeight;
  String? weightCode;

  //association
  List<PaperClassificationModel>? classifications;

  bool isDraft;

  PaperBasisWeightModel({
    this.basisWeightId,
    required this.basisWeight,
    this.weightCode,
    this.classifications,

    this.isDraft = false,
  });

  factory PaperBasisWeightModel.fromJson(Map<String, dynamic> json) {
    return PaperBasisWeightModel(
      basisWeightId: json["basisWeightId"] ?? 0,
      basisWeight: json["basisWeight"] ?? 0,
      weightCode: json["weightCode"] ?? "",
      classifications:
          json["classifications"] != null
              ? List<PaperClassificationModel>.from(
                json["classifications"].map((x) => PaperClassificationModel.fromJson(x)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"basisWeight": basisWeight, "weightCode": weightCode};
  }
}
