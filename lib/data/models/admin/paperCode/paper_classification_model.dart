import 'package:dongtam/data/models/admin/paperCode/paper_basis_weight_model.dart';
import 'package:dongtam/data/models/admin/paperCode/supplier_paper_code_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class PaperClassificationModel {
  int classificationId;
  String paperCode;
  String weightCategory;

  double? burstRatio;
  double? burstStrength;
  double? ringCrush;
  double? pricePaper;

  //FK
  int supplierPaperId;
  int basisWeightId;

  SupplierPaperCodeModel? supplierPaper;
  PaperBasisWeightModel? basisWeight;

  bool isDraft;

  PaperClassificationModel({
    required this.classificationId,
    required this.paperCode,
    required this.weightCategory,
    required this.burstRatio,
    required this.burstStrength,
    required this.ringCrush,
    required this.pricePaper,

    //FK
    required this.supplierPaperId,
    required this.basisWeightId,
    this.supplierPaper,
    this.basisWeight,

    this.isDraft = false,
  });

  factory PaperClassificationModel.fromJson(Map<String, dynamic> json) {
    return PaperClassificationModel(
      classificationId: json["classificationId"] ?? 0,
      paperCode: json["paperCode"] ?? "",
      weightCategory: json["weightCategory"] ?? "",
      burstRatio: toDouble(json["burstRatio"]),
      burstStrength: toDouble(json["burstStrength"]),
      ringCrush: toDouble(json["ringCrush"]),
      pricePaper: toDouble(json["pricePaper"]),

      //FK
      supplierPaperId: json["supplierPaperId"] ?? 0,
      basisWeightId: json["basisWeightId"] ?? 0,
      supplierPaper:
          json["supplierPaper"] != null
              ? SupplierPaperCodeModel.fromJson(json["supplierPaper"])
              : null,
      basisWeight:
          json["basisWeight"] != null ? PaperBasisWeightModel.fromJson(json["basisWeight"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (classificationId > 0) "classificationId": classificationId,
      "burstRatio": burstRatio,
      "burstStrength": burstStrength,
      "ringCrush": ringCrush,
      "pricePaper": pricePaper,
      "supplierPaperId": supplierPaperId,
      "basisWeightId": basisWeightId,
    };
  }
}
