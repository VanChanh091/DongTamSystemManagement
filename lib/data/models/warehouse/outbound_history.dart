import 'package:dongtam/data/models/order/order_model.dart';

class OutboundHistoryModel {
  final int outboundId;
  final DateTime dateOutbound;
  final String outboundSlipCode;
  final int deliveredQty;
  final int outboundQty;

  final String orderId;
  final Order? order;

  OutboundHistoryModel({
    required this.outboundId,
    required this.dateOutbound,
    required this.outboundSlipCode,
    required this.deliveredQty,
    required this.outboundQty,

    required this.orderId,
    required this.order,
  });

  factory OutboundHistoryModel.fromJson(Map<String, dynamic> json) {
    return OutboundHistoryModel(
      outboundId: json['outboundId'],
      dateOutbound: DateTime.parse(json['dateOutbound']),
      outboundSlipCode: json['outboundSlipCode'] ?? "",
      deliveredQty: json['deliveredQty'] ?? 0,
      outboundQty: json['outboundQty'] ?? 0,

      orderId: json['orderId'] ?? 0,
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
    );
  }
}
