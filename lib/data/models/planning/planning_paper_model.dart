import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/time_overflow_planning.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class PlanningPaper {
  //frontend
  final DateTime? dayStart, dayCompleted;
  final int? ghepKho;
  final double lengthPaperPlanning, sizePaperPLaning;
  final String? dayReplace, matEReplace, matBReplace, matCReplace;
  final String? songEReplace, songBReplace, songCReplace, songE2Replace;
  final int runningPlan;
  final int? qtyProduced;
  final double? qtyWasteNorm;
  final String chooseMachine;
  final String? shiftProduction;
  final String? shiftManagement;

  //backend auto generate
  final int planningId;
  final TimeOfDay? timeRunning;
  final int? sortPlanning;
  final double? bottom;
  final double? fluteE;
  final double? fluteB;
  final double? fluteC;
  final double? knife;
  final double? totalLoss;
  final String status;
  final bool hasBox;

  final String orderId;
  final Order? order;
  final TimeOverflowPlanning? timeOverflowPlanning;

  PlanningPaper({
    required this.planningId,
    required this.runningPlan,
    this.timeRunning,
    this.dayStart,
    this.dayReplace,
    this.matEReplace,
    this.matBReplace,
    this.matCReplace,
    this.songEReplace,
    this.songBReplace,
    this.songCReplace,
    this.songE2Replace,
    required this.lengthPaperPlanning,
    required this.sizePaperPLaning,
    required this.ghepKho,
    required this.chooseMachine,
    this.bottom,
    this.fluteE,
    this.fluteB,
    this.fluteC,
    this.knife,
    this.totalLoss,
    this.sortPlanning,
    required this.status,
    this.dayCompleted,
    this.qtyProduced,
    this.qtyWasteNorm,
    this.shiftManagement,
    this.shiftProduction,
    required this.hasBox,

    required this.orderId,
    this.order,
    this.timeOverflowPlanning,
  });

  String get formatterStructureOrder {
    final parts = [
      dayReplace,
      songEReplace,
      matEReplace,
      songBReplace,
      matBReplace,
      songCReplace,
      matCReplace,
      songE2Replace,
    ];
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

  factory PlanningPaper.fromJson(Map<String, dynamic> json) {
    return PlanningPaper(
      planningId: json["planningId"],
      dayStart:
          json['dayStart'] != null && json['dayStart'] != ''
              ? DateTime.tryParse(json['dayStart'])
              : null,
      dayCompleted:
          json['dayCompleted'] != null && json['dayCompleted'] != ''
              ? DateTime.tryParse(json['dayCompleted'])
              : null,
      timeRunning:
          json['timeRunning'] != null && json['timeRunning'] != ''
              ? parseTimeOfDay(json['timeRunning'])
              : null,
      runningPlan: json['runningPlan'] ?? 0,
      dayReplace: json['dayReplace'] ?? "",
      matEReplace: json['matEReplace'] ?? "",
      matBReplace: json['matBReplace'] ?? "",
      matCReplace: json['matCReplace'] ?? "",
      songEReplace: json['songEReplace'] ?? "",
      songBReplace: json['songBReplace'] ?? "",
      songCReplace: json['songCReplace'] ?? "",
      songE2Replace: json['songE2Replace'] ?? "",
      lengthPaperPlanning: toDouble(json['lengthPaperPlanning']),
      sizePaperPLaning: toDouble((json['sizePaperPLaning'])),
      ghepKho: json['ghepKho'] ?? "",
      chooseMachine: json['chooseMachine'] ?? "",
      bottom: toDouble(json['bottom']),
      fluteE: toDouble(json['fluteE']),
      fluteB: toDouble(json['fluteB']),
      fluteC: toDouble(json['fluteC']),
      knife: toDouble(json['knife']),
      totalLoss: toDouble(json['totalLoss']),
      sortPlanning: json['sortPlanning'] ?? 0,
      status: json['status'] ?? "",
      qtyProduced: json['qtyProduced'] ?? 0,
      qtyWasteNorm: toDouble(json['qtyWasteNorm']),
      shiftManagement: json['shiftManagement'] ?? "",
      shiftProduction: json['shiftProduction'] ?? "",
      hasBox: json['hasBox'] ?? false,

      orderId: json['orderId'] ?? "",
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
      timeOverflowPlanning:
          json['timeOverFlow'] != null
              ? TimeOverflowPlanning.fromJson(json['timeOverFlow'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'runningPlan': runningPlan,
      'dayReplace': dayReplace,
      'matEReplace': matEReplace,
      'matBReplace': matBReplace,
      'matCReplace': matCReplace,
      'songEReplace': songEReplace,
      'songBReplace': songBReplace,
      'songCReplace': songCReplace,
      'songE2Replace': songE2Replace,
      'lengthPaperPlanning': lengthPaperPlanning,
      'sizePaperPLaning': sizePaperPLaning,
      'ghepKho': ghepKho,
      'chooseMachine': chooseMachine,
      'hasBox': hasBox,

      'orderId': orderId,
      'order': order?.toJson(),
    };
  }
}
