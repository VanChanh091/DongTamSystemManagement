import 'package:dongtam/data/models/admin/paperCode/paper_classification_model.dart';
import 'package:dongtam/data/models/admin/paperCode/paper_type_model.dart';
import 'package:dongtam/data/models/admin/paperCode/supplier_model.dart';

class SupplierPaperCodeModel {
  int supplierPaperId;
  String layerType;
  String? companyCode;

  //FK
  int supplierId;
  SupplierModel? Supplier;

  int paperTypeId;
  PaperTypeModel? PaperType;

  List<PaperClassificationModel>? classifications;

  bool isDraft;

  SupplierPaperCodeModel({
    required this.supplierPaperId,
    required this.layerType,
    this.companyCode,

    //FK
    required this.supplierId,
    required this.paperTypeId,
    this.Supplier,
    this.PaperType,
    this.classifications,

    this.isDraft = false,
  });

  factory SupplierPaperCodeModel.fromJson(Map<String, dynamic> json) {
    return SupplierPaperCodeModel(
      supplierPaperId: json["supplierPaperId"] ?? 0,
      layerType: json["layerType"] ?? "",
      companyCode: json["companyCode"] ?? "",

      //FK
      supplierId: json["supplierId"] ?? 0,
      paperTypeId: json["paperTypeId"] ?? 0,
      Supplier: json["Supplier"] != null ? SupplierModel.fromJson(json["Supplier"]) : null,
      PaperType: json["PaperType"] != null ? PaperTypeModel.fromJson(json["PaperType"]) : null,
      classifications:
          json["classifications"] != null
              ? List<PaperClassificationModel>.from(
                json["classifications"].map((x) => PaperClassificationModel.fromJson(x)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (supplierPaperId > 0) "supplierPaperId": supplierPaperId,
      "layerType": layerType,
      "supplierId": supplierId,
      "paperTypeId": paperTypeId,
    };
  }
}
