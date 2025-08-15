import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/box_machine_time.dart';
import 'package:dongtam/data/models/planning/time_overflow_planning.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class PlanningBox {
  final int planningBoxId;

  final int runningPlan;
  final String? day, matE, matB, matC, songE, songB, songC, songE2;
  final double length, size;

  final int planningId;
  final String orderId;
  final Order? order;
  final TimeOverflowPlanning? timeOverflowPlanning;
  final List<BoxMachineTime>? boxTimes;
  final List<BoxMachineTime>? allBoxTimes;

  PlanningBox({
    required this.planningBoxId,
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
    this.boxTimes,
    this.allBoxTimes,
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
    return boxTimes?.firstWhere((item) => item.machine == machine);
  }

  BoxMachineTime? getAllBoxMachineTime(String machine) {
    if (allBoxTimes == null) return null;
    final match = allBoxTimes!.where((item) => item.machine == machine);
    return match.isNotEmpty ? match.first : null;
  }

  factory PlanningBox.fromJson(Map<String, dynamic> json) {
    return PlanningBox(
      planningBoxId: json['planningBoxId'],
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
      boxTimes:
          json['boxTimes'] != null
              ? List<BoxMachineTime>.from(
                json['boxTimes'].map((x) => BoxMachineTime.fromJson(x)),
              )
              : [],
      allBoxTimes:
          json['allBoxTimes'] != null
              ? List<BoxMachineTime>.from(
                json['allBoxTimes'].map((x) => BoxMachineTime.fromJson(x)),
              )
              : [],
    );
  }
}
