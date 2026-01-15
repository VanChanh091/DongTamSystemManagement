import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_stages.dart';
import 'package:dongtam/data/models/planning/time_overflow_planning.dart';
import 'package:dongtam/data/models/warehouse/inbound_history_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class PlanningPaper {
  //frontend
  final DateTime? dayStart, dayCompleted;
  final int ghepKho;
  final double lengthPaperPlanning, sizePaperPLaning;
  final String? dayReplace, matEReplace, matBReplace, matCReplace, matE2Replace;
  final String? songEReplace, songBReplace, songCReplace, songE2Replace;
  final int runningPlan, numberChild;
  final int? qtyProduced;
  final double? qtyWasteNorm;
  final String chooseMachine;
  final String? shiftProduction;
  final String? shiftManagement;

  //backend auto generate
  final int planningId;
  final TimeOfDay? timeRunning;
  final int? sortPlanning;
  final double? bottom, fluteE, fluteB, fluteC, fluteE2, knife, totalLoss;
  final String status;
  final String? statusRequest;

  //field temp
  final double? volume;

  final bool hasBox;

  //association
  final String orderId;
  final Order? order;
  final TimeOverflowPlanning? timeOverflowPlanning;
  final List<PlanningStage>? stages;
  final List<InboundHistoryModel>? inbound;

  PlanningPaper({
    required this.planningId,
    required this.runningPlan,
    this.timeRunning,
    this.dayStart,
    this.dayReplace,
    this.matEReplace,
    this.matBReplace,
    this.matCReplace,
    this.matE2Replace,
    this.songEReplace,
    this.songBReplace,
    this.songCReplace,
    this.songE2Replace,
    required this.lengthPaperPlanning,
    required this.sizePaperPLaning,
    required this.ghepKho,
    required this.numberChild,
    required this.chooseMachine,
    this.bottom,
    this.fluteE,
    this.fluteB,
    this.fluteC,
    this.fluteE2,
    this.knife,
    this.totalLoss,
    this.sortPlanning,
    required this.status,
    this.statusRequest,
    this.dayCompleted,
    this.qtyProduced,
    this.qtyWasteNorm,
    this.shiftManagement,
    this.shiftProduction,
    required this.hasBox,
    this.volume,

    required this.orderId,
    this.order,
    this.timeOverflowPlanning,
    this.stages,
    this.inbound,
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
      matE2Replace,
    ];
    final formattedParts = <String>[];

    for (final part in parts) {
      if (part != null && part.isNotEmpty) {
        formattedParts.add(part);
      }
    }

    return formattedParts.join('/');
  }

  int get getTotalQtyInbound => inbound?.fold(0, (sum, e) => sum! + e.qtyInbound) ?? 0;

  static String formatTimeOfDay({required TimeOfDay timeOfDay}) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  int get remainRunningPlan {
    final remain = runningPlan - (qtyProduced ?? 0);
    return remain > 0 ? remain : 0;
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
      matE2Replace: json['matE2Replace'] ?? "",
      songEReplace: json['songEReplace'] ?? "",
      songBReplace: json['songBReplace'] ?? "",
      songCReplace: json['songCReplace'] ?? "",
      songE2Replace: json['songE2Replace'] ?? "",
      lengthPaperPlanning: toDouble(json['lengthPaperPlanning']),
      sizePaperPLaning: toDouble((json['sizePaperPLaning'])),
      ghepKho: json['ghepKho'] ?? 0,
      numberChild: json['numberChild'] ?? 0,
      chooseMachine: json['chooseMachine'] ?? "",
      bottom: toDouble(json['bottom']),
      fluteE: toDouble(json['fluteE']),
      fluteB: toDouble(json['fluteB']),
      fluteC: toDouble(json['fluteC']),
      fluteE2: toDouble(json['fluteE2']),
      knife: toDouble(json['knife']),
      totalLoss: toDouble(json['totalLoss']),
      sortPlanning: json['sortPlanning'] ?? 0,
      status: json['status'] ?? "",
      statusRequest: json['statusRequest'] ?? "",
      qtyProduced: json['qtyProduced'] ?? 0,
      qtyWasteNorm: toDouble(json['qtyWasteNorm']),
      shiftManagement: json['shiftManagement'] ?? "",
      shiftProduction: json['shiftProduction'] ?? "",
      hasBox: json['hasBox'] ?? false,

      //field temp
      volume: toDouble(json['volume']),

      orderId: json['orderId'] ?? "",
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
      timeOverflowPlanning:
          json['timeOverFlow'] != null ? TimeOverflowPlanning.fromJson(json['timeOverFlow']) : null,
      stages:
          json['stages'] != null
              ? List<PlanningStage>.from(json['stages'].map((x) => PlanningStage.fromJson(x)))
              : [],
      inbound:
          json['inbound'] != null
              ? List<InboundHistoryModel>.from(
                json['inbound'].map((x) => InboundHistoryModel.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'runningPlan': runningPlan,
      'dayReplace': dayReplace,
      'matEReplace': matEReplace,
      'matBReplace': matBReplace,
      'matCReplace': matCReplace,
      'matE2Replace': matE2Replace,
      'songEReplace': songEReplace,
      'songBReplace': songBReplace,
      'songCReplace': songCReplace,
      'songE2Replace': songE2Replace,
      'lengthPaperPlanning': lengthPaperPlanning,
      'sizePaperPLaning': sizePaperPLaning,
      'ghepKho': ghepKho,
      'numberChild': numberChild,
      'chooseMachine': chooseMachine,
      'hasBox': hasBox,

      'orderId': orderId,
      'order': order?.toJson(),
    };
  }
}
