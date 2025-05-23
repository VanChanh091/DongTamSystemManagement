import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/paper_consumption_norm_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class Planning {
  final String dayStart;
  final int runningPlan;
  final TimeOfDay timeRunning;
  final String? dayReplace;
  final String? middle_1Replace;
  final String? middle_2Replace;
  final String? matReplace;
  final String? songEReplace;
  final String? songBReplace;
  final String? songCReplace;
  final String? songE2Replace;
  final double lengthPaperPlanning;
  final double sizePaperPLaning;
  final int quantity;
  final int numberChild;
  final String chooseMachine;

  final PaperConsumptionNorm? paperConsumptionNorm;
  final Order? order;

  Planning({
    required this.dayStart,
    required this.runningPlan,
    required this.timeRunning,
    this.dayReplace,
    this.middle_1Replace,
    this.middle_2Replace,
    this.matReplace,
    this.songEReplace,
    this.songBReplace,
    this.songCReplace,
    this.songE2Replace,
    required this.lengthPaperPlanning,
    required this.sizePaperPLaning,
    required this.quantity,
    required this.numberChild,
    required this.chooseMachine,
    this.paperConsumptionNorm,
    this.order,
  });

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
      dayStart: json['dayStart'] ?? "",
      runningPlan: json['runningPlan'] ?? 0,
      timeRunning:
          json['timeRunning'] != null
              ? TimeOfDay(
                hour: json['timeRunning']['hour'] ?? 0,
                minute: json['timeRunning']['minute'] ?? 0,
              )
              : TimeOfDay(hour: 0, minute: 0),
      dayReplace: json['dayReplace'] ?? "",
      middle_1Replace: json['middle_1Replace'] ?? "",
      middle_2Replace: json['middle_2Replace'] ?? "",
      matReplace: json['matReplace'] ?? "",
      songEReplace: json['songEReplace'] ?? "",
      songBReplace: json['songBReplace'] ?? "",
      songCReplace: json['songCReplace'] ?? "",
      songE2Replace: json['songE2Replace'] ?? "",
      lengthPaperPlanning: toDouble(json['lengthPaperPlanning']),
      sizePaperPLaning: toDouble((json['sizePaperPLaning'])),
      quantity: json['quantity'] ?? 0,
      numberChild: json['numberChild'] ?? 0,
      chooseMachine: json['chooseMachine'] ?? "",
      paperConsumptionNorm:
          json['paperConsumptionNorm'] != null
              ? PaperConsumptionNorm.fromJson(json['paperConsumptionNorm'])
              : null,
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayStart': dayStart,
      'runningPlan': runningPlan,
      'timeRunning': {'hour': timeRunning.hour, 'minute': timeRunning.minute},
      'dayReplace': dayReplace,
      'middle_1Replace': middle_1Replace,
      'middle_2Replace': middle_2Replace,
      'matReplace': matReplace,
      'songEReplace': songEReplace,
      'songBReplace': songBReplace,
      'songCReplace': songCReplace,
      'songE2Replace': songE2Replace,
      'lengthPaperPlanning': lengthPaperPlanning,
      'sizePaperPLaning': sizePaperPLaning,
      'quantity': quantity,
      'numberChild': numberChild,
      'chooseMachine': chooseMachine,
      'paperConsumptionNorm': paperConsumptionNorm?.toJson(),
      'order': order?.toJson(),
    };
  }
}
