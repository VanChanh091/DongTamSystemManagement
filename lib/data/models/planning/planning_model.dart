import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/paper_consumption_norm_model.dart';
import 'package:dongtam/data/models/planning/time_overflow_planning.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class Planning {
  final int planningId;
  final DateTime? dayStart;
  final TimeOfDay? timeRunning;
  final int runningPlan;
  final int? ghepKho;
  final int? sortPlanning;
  final double lengthPaperPlanning, sizePaperPLaning;
  final String? dayReplace;
  final String? matEReplace, matBReplace, matCReplace;
  final String? songEReplace, songBReplace, songCReplace, songE2Replace;
  final String chooseMachine;

  final String orderId;
  final Order? order;
  final PaperConsumptionNorm? paperConsumptionNorm;
  final TimeOverflowPlanning? timeOverflowPlanning;

  Planning({
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
    this.sortPlanning,

    required this.orderId,
    this.order,
    this.paperConsumptionNorm,
    this.timeOverflowPlanning,
  });

  String get formatterStructureOrder {
    final prefixes = ['', 'E', '', 'B', '', 'C', '', ''];
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

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part != null && part.isNotEmpty) {
        final prefix = prefixes[i];
        if (!part.startsWith(prefix.replaceAll(r'[^A-Z]', ""))) {
          formattedParts.add('$prefix$part');
        } else {
          formattedParts.add(part);
        }
      }
    }
    return formattedParts.join('/');
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
      planningId: json["planningId"] ?? 0,
      dayStart:
          json['dayStart'] != null && json['dayStart'] != ''
              ? DateTime.tryParse(json['dayStart'])
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
      sortPlanning: json['sortPlanning'] ?? 0,

      orderId: json['orderId'] ?? "",
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
      paperConsumptionNorm:
          json['norm'] != null
              ? PaperConsumptionNorm.fromJson(json['norm'])
              : null,
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

      'orderId': orderId,
      'order': order?.toJson(),
      'paperConsumptionNorm': paperConsumptionNorm?.toJson(),
    };
  }
}
