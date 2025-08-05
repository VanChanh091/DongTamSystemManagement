import 'package:dongtam/utils/helper/helper_model.dart';

class AdminWasteBoxModel {
  int wasteBoxId;
  int? colorNumberOnProduct;
  int? paperNumberOnProduct;
  double totalLossOnTotalQty;
  String machineName;

  AdminWasteBoxModel({
    required this.wasteBoxId,
    this.colorNumberOnProduct,
    this.paperNumberOnProduct,
    required this.totalLossOnTotalQty,
    required this.machineName,
  });

  factory AdminWasteBoxModel.fromJson(Map<String, dynamic> json) {
    return AdminWasteBoxModel(
      wasteBoxId: json['wasteBoxId'],
      colorNumberOnProduct: json['colorNumberOnProduct'] ?? 0,
      paperNumberOnProduct: json['paperNumberOnProduct'] ?? 0,
      totalLossOnTotalQty: toDouble(json['totalLossOnTotalQty']),
      machineName: json['machineName'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "colorNumberOnProduct": colorNumberOnProduct,
      "paperNumberOnProduct": paperNumberOnProduct,
      "totalLossOnTotalQty": totalLossOnTotalQty,
      "machineName": machineName,
    };
  }
}
