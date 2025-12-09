import 'package:dongtam/data/models/order/order_model.dart';

class InboundHistory {
  final int inboundId;
  final DateTime dateInbound;
  final int qtyPaper;
  final int inboundQty;

  //FK
  final String orderId;
  final Order? order;

  InboundHistory({
    required this.inboundId,
    required this.dateInbound,
    required this.qtyPaper,
    required this.inboundQty,

    required this.orderId,
    required this.order,
  });

  factory InboundHistory.fromJson(Map<String, dynamic> json) {
    return InboundHistory(
      inboundId: json['inboundId'],
      dateInbound: DateTime.parse(json['dateInbound']),
      qtyPaper: json['inboundQty'] ?? 0,
      inboundQty: json['inboundQty'] ?? 0,

      orderId: json['orderId'] ?? 0,
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
    );
  }
}
