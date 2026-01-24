import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/user/user_user_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class DeliveryRequestModel {
  final int requestId;
  final String status;

  //field temp
  final double? volume;

  //FK
  final int userId;
  final int planningId;

  final PlanningPaper? paper;
  final UserUserModel? user;

  DeliveryRequestModel({
    required this.requestId,
    required this.status,

    //field temp
    this.volume,

    //ASSOCIATION
    required this.userId,
    required this.planningId,

    this.paper,
    this.user,
  });

  factory DeliveryRequestModel.fromJson(Map<String, dynamic> json) {
    return DeliveryRequestModel(
      requestId: json['deliveryId'] ?? 0,
      status: json['status'] ?? "",
      userId: json['userId'] ?? 0,
      planningId: json['planningId'] ?? 0,

      //field temp
      volume: toDouble(json['volume']),

      paper: json['PlanningPaper'] != null ? PlanningPaper.fromJson(json['PlanningPaper']) : null,
      user: json['User'] != null ? UserUserModel.fromJson(json['User']) : null,
    );
  }
}
