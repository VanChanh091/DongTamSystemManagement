import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/paper_consumption_norm_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class Planning {
  final int planningId;
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
  final int numberChild;
  final int? ghepKho;
  final String chooseMachine;

  final String orderId;
  final Order? order;
  final PaperConsumptionNorm? paperConsumptionNorm;

  Planning({
    required this.planningId,
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
    required this.ghepKho,
    required this.numberChild,
    required this.chooseMachine,
    required this.orderId,
    this.order,
    this.paperConsumptionNorm,
  });

  String get formatterStructureOrder {
    final prefixes = ['', 'E', '', 'B', '', 'C', '', ''];
    final parts = [
      dayReplace,
      songEReplace,
      middle_1Replace,
      songBReplace,
      middle_2Replace,
      songCReplace,
      matReplace,
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

  static TimeOfDay parseTimeOfDay(dynamic timeValue) {
    // Trường hợp đã là TimeOfDay → trả về luôn
    if (timeValue is TimeOfDay) return timeValue;

    // Trường hợp là chuỗi hợp lệ → parse
    if (timeValue is String && timeValue.isNotEmpty) {
      try {
        final parts = timeValue.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          return TimeOfDay(hour: hour, minute: minute);
        }
      } catch (e) {
        print('⚠️ Error parsing time: $e for $timeValue');
      }
    }

    // Trả về mặc định nếu không parse được
    return const TimeOfDay(hour: 0, minute: 0);
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
      planningId: json["planningId"] ?? 0,
      orderId: json['orderId'] ?? "",
      runningPlan: json['runningPlan'] ?? 0,
      timeRunning: parseTimeOfDay(json['timeRunning']),
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
      numberChild: json['numberChild'] ?? 0,
      ghepKho: json['ghepKho'] ?? "",
      chooseMachine: json['chooseMachine'] ?? "",
      paperConsumptionNorm:
          json['norm'] != null
              ? PaperConsumptionNorm.fromJson(json['norm'])
              : null,
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'runningPlan': runningPlan,
      'timeRunning': '${timeRunning.hour}:${timeRunning.minute}',
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
      'numberChild': numberChild,
      'ghepKho': ghepKho,
      'chooseMachine': chooseMachine,
      'paperConsumptionNorm': paperConsumptionNorm?.toJson(),
      'order': order?.toJson(),
    };
  }
}
