import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class ReportProductionModel {
  final int qtyActually;
  final double qtyWasteNorm;
  final DateTime dayCompleted;
  final String shiftProduction;
  final String shiftManagement;
  final String? note;

  final Planning? planning;

  ReportProductionModel({
    required this.qtyActually,
    required this.qtyWasteNorm,
    required this.dayCompleted,
    required this.shiftProduction,
    required this.shiftManagement,
    this.note,

    this.planning,
  });

  factory ReportProductionModel.fromJson(Map<String, dynamic> json) {
    return ReportProductionModel(
      qtyActually: json['qtyActually'] ?? 0,
      qtyWasteNorm: toDouble(json['qtyWasteNorm']),
      dayCompleted: DateTime.parse(json['dayCompleted']),
      shiftProduction: json['shiftProduction'] ?? "",
      shiftManagement: json['shiftManagement'] ?? "",
      note: json['note'],
      planning:
          json['Planning'] != null ? Planning.fromJson(json['Planning']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qtyActually': qtyActually,
      'qtyWasteNorm': qtyWasteNorm,
      'dayCompleted': dayCompleted.toIso8601String(),
      'shiftProduction': shiftProduction,
      'shiftManagement': shiftManagement,
    };
  }
}
