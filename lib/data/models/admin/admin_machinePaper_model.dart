import 'package:dongtam/utils/helper/helper_model.dart';

class AdminMachinePaperModel {
  final int machineId;
  final String machineName;
  final int timeChangePaper;
  final int timeChangeOrderId;
  final int speed2Layer;
  final int speed3Layer;
  final int speed4Layer;
  final int speed5Layer;
  final int speed6Layer;
  final int speed7Layer;
  final int paperRollSpeed;
  final double machinePerformance;

  AdminMachinePaperModel({
    required this.machineId,
    required this.machineName,
    required this.timeChangePaper,
    required this.timeChangeOrderId,
    required this.speed2Layer,
    required this.speed3Layer,
    required this.speed4Layer,
    required this.speed5Layer,
    required this.speed6Layer,
    required this.speed7Layer,
    required this.paperRollSpeed,
    required this.machinePerformance,
  });

  factory AdminMachinePaperModel.fromJson(Map<String, dynamic> json) {
    return AdminMachinePaperModel(
      machineId: json['machineId'],
      machineName: json['machineName'],
      timeChangePaper: json['timeChangePaper'] ?? 0,
      timeChangeOrderId: json['timeChangeOrderId'] ?? 0,
      speed2Layer: json['speed2Layer'] ?? 0,
      speed3Layer: json['speed3Layer'] ?? 0,
      speed4Layer: json['speed4Layer'] ?? 0,
      speed5Layer: json['speed5Layer'] ?? 0,
      speed6Layer: json['speed6Layer'] ?? 0,
      speed7Layer: json['speed7Layer'] ?? 0,
      paperRollSpeed: json['paperRollSpeed'] ?? 0,
      machinePerformance: toDouble(json['machinePerformance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "machineName": machineName,
      "timeChangePaper": timeChangePaper,
      "timeChangeOrderId": timeChangeOrderId,
      "speed2Layer": speed2Layer,
      "speed3Layer": speed3Layer,
      "speed4Layer": speed4Layer,
      "speed5Layer": speed5Layer,
      "speed6Layer": speed6Layer,
      "speed7Layer": speed7Layer,
      "paperRollSpeed": paperRollSpeed,
      "machinePerformance": machinePerformance,
    };
  }
}
