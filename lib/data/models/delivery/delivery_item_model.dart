import 'package:dongtam/data/models/admin/admin_vehicle_model.dart';
import 'package:dongtam/data/models/delivery/delivery_schedule_model.dart';
import 'package:dongtam/data/models/delivery/delivery_request_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart';

class DeliveryItemModel {
  final int deliveryItemId;
  final String sequence;
  final int? idxOrder;
  final String? recipient;
  final DateTime? dayRequested;
  final DateTime? dayCompleted;
  final String status;

  //FK
  final int deliveryId;
  final int requestId;
  final int vehicleId;

  final DeliveryScheduleModel? deliverySchedule;
  final DeliveryRequest? request;
  final AdminVehicleModel? vehicle;
  final List<OutboundDetailModel>? outboundDetails;
  final DeliveryScheduleModel? DeliverySchedule;

  DeliveryItemModel({
    required this.deliveryItemId,
    required this.sequence,
    required this.status,
    this.idxOrder,
    this.recipient,
    this.dayRequested,
    this.dayCompleted,

    //FK
    required this.deliveryId,
    required this.requestId,
    required this.vehicleId,
    this.outboundDetails,
    this.DeliverySchedule,

    this.deliverySchedule,
    this.vehicle,
    this.request,
  });

  int get getTotalQtyOutbound => outboundDetails?.fold(0, (sum, e) => sum! + e.outboundQty) ?? 0;

  factory DeliveryItemModel.fromJson(Map<String, dynamic> json) {
    return DeliveryItemModel(
      deliveryItemId: json['deliveryItemId'] ?? 0,
      sequence: json['sequence'] ?? "",
      idxOrder: json['idxOrder'] ?? 0,
      recipient: json['recipient'] ?? "",
      dayRequested: json['dayRequested'] != null ? DateTime.parse(json['dayRequested']) : null,
      dayCompleted: json['dayCompleted'] != null ? DateTime.parse(json['dayCompleted']) : null,
      status: json['status'] ?? "",

      //FK
      deliveryId: json['deliveryId'] ?? 0,
      requestId: json['requestId'] ?? 0,
      vehicleId: json['vehicleId'] ?? 0,
      deliverySchedule:
          json['DeliverySchedule'] != null
              ? DeliveryScheduleModel.fromJson(json['DeliverySchedule'])
              : null,
      vehicle: json['Vehicle'] != null ? AdminVehicleModel.fromJson(json['Vehicle']) : null,
      request:
          json['DeliveryRequest'] != null
              ? DeliveryRequest.fromJson(json['DeliveryRequest'])
              : null,
      DeliverySchedule:
          json['DeliveryPlan'] != null
              ? DeliveryScheduleModel.fromJson(json['DeliveryPlan'])
              : null,
      outboundDetails:
          json['OutboundDetails'] != null
              ? List<OutboundDetailModel>.from(
                json['OutboundDetails'].map((x) => OutboundDetailModel.fromJson(x)),
              )
              : [],
    );
  }
}
