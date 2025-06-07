import 'package:dongtam/utils/helper/helper_model.dart';

class PaperConsumptionNorm {
  final int? day, songE, matE, songB, matB, songC, matC;
  final double? weight,
      totalConsumption,
      DmDay,
      DmSongC,
      DmSongB,
      DmSongE,
      DmDao;

  PaperConsumptionNorm({
    this.day,
    this.songE,
    this.matE,
    this.songB,
    this.matB,
    this.songC,
    this.matC,
    this.weight,
    this.totalConsumption,
    this.DmDay,
    this.DmSongC,
    this.DmSongB,
    this.DmSongE,
    this.DmDao,
  });

  factory PaperConsumptionNorm.fromJson(Map<String, dynamic> json) {
    return PaperConsumptionNorm(
      day: json['day'] ?? 0,
      songE: json['songE'] ?? 0,
      matE: json['matE'] ?? 0,
      songB: json['songB'] ?? 0,
      matB: json['matB'] ?? 0,
      songC: json['songC'] ?? 0,
      matC: json['matC'] ?? 0,
      weight: toDouble(json['weight']),
      totalConsumption: toDouble(json['totalConsumption']),
      DmDay: toDouble(json['DmDay']),
      DmSongC: toDouble(json['DmSongC']),
      DmSongB: toDouble(json['DmSongB']),
      DmSongE: toDouble(json['DmSongE']),
      DmDao: toDouble(json['DmDao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'songE': songE,
      'matE': matE,
      'songB': songB,
      'matB': matB,
      'songC': songC,
      'matC': matC,
    };
  }
}
