import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class TimeOverflowPlanning {
  final DateTime? overflowDayStart;
  final TimeOfDay? overflowTimeRunning;
  final int? sortPlanning;

  final int planningId;

  TimeOverflowPlanning({
    this.overflowDayStart,
    this.overflowTimeRunning,
    this.sortPlanning,
    required this.planningId,
  });

  factory TimeOverflowPlanning.fromJson(Map<String, dynamic> json) {
    return TimeOverflowPlanning(
      overflowDayStart: DateTime.parse(json['overflowDayStart']),
      overflowTimeRunning: parseTimeOfDay(json['overflowTimeRunning']),
      sortPlanning: json['sortPlanning'] ?? 0,
      planningId: json['planningId'] ?? 0,
    );
  }
}
