import 'package:dongtam/data/models/admin/paperCode/supplier_paper_code_model.dart';

class PaperTypeModel {
  int? paperTypeId;
  String paperName;
  String paperCode;
  int grade;

  //association
  List<SupplierPaperCodeModel>? supplierPapers;

  bool isDraft;

  PaperTypeModel({
    this.paperTypeId,
    required this.paperName,
    required this.paperCode,
    required this.grade,
    this.supplierPapers,

    this.isDraft = false,
  });

  factory PaperTypeModel.fromJson(Map<String, dynamic> json) {
    return PaperTypeModel(
      paperTypeId: json["paperTypeId"] ?? 0,
      paperName: json["paperName"] ?? "",
      paperCode: json["paperCode"] ?? "",
      grade: json["grade"] ?? 0,
      supplierPapers:
          json["supplierPapers"] != null
              ? List<SupplierPaperCodeModel>.from(
                json["supplierPapers"].map((x) => SupplierPaperCodeModel.fromJson(x)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"paperName": paperName, "paperCode": paperCode, "grade": grade};
  }
}
