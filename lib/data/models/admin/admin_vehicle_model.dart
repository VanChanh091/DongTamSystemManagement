import 'package:dongtam/utils/helper/helper_model.dart';

class AdminVehicleModel {
  int? vehicleId;
  String vehicleName;
  String licensePlate;
  int maxPayload;
  double volumeCapacity;

  bool isDraft;

  AdminVehicleModel({
    this.vehicleId,
    required this.vehicleName,
    required this.licensePlate,
    required this.maxPayload,
    required this.volumeCapacity,
    this.isDraft = false,
  });

  factory AdminVehicleModel.fromJson(Map<String, dynamic> json) {
    return AdminVehicleModel(
      vehicleId: json['vehicleId'] ?? 0,
      vehicleName: json['vehicleName'] ?? "",
      licensePlate: json['licensePlate'] ?? "",
      maxPayload: json['maxPayload'] ?? 0,
      volumeCapacity: toDouble(json['volumeCapacity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vehicleName": vehicleName,
      "licensePlate": licensePlate,
      "maxPayload": maxPayload,
      "volumeCapacity": volumeCapacity,
    };
  }
}
