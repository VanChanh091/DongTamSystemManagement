import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/box_machine_time.dart';
import 'package:dongtam/data/models/planning/time_overflow_planning.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class PlanningBox {
  final int planningBoxId;
  final DateTime? dayStart;
  final int runningPlan;
  final String? day, matE, matB, matC, songE, songB, songC, songE2;
  final double length, size;

  final int planningId;
  final String orderId;
  final Order? order;
  final TimeOverflowPlanning? timeOverflowPlanning;
  final List<BoxMachineTime>? boxMachineTime;

  PlanningBox({
    required this.planningBoxId,
    this.dayStart,
    required this.runningPlan,
    this.day,
    this.matE,
    this.matB,
    this.matC,
    this.songE,
    this.songB,
    this.songC,
    this.songE2,
    required this.length,
    required this.size,

    required this.planningId,
    required this.orderId,
    this.order,
    this.timeOverflowPlanning,
    this.boxMachineTime,
  });

  String get formatterStructureOrder {
    final parts = [day, songE, matE, songB, matB, songC, matC, songE2];
    final formattedParts = <String>[];

    for (final part in parts) {
      if (part != null && part.isNotEmpty) {
        formattedParts.add(part);
      }
    }

    return formattedParts.join('/');
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  BoxMachineTime? getBoxMachineTimeByMachine(String machine) {
    return boxMachineTime?.firstWhere((item) => item.machine == machine);
  }

  factory PlanningBox.fromJson(Map<String, dynamic> json) {
    return PlanningBox(
      planningBoxId: json['planningBoxId'],
      dayStart:
          json['dayStart'] != null && json['dayStart'] != ''
              ? DateTime.tryParse(json['dayStart'])
              : null,
      runningPlan: json['runningPlan'] ?? 0,
      day: json['day'] ?? "",
      matE: json['matE'] ?? "",
      matB: json['matB'] ?? "",
      matC: json['matC'] ?? "",
      songE: json['songE'] ?? "",
      songB: json['songB'] ?? "",
      songC: json['songC'] ?? "",
      songE2: json['songE2'] ?? "",
      length: toDouble(json['length']),
      size: toDouble(json['size']),

      orderId: json['orderId'] ?? "",
      planningId: json['planningId'] ?? 0,
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
      timeOverflowPlanning:
          json['timeOverFlow'] != null
              ? TimeOverflowPlanning.fromJson(json['timeOverFlow'])
              : null,
      boxMachineTime:
          json['boxTimes'] != null
              ? List<BoxMachineTime>.from(
                json['boxTimes'].map((x) => BoxMachineTime.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {"dayStart": dayStart, "planningId": planningId, "orderId": orderId};
  }
}
