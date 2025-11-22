import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class TimeOverflowPlanning {
  final DateTime? overflowDayStart;
  final DateTime? overflowDayCompleted;
  final TimeOfDay? overflowTimeRunning;
  final String? machine;
  final String? status;

  final int planningId;
  final int planningBoxId;

  TimeOverflowPlanning({
    this.overflowDayStart,
    this.overflowDayCompleted,
    this.overflowTimeRunning,
    this.machine,
    this.status,
    required this.planningId,
    required this.planningBoxId,
  });

  factory TimeOverflowPlanning.fromJson(Map<String, dynamic> json) {
    return TimeOverflowPlanning(
      overflowDayStart:
          json['overflowDayStart'] != null && json['overflowDayStart'] != ''
              ? DateTime.tryParse(json['overflowDayStart'])
              : null,
      overflowDayCompleted:
          json['overflowDayCompleted'] != null && json['overflowDayCompleted'] != ''
              ? DateTime.tryParse(json['overflowDayCompleted'])
              : null,
      overflowTimeRunning:
          json['overflowTimeRunning'] != null && json['overflowTimeRunning'] != ''
              ? parseTimeOfDay(json['overflowTimeRunning'])
              : null,
      machine: json['machine'] ?? "",
      status: json['status'] ?? "",
      planningId: json['planningId'] ?? 0,
      planningBoxId: json['planningBoxId'] ?? 0,
    );
  }
}
