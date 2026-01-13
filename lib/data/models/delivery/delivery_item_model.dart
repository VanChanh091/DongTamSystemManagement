import 'package:dongtam/data/models/admin/admin_vehicle_model.dart';
import 'package:dongtam/data/models/delivery/delivery_plan_model.dart';

class DeliveryItemModel {
  final int deliveryItemId;
  final String targetType;
  final int targetId;
  final int sequence;
  final String status;

  //FK
  final int deliveryId;
  final int vehicleId;

  final DeliveryPlanModel? deliveryPlan;
  final AdminVehicleModel? vehicle;

  DeliveryItemModel({
    required this.deliveryItemId,
    required this.targetType,
    required this.targetId,
    required this.sequence,
    required this.status,

    //FK
    required this.deliveryId,
    required this.vehicleId,
    this.deliveryPlan,
    this.vehicle,
  });

  factory DeliveryItemModel.fromJson(Map<String, dynamic> json) {
    return DeliveryItemModel(
      deliveryItemId: json['deliveryItemId'] ?? 0,
      targetType: json['targetType'] ?? "",
      targetId: json['targetId'] ?? 0,
      sequence: json['sequence'] ?? 0,
      status: json['status'] ?? "",

      //FK
      deliveryId: json['deliveryId'] ?? 0,
      vehicleId: json['vehicleId'] ?? 0,
      deliveryPlan:
          json['DeliveryPlan'] != null ? DeliveryPlanModel.fromJson(json['DeliveryPlan']) : null,
      vehicle: json['Vehicle'] != null ? AdminVehicleModel.fromJson(json['Vehicle']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"targetType": targetType, "targetId": targetId, "sequence": sequence};
  }
}
