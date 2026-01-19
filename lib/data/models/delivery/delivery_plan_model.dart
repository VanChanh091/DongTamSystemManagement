import 'package:dongtam/data/models/delivery/delivery_item_model.dart';
import 'package:intl/intl.dart';

class DeliveryPlanModel {
  final int deliveryId;
  final DateTime? deliveryDate;
  final String status;

  final List<DeliveryItemModel>? deliveryItems;

  DeliveryPlanModel({
    required this.deliveryId,
    required this.deliveryDate,
    required this.status,

    //ASSOCIATION
    this.deliveryItems,
  });

  factory DeliveryPlanModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPlanModel(
      deliveryId: json['deliveryId'] ?? 0,
      deliveryDate:
          json['deliveryDate'] != null && json['deliveryDate'] != ''
              ? DateTime.tryParse(json['deliveryDate'])
              : null,
      status: json['status'] ?? "",

      deliveryItems:
          json['DeliveryItems'] != null
              ? List<DeliveryItemModel>.from(
                json['DeliveryItems'].map((x) => DeliveryItemModel.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "deliveryId": deliveryId,
      "deliveryDate": deliveryDate != null ? DateFormat('yyyy-MM-dd').format(deliveryDate!) : null,
      "status": status,
    };
  }
}
