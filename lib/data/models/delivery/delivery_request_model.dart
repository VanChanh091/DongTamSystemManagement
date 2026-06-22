import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/user/user_user_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class DeliveryRequest {
  final int requestId;
  final int qtyRegistered;
  final double volume;
  final String status;
  final String? note;

  //temp variable
  bool hasOutbound = false;

  //FK
  final int userId;
  final int planningId;

  final PlanningPaper? paper;
  final UserUserModel? user;

  DeliveryRequest({
    required this.requestId,
    required this.qtyRegistered,
    required this.volume,
    required this.status,
    this.note,

    //ASSOCIATION
    required this.userId,
    required this.planningId,

    this.paper,
    this.user,
  });

  factory DeliveryRequest.fromJson(Map<String, dynamic> json) {
    return DeliveryRequest(
      requestId: json['requestId'] ?? 0,
      qtyRegistered: json['qtyRegistered'] ?? 0,
      volume: toDouble(json['volume']),
      status: json['status'] ?? "",
      note: json['note'],

      //ASSOCIATION
      userId: json['userId'] ?? 0,
      planningId: json['planningId'] ?? 0,
      paper: json['PlanningPaper'] != null ? PlanningPaper.fromJson(json['PlanningPaper']) : null,
      user: json['User'] != null ? UserUserModel.fromJson(json['User']) : null,
    );
  }
}
