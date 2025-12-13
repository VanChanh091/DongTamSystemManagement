import 'package:dongtam/data/models/warehouse/outbound_detail_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class OutboundHistoryModel {
  final int outboundId;
  final DateTime dateOutbound;
  final String outboundSlipCode;
  final double totalPriceOrder;
  final double? totalPriceVAT;
  final double totalPricePayment;
  final int totalOutboundQty;

  //FK
  final List<OutboundDetailModel>? detail;

  OutboundHistoryModel({
    required this.outboundId,
    required this.dateOutbound,
    required this.outboundSlipCode,
    required this.totalPriceOrder,
    this.totalPriceVAT,
    required this.totalPricePayment,
    required this.totalOutboundQty,

    this.detail,
  });

  factory OutboundHistoryModel.fromJson(Map<String, dynamic> json) {
    return OutboundHistoryModel(
      outboundId: json['outboundId'],
      dateOutbound: DateTime.parse(json['dateOutbound']),
      outboundSlipCode: json['outboundSlipCode'] ?? "",
      totalPriceOrder: toDouble(json['totalPriceOrder']),
      totalPriceVAT: toDouble(json['totalPriceVAT']),
      totalPricePayment: toDouble(json['totalPricePayment']),
      totalOutboundQty: json['outboundQty'] ?? 0,

      detail:
          json['detail'] != null
              ? List<OutboundDetailModel>.from(
                json['detail'].map((x) => OutboundDetailModel.fromJson(x)),
              )
              : [],
      // stages:
      //     json['stages'] != null
      //         ? List<PlanningStage>.from(json['stages'].map((x) => PlanningStage.fromJson(x)))
      //         : [],
    );
  }
}
