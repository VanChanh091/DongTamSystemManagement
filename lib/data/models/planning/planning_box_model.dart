import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/box_machine_time.dart';
import 'package:dongtam/data/models/planning/time_overflow_planning.dart';
import 'package:dongtam/data/models/warehouse/inbound_history_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class PlanningBox {
  final int planningBoxId;

  final int qtyPaper;
  final String? day, matE, matB, matC, matE2, songE, songB, songC, songE2;
  final double length, size;

  final String statusRequest;

  final int planningId;
  final String orderId;
  final Order? order;
  final List<TimeOverflowPlanning>? timeOverflowPlanning;
  final List<BoxMachineTime>? boxTimes;
  final List<BoxMachineTime>? allBoxTimes;
  final List<InboundHistoryModel>? inbound;

  PlanningBox({
    required this.planningBoxId,
    required this.qtyPaper,
    this.day,
    this.matE,
    this.matB,
    this.matC,
    this.matE2,
    this.songE,
    this.songB,
    this.songC,
    this.songE2,
    required this.length,
    required this.size,
    required this.statusRequest,

    required this.planningId,
    required this.orderId,
    this.order,
    this.timeOverflowPlanning,
    this.boxTimes,
    this.allBoxTimes,
    this.inbound,
  });

  String get formatterStructureOrder {
    final parts = [day, songE, matE, songB, matB, songC, matC, songE2, matE2];
    final formattedParts = <String>[];

    for (final part in parts) {
      if (part != null && part.isNotEmpty) {
        formattedParts.add(part);
      }
    }

    return formattedParts.join('/');
  }

  static String formatTimeOfDay({required TimeOfDay timeOfDay}) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  //get data of box time machine
  BoxMachineTime? _findByMachine({required List<BoxMachineTime>? list, required String machine}) {
    if (list == null) return null;
    try {
      return list.firstWhere((item) => item.machine == machine);
    } catch (e) {
      return null;
    }
  }

  //get one box
  BoxMachineTime? getBoxMachineTimeByMachine(String machine) =>
      _findByMachine(list: boxTimes, machine: machine);

  //get all box
  BoxMachineTime? getAllBoxMachineTime(String machine) =>
      _findByMachine(list: allBoxTimes, machine: machine);

  TimeOverflowPlanning? getTimeOverflow({required String machine}) {
    if (timeOverflowPlanning == null) return null;
    try {
      return timeOverflowPlanning?.firstWhere((item) => item.machine == machine);
    } catch (e) {
      return null;
    }
  }

  factory PlanningBox.fromJson(Map<String, dynamic> json) {
    return PlanningBox(
      planningBoxId: json['planningBoxId'],
      qtyPaper: json['qtyPaper'] ?? 0,

      day: json['day'] ?? "",
      matE: json['matE'] ?? "",
      matB: json['matB'] ?? "",
      matC: json['matC'] ?? "",
      matE2: json['matE2'] ?? "",
      songE: json['songE'] ?? "",
      songB: json['songB'] ?? "",
      songC: json['songC'] ?? "",
      songE2: json['songE2'] ?? "",
      length: toDouble(json['length']),
      size: toDouble(json['size']),
      statusRequest: json['statusRequest'],

      orderId: json['orderId'] ?? "",
      planningId: json['planningId'] ?? 0,
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
      timeOverflowPlanning:
          json['timeOverFlow'] != null
              ? List<TimeOverflowPlanning>.from(
                json['timeOverFlow'].map((x) => TimeOverflowPlanning.fromJson(x)),
              )
              : [],
      boxTimes:
          json['boxTimes'] != null
              ? List<BoxMachineTime>.from(json['boxTimes'].map((x) => BoxMachineTime.fromJson(x)))
              : [],
      allBoxTimes:
          json['allBoxTimes'] != null
              ? List<BoxMachineTime>.from(
                json['allBoxTimes'].map((x) => BoxMachineTime.fromJson(x)),
              )
              : [],
      inbound:
          json['inbound'] != null
              ? List<InboundHistoryModel>.from(
                json['inbound'].map((x) => InboundHistoryModel.fromJson(x)),
              )
              : [],
    );
  }
}
