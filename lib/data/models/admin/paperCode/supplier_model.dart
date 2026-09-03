import 'package:dongtam/data/models/admin/paperCode/supplier_paper_code_model.dart';

class SupplierModel {
  int? supplierId;
  String supplierName;
  String supplierCode;
  String transferCode;
  bool? isActive;

  //association
  List<SupplierPaperCodeModel>? supplierPapers;

  bool isDraft;

  SupplierModel({
    this.supplierId,
    required this.supplierName,
    required this.supplierCode,
    required this.transferCode,
    this.isActive,
    this.supplierPapers,

    this.isDraft = false,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      supplierId: json["supplierId"] ?? 0,
      supplierName: json["supplierName"] ?? "",
      supplierCode: json["supplierCode"] ?? "",
      transferCode: json["transferCode"] ?? "",
      isActive: json["isActive"] ?? false,
      supplierPapers:
          json["supplierPapers"] != null
              ? List<SupplierPaperCodeModel>.from(
                json["supplierPapers"].map((x) => SupplierPaperCodeModel.fromJson(x)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "supplierName": supplierName,
      "supplierCode": supplierCode,
      "transferCode": transferCode,
    };
  }
}
