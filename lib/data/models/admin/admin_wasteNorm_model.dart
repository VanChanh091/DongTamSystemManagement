import 'package:dongtam/utils/helper/helper_model.dart';

class AdminWasteNormModel {
  int wasteNormId;
  double waveCrest;
  double? waveCrestSoft;
  double lossInProcess;
  double lossInSheetingAndSlitting;
  String machineName;

  AdminWasteNormModel({
    required this.wasteNormId,
    required this.waveCrest,
    this.waveCrestSoft,
    required this.lossInProcess,
    required this.lossInSheetingAndSlitting,
    required this.machineName,
  });

  factory AdminWasteNormModel.fromJson(Map<String, dynamic> json) {
    return AdminWasteNormModel(
      wasteNormId: json['wasteNormId'],
      waveCrest: toDouble(json['waveCrest']),
      waveCrestSoft: toDouble(json['waveCrestSoft']),
      lossInProcess: toDouble(json['lossInProcess']),
      lossInSheetingAndSlitting: toDouble(json['lossInSheetingAndSlitting']),
      machineName: json['machineName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "waveCrest": waveCrest,
      "waveCrestSoft": waveCrestSoft,
      "lossInProcess": lossInProcess,
      "lossInSheetingAndSlitting": lossInSheetingAndSlitting,
      "machineName": machineName,
    };
  }
}
