import 'package:dongtam/utils/helper/helper_model.dart';

class AdminWaveCrestModel {
  final int waveCrestCoefficientId;
  final double? fluteE_1;
  final double? fluteE_2;
  final double? fluteB;
  final double? fluteC;
  final String machineName;

  AdminWaveCrestModel({
    required this.waveCrestCoefficientId,
    this.fluteE_1,
    this.fluteE_2,
    this.fluteB,
    this.fluteC,
    required this.machineName,
  });

  factory AdminWaveCrestModel.fromJson(Map<String, dynamic> json) {
    return AdminWaveCrestModel(
      waveCrestCoefficientId: json['waveCrestCoefficientId'],
      fluteE_1: toDouble(json['fluteE_1']),
      fluteE_2: toDouble(json['fluteE_2']),
      fluteB: toDouble(json['fluteB']),
      fluteC: toDouble(json['fluteC']),
      machineName: json['machineName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fluteE_1": fluteE_1,
      "fluteE_2": fluteE_2,
      "fluteB": fluteB,
      "fluteC": fluteC,
      "machineName": machineName,
    };
  }
}
