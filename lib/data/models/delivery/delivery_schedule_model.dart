import 'package:dongtam/data/models/delivery/delivery_item_model.dart';
import 'package:intl/intl.dart';

class DeliveryScheduleModel {
  final int deliveryId;
  final DateTime? deliveryDate;
  final String status;

  final List<DeliveryItemModel>? deliveryItems;

  DeliveryScheduleModel({
    required this.deliveryId,
    required this.deliveryDate,
    required this.status,

    //ASSOCIATION
    this.deliveryItems,
  });

  factory DeliveryScheduleModel.fromJson(Map<String, dynamic> json) {
    return DeliveryScheduleModel(
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
