import 'package:dongtam/data/models/order/order_model.dart';

class InboundHistoryModel {
  final int inboundId;
  final DateTime dateInbound;
  final int qtyPaper;
  final int qtyInbound;

  //FK
  final String orderId;
  final Order? order;

  InboundHistoryModel({
    required this.inboundId,
    required this.dateInbound,
    required this.qtyPaper,
    required this.qtyInbound,

    required this.orderId,
    required this.order,
  });

  factory InboundHistoryModel.fromJson(Map<String, dynamic> json) {
    return InboundHistoryModel(
      inboundId: json['inboundId'],
      dateInbound: DateTime.parse(json['dateInbound']),
      qtyPaper: json['qtyPaper'] ?? 0,
      qtyInbound: json['qtyInbound'] ?? 0,

      orderId: json['orderId'] ?? 0,
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
    );
  }
}
