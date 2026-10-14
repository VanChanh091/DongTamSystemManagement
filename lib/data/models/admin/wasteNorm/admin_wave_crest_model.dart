import "package:dongtam/utils/helper/helper_model.dart";

class AdminWaveCrestCoeffModel {
  int waveCrestCoefficientId;
  double? fluteE_1;
  double? fluteE_2;
  double? fluteB;
  double? fluteC;
  double? fluteA;
  String machineName;

  AdminWaveCrestCoeffModel({
    required this.waveCrestCoefficientId,
    this.fluteE_1,
    this.fluteE_2,
    this.fluteB,
    this.fluteC,
    this.fluteA,
    required this.machineName,
  });

  factory AdminWaveCrestCoeffModel.fromJson(Map<String, dynamic> json) {
    return AdminWaveCrestCoeffModel(
      waveCrestCoefficientId: json["waveCrestCoefficientId"],
      fluteE_1: toDouble(json["fluteE_1"]),
      fluteE_2: toDouble(json["fluteE_2"]),
      fluteB: toDouble(json["fluteB"]),
      fluteC: toDouble(json["fluteC"]),
      fluteA: toDouble(json["fluteA"]),
      machineName: json["machineName"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fluteE_1": fluteE_1,
      "fluteE_2": fluteE_2,
      "fluteB": fluteB,
      "fluteC": fluteC,
      "fluteA": fluteA,
      "machineName": machineName,
    };
  }
}
