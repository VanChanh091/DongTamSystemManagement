import "package:dongtam/utils/helper/helper_model.dart";

class AdminMachinePaperModel {
  int machineId;
  int timeChangeSize;
  int timeChangeSameSize;
  int speed2Layer;
  int speed3Layer;
  int speed4Layer;
  int speed5Layer;
  int speed6Layer;
  int speed7Layer;
  int paperRollSpeed;
  double machinePerformance;
  String machineName;
  String type;

  AdminMachinePaperModel({
    required this.machineId,
    required this.machineName,
    required this.timeChangeSize,
    required this.timeChangeSameSize,
    required this.speed2Layer,
    required this.speed3Layer,
    required this.speed4Layer,
    required this.speed5Layer,
    required this.speed6Layer,
    required this.speed7Layer,
    required this.paperRollSpeed,
    required this.machinePerformance,
    required this.type,
  });

  factory AdminMachinePaperModel.fromJson(Map<String, dynamic> json) {
    return AdminMachinePaperModel(
      machineId: toInt(json["machineId"]),
      machineName: json["machineName"] ?? "",
      timeChangeSize: toInt(json["timeChangeSize"]),
      timeChangeSameSize: toInt(json["timeChangeSameSize"]),
      speed2Layer: toInt(json["speed2Layer"]),
      speed3Layer: toInt(json["speed3Layer"]),
      speed4Layer: toInt(json["speed4Layer"]),
      speed5Layer: toInt(json["speed5Layer"]),
      speed6Layer: toInt(json["speed6Layer"]),
      speed7Layer: toInt(json["speed7Layer"]),
      paperRollSpeed: toInt(json["paperRollSpeed"]),
      machinePerformance: toDouble(json["machinePerformance"]),
      type: json["type"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "machineName": machineName,
      "timeChangeSize": timeChangeSize,
      "timeChangeSameSize": timeChangeSameSize,
      "speed2Layer": speed2Layer,
      "speed3Layer": speed3Layer,
      "speed4Layer": speed4Layer,
      "speed5Layer": speed5Layer,
      "speed6Layer": speed6Layer,
      "speed7Layer": speed7Layer,
      "paperRollSpeed": paperRollSpeed,
      "machinePerformance": machinePerformance,
      "type": type,
    };
  }
}
