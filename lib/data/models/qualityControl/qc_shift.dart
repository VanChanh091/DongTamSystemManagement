import 'package:dongtam/utils/helper/helper_model.dart';

class QcShiftModel {
  final int qcShiftId;
  final String username;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final bool isActive;
  final bool isOnDuty;

  //FK
  final int userId;

  QcShiftModel({
    this.qcShiftId = 0,
    required this.username,
    required this.startedAt,
    this.endedAt,
    required this.isActive,
    this.isOnDuty = false,

    //FK
    this.userId = 0,
  });

  factory QcShiftModel.fromJson(Map<String, dynamic> json) {
    final shiftInfo =
        json["shiftInfo"] is Map<String, dynamic>
            ? json["shiftInfo"] as Map<String, dynamic>
            : null;

    final isOnDuty = json["isOnDuty"] as bool? ?? false;
    final isActive = (shiftInfo?["isActive"] as bool?) ?? (json["isActive"] as bool?) ?? isOnDuty;

    final startedAtRaw = shiftInfo?["startedAt"] ?? json["startedAt"];
    final endedAtRaw = shiftInfo?["endedAt"] ?? json["endedAt"];

    return QcShiftModel(
      qcShiftId: toInt(shiftInfo?["qcShiftId"] ?? json["qcShiftId"]),
      username: (shiftInfo?["username"] ?? json["username"] ?? "").toString(),
      startedAt:
          startedAtRaw != null && startedAtRaw != ""
              ? DateTime.tryParse(startedAtRaw.toString())
              : null,
      endedAt:
          endedAtRaw != null && endedAtRaw != "" ? DateTime.tryParse(endedAtRaw.toString()) : null,
      isActive: isActive,
      isOnDuty: isOnDuty,

      //FK
      userId: toInt(shiftInfo?["userId"] ?? json["userId"]),
    );
  }
}
