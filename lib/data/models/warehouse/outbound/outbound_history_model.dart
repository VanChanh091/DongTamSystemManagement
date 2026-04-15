import 'package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class OutboundHistoryModel {
  final int outboundId;
  final DateTime dateOutbound;
  final String outboundSlipCode;
  final double totalPriceOrder;
  final double? totalPriceVAT;
  final double totalPricePayment;
  final int totalOutboundQty;
  final DateTime? dueDate;
  final double? paidAmount;
  final double? remainingAmount;
  final String status;

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
    this.dueDate,
    this.paidAmount,
    this.remainingAmount,
    required this.status,

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
      totalOutboundQty: json['totalOutboundQty'] ?? 0,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      paidAmount: toDouble(json['paidAmount']),
      remainingAmount: toDouble(json['remainingAmount']),
      status: json['status'] ?? "",

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
