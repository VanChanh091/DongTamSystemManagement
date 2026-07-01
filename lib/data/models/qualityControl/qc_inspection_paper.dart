import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/material.dart';

class QcInspectionPaperModel {
  final int inspecPaperId;

  //user input
  final TimeOfDay timeInspection;
  final int? numberPallet;
  final int machineSpeed;
  final double moisture;
  final double steamPressure;
  final double preheaterTemp;
  final double fctValue;
  final double patValue;

  //boolean
  final bool blishter;
  final bool wrongWidth;
  final bool wrongLength;
  final bool wrongScoringSpec;
  final bool poorScoring;
  final bool dirtyLiner;
  final bool losseLiner;
  final bool earDefect;
  final bool skewedFlute;
  final bool warppage;
  final bool poorTrimCut;
  final bool misalignment;
  final bool glueDripping;
  final bool trimScrap;
  final bool poorBundling;
  final double totalWidthErr;
  final bool wrongProductInfo;

  //FK
  final int planningId;

  QcInspectionPaperModel({
    required this.inspecPaperId,
    required this.timeInspection,
    this.numberPallet,
    required this.machineSpeed,
    required this.moisture,
    required this.steamPressure,
    required this.preheaterTemp,
    required this.fctValue,
    required this.patValue,
    required this.blishter,
    required this.wrongWidth,
    required this.wrongLength,
    required this.wrongScoringSpec,
    required this.poorScoring,
    required this.dirtyLiner,
    required this.losseLiner,
    required this.earDefect,
    required this.skewedFlute,
    required this.warppage,
    required this.poorTrimCut,
    required this.misalignment,
    required this.glueDripping,
    required this.trimScrap,
    required this.poorBundling,
    required this.totalWidthErr,
    required this.wrongProductInfo,

    //FK
    required this.planningId,
  });

  factory QcInspectionPaperModel.fromJson(Map<String, dynamic> json) {
    return QcInspectionPaperModel(
      inspecPaperId: json["inspecPaperId"],

      timeInspection:
          json["timeInspection"] != null && json["timeInspection"] != ""
              ? parseTimeOfDay(json["timeInspection"])
              : const TimeOfDay(hour: 0, minute: 0),
      numberPallet: json["numberPallet"] ?? 0,
      machineSpeed: json["machineSpeed"] ?? 0,
      moisture: toDouble(json["lengthPaperPlanning"]),
      steamPressure: toDouble(json["steamPressure"]),
      preheaterTemp: toDouble(json["preheaterTemp"]),
      fctValue: toDouble(json["fctValue"]),
      patValue: toDouble(json["patValue"]),

      blishter: json["blishter"] ?? false,
      wrongWidth: json["wrongWidth"] ?? false,
      wrongLength: json["wrongLength"] ?? false,
      wrongScoringSpec: json["wrongScoringSpec"] ?? false,
      poorScoring: json["poorScoring"] ?? false,
      dirtyLiner: json["dirtyLiner"] ?? false,
      losseLiner: json["losseLiner"] ?? false,
      earDefect: json["earDefect"] ?? false,
      skewedFlute: json["skewedFlute"] ?? false,
      warppage: json["warppage"] ?? false,
      poorTrimCut: json["poorTrimCut"] ?? false,
      misalignment: json["misalignment"] ?? false,
      glueDripping: json["glueDripping"] ?? false,
      trimScrap: json["trimScrap"] ?? false,
      poorBundling: json["poorBundling"] ?? false,
      totalWidthErr: toDouble(json["totalWidthErr"]),
      wrongProductInfo: json["wrongProductInfo"] ?? false,

      //FK
      planningId: json["planningId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //user input
      "numberPallet": numberPallet,
      "machineSpeed": machineSpeed,
      "moisture": moisture,
      "steamPressure": steamPressure,
      "preheaterTemp": preheaterTemp,
      "fctValue": fctValue,
      "patValue": patValue,

      //boolean
      "blishter": blishter,
      "wrongWidth": wrongWidth,
      "wrongLength": wrongLength,
      "wrongScoringSpec": wrongScoringSpec,
      "poorScoring": poorScoring,
      "dirtyLiner": dirtyLiner,
      "losseLiner": losseLiner,
      "earDefect": earDefect,
      "skewedFlute": skewedFlute,
      "warppage": warppage,
      "poorTrimCut": poorTrimCut,
      "misalignment": misalignment,
      "glueDripping": glueDripping,
      "trimScrap": trimScrap,
      "poorBundling": poorBundling,
      "totalWidthErr": totalWidthErr,
      "wrongProductInfo": wrongProductInfo,

      //FK
      "planningId": planningId,
    };
  }
}
