import 'package:dongtam/data/models/admin/admin_vehicle_model.dart';
import 'package:dongtam/data/models/delivery/delivery_plan_model.dart';
import 'package:dongtam/data/models/delivery/delivery_request_model.dart';

class DeliveryItemModel {
  final int deliveryItemId;
  final String sequence;
  final String? note;
  final String status;

  //FK
  final int deliveryId;
  final int requestId;
  final int vehicleId;

  final DeliveryPlanModel? deliveryPlan;
  final DeliveryRequest? request;
  final AdminVehicleModel? vehicle;

  DeliveryItemModel({
    required this.deliveryItemId,
    required this.sequence,
    required this.status,
    this.note,

    //FK
    required this.deliveryId,
    required this.requestId,
    required this.vehicleId,

    this.deliveryPlan,
    this.vehicle,
    this.request,
  });

  factory DeliveryItemModel.fromJson(Map<String, dynamic> json) {
    return DeliveryItemModel(
      deliveryItemId: json['deliveryItemId'] ?? 0,
      sequence: json['sequence'] ?? "",
      note: json['note'] ?? "",
      status: json['status'] ?? "",

      //FK
      deliveryId: json['deliveryId'] ?? 0,
      requestId: json['requestId'] ?? 0,
      vehicleId: json['vehicleId'] ?? 0,
      deliveryPlan:
          json['DeliveryPlan'] != null ? DeliveryPlanModel.fromJson(json['DeliveryPlan']) : null,
      vehicle: json['Vehicle'] != null ? AdminVehicleModel.fromJson(json['Vehicle']) : null,
      request:
          json['DeliveryRequest'] != null
              ? DeliveryRequest.fromJson(json['DeliveryRequest'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {"sequence": sequence, "note": note};
  }
}
