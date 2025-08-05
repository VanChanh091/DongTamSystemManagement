class AdminMachineBoxModel {
  int machineId;
  int timeToProduct;
  int speedOfMachine;
  final String machineName;

  AdminMachineBoxModel({
    required this.machineId,
    required this.timeToProduct,
    required this.speedOfMachine,
    required this.machineName,
  });

  factory AdminMachineBoxModel.fromJson(Map<String, dynamic> json) {
    return AdminMachineBoxModel(
      machineId: json['machineId'],
      timeToProduct: json['timeToProduct'] ?? 0,
      speedOfMachine: json['speedOfMachine'] ?? 0,
      machineName: json['machineName'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "timeToProduct": timeToProduct,
      "speedOfMachine": speedOfMachine,
      "machineName": machineName,
    };
  }
}
