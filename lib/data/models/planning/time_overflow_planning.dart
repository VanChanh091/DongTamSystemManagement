import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class TimeOverflowPlanning {
  final DateTime? overflowDayStart;
  final TimeOfDay? overflowTimeRunning;
  final String? machine;
  final int? sortPlanning;

  final int planningId;

  TimeOverflowPlanning({
    this.overflowDayStart,
    this.overflowTimeRunning,
    this.sortPlanning,
    this.machine,
    required this.planningId,
  });

  factory TimeOverflowPlanning.fromJson(Map<String, dynamic> json) {
    return TimeOverflowPlanning(
      overflowDayStart: DateTime.parse(json['overflowDayStart']),
      overflowTimeRunning: parseTimeOfDay(json['overflowTimeRunning']),
      machine: json['machine'] ?? "",
      sortPlanning: json['sortPlanning'] ?? 0,
      planningId: json['planningId'] ?? 0,
    );
  }
}
